//
//  ViewController.m
//  socket聊天
//
//  Created by ZH on 16/10/14.
//  Copyright © 2016年 钟环. All rights reserved.
//

#import "ViewController.h"
#import <arpa/inet.h>
#import <netinet/in.h>
#import <sys/socket.h>

#include<unistd.h>
#include<arpa/inet.h>
#include<netdb.h>
void error_handling(char *message);

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tf_ip;
@property (weak, nonatomic) IBOutlet UITextField *tf_port;
@property (weak, nonatomic) IBOutlet UITextField *tf_sendMSG;
@property (weak, nonatomic) IBOutlet UITextView *tv_showMSG;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (nonatomic,assign) int flag;
@end

@implementation ViewController {
    int _clientSocket;//nc -lk 1024
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)connClick:(id)sender {
    if (_flag == 0) {
        NSString *ip = self.tf_ip.text;
        int port = [self.tf_port.text intValue];
        NSString *validIP = [self isValidIP:ip] ? ip :[self getIP:ip];
        [self connectToServer:validIP port:port];
        [sender setTitle:@"关闭" forState:UIControlStateNormal];
        self.flag = 1;
    }else{
        [sender setTitle:@"连接" forState:UIControlStateNormal];
        shutdown(_clientSocket, SHUT_RDWR);
        close(_clientSocket);
        _status.text = @"连接断开";
        
        self.flag = 0;
    }
}

- (BOOL)isValidIP:(NSString *)ipStr {
    if (nil == ipStr) {
        return NO;
    }
    
    NSArray *ipArray = [ipStr componentsSeparatedByString:@"."];
    if (ipArray.count == 4) {
        for (NSString *ipnumberStr in ipArray) {
            int ipnumber = [ipnumberStr intValue];
            if (!(ipnumber>=0 && ipnumber<=255)) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (IBAction)snedClick:(id)sender {
    [self sentAndRecv:self.tf_sendMSG.text];
}

//发送数据并等待返回数据
- (void)sentAndRecv:(NSString *)msg {
    dispatch_queue_t q_con =  dispatch_queue_create("CONCURRENT", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(q_con, ^{
        const char *str = msg.UTF8String;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
        ssize_t sendLen = send(self->_clientSocket, str, strlen(str), 0);
#pragma clang diagnostic pop
        char *buf[1024];
        ssize_t recvLen = recv(self->_clientSocket, buf, sizeof(buf), 0);
        NSString *recvStr = [[NSString alloc] initWithBytes:buf length:recvLen encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.tv_showMSG.text = recvStr;
        });
    });
    
}

//建立连接
- (void)connectToServer:(NSString *)ip port:(int)port {
    _clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    struct sockaddr_in addr;
    /* 填写sockaddr_in结构*/
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr(ip.UTF8String);
    
    int connectResult = connect(_clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
    
    if (connectResult == 0) {
        NSLog(@"conn ok");
        _status.text = @"连接成功";
    }else{
        
        _status.text = @"连接失败";
        
    }
}


- (NSString *)getIP:(NSString *)ip {
    int i;
    struct hostent* host;
    host=gethostbyname(ip.UTF8String);
    if(!host)
    {
        error_handling("gethostbyname error");
    }
    
    printf("official name is %s\n",host->h_name);
    for(i=0;host->h_aliases[i];i++)
    {
        printf("Aliases %d: %s\n",i+1,host->h_aliases[i]);
    }
    
    printf("Address type: %s\n",
           host->h_addrtype==AF_INET?"AF_INET":"AF_INET6");
    NSMutableString *mutStr = [NSMutableString string];
    for(i=0;host->h_addr_list[i];i++)
    {
        printf("IP addr %d: %s \n",i+1,
               inet_ntoa(*(struct in_addr*)host->h_addr_list[i]));
        NSString *str=[NSString stringWithUTF8String:inet_ntoa(*(struct in_addr*)host->h_addr_list[i])];
        [mutStr appendFormat:@"%@", str];
    }
    return mutStr;
}

void error_handling(char* message)
{
    fputs(message,stderr);
    fputc('\n',stderr);
    exit(0);
}

@end
