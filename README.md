# ClientSocket
Socket方式实现客户端通讯

##前言
Socket网络编程在任何一门编程语言中都很重要,而且socket底层是纯C语言,跨平台,了解并熟悉底层交互是提高自己编程水平重要的一步.环环在此稍加总结,如果有童鞋要面试还能用的上,结尾附有demo案例(IOS).

##正文
- 首先明确Socket在网络模型中哪里:是应用层与传输层之间的桥梁
![image](http://upload-images.jianshu.io/upload_images/3222021-2cc70f7644cfa160.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 回顾一下网络模型: OSI七层网络模型:
1.应用层.2.表示层.3.会话层.4.传输层.5.网络层.6.数据链路层.7.物理层
  TCP/IP四层网络模型:应用层.传输层.网络层.网络接入层
-  HTTP协议:属于应用层面向对象的协议(超文本传输协议),常基于TCP连接方式, 特点是:
1.支持客户/服务端模式
2.简单快捷灵活
3.客户端发送的每次请求都需要服务器回送响应,请求结束后主动释放连接.俗称”短连接"

- TCP协议:传输控制协议,提供面向连接.可靠的字节流服务,提供超时重发，丢弃重复数据，检验数据，流量控制等功能。在正式收发数据前,必须建立可靠的连接,也即:三次握手.
>第一次握手:客户端发送syn包(syn=j)到服务器，并进入SYN_SEND状态，等待服务器确认；
 第二次握手:服务器收到syn包，必须确认客户的SYN（ack=j+1），同时自己也发送一个SYN包（syn=k），即SYN+ACK包，此时服务器进入SYN_RECV状态；
第三次握手:客户端收到服务器的SYN＋ACK包，向服务器发送确认包ACK(ack=k+1)，此包发送完毕，客户端和服 务器进入ESTABLISHED状态，完成三次握手。

- UDP协议:用户数据报协议,面向非连接,不保证可靠性的数据传输服务,没有超时重发等机制，故而传输速度很快.
> 特点:它不与对方建立连接，而是直接就把数据包发送过去, UDP适用于一次只传送少量数据、对可靠性要求不高的应用环境。

- Socket:又称”套接字”,应用程序通过”套接字”向网络发送请求或应答,它是一个针对TCP和UDP编程的接口，借助它建立TCP/UDP连接。socket连接就是所谓的长连接,理论上客户端和服务器端一旦建立起连接将不会主动断掉.

- HTTP协议—Socket连接--TCP连接关系:
>1.HTTP协议提供了封装或者显示数据的具体形式;
2.Socket连接提供了网络通信的能力;
3.TCP连接提供如何在网络中传输;
4.socket是纯C语言的,跨平台;
5.HTTP协议是基于socket的,底层使用的就是socket;
6.创建Socket连接时，可以指定使用的传输层协议(TCP或UDP),当使用TCP协议进行连接时，该Socket连接就是一个TCP连接。

- TCP和UDP区别
>1.基于连接和无连接
2.对系统资源要求(TCP较多,UDP较少)
3.UDP程序结构较简单
4.TCP是流模式,UDP是数据报模式
5.可靠性:TCP保证数据正确性,UDP可能丢包,不保证数据准确性

-     Socket通信流程图
![image](http://upload-images.jianshu.io/upload_images/3222021-cd8d5f24db60a352.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
以socket客户端编程为例:
0.导入头文件
```
#import <arpa/inet.h>
#import <netinet/in.h>
#import <sys/socket.h>
```
1.创建socket
```
@implementation ViewController {
    int _clientSocket;
}

  /*
     1.AF_INET: ipv4 执行ip协议的版本
     2.SOCK_STREAM：指定Socket类型,面向连接的流式socket 传输层的协议
     3.IPPROTO_TCP：指定协议。 IPPROTO_TCP 传输方式TCP传输协议
     返回值 大于0 创建成功
     */
_clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
```
2.建立连接(与服务器)
```
  /*
     终端里面 命令模拟服务器 netcat  nc -lk 12345
     参数一：套接字描述符
     参数二：指向数据结构sockaddr的指针，其中包括目的端口和IP地址
     参数三：参数二sockaddr的长度，可以通过sizeof（struct sockaddr）获得
     返回值 int -1失败 0 成功
  */
    struct sockaddr_in addr;
   /* 填写sockaddr_in结构*/
    addr.sin_family = AF_INET;
    addr.sin_port=htons(12345);
    addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    int connectResult= connect( _clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
```
3.发送数据(到服务器)
```
   /*
      第一个参数指定发送端套接字描述符；
      第二个参数指明一个存放应用程式要发送数据的缓冲区；
      第三个参数指明实际要发送的数据的字符数；
      第四个参数一般置0。
      成功则返回实际传送出去的字符数，失败返回－1，
   */
      char * str = "itcast";
      ssize_t sendLen = send( _clientSocket, str, strlen(str), 0);
```
4.接送数据(从服务器)
```
     /*
      第一个参数socket
      第二个参数存放数据的缓冲区
      第三个参数缓冲区长度。
      第四个参数指定调用方式,一般置0
      返回值 接收成功的字符数
     */
      char *buf[1024];
      ssize_t recvLen = recv( _clientSocket, buf, sizeof(buf), 0);
      NSLog(@"---->%ld",recvLen);
```
5.关闭连接
```
       close( _clientSocket);
```

6.demo封装方法:
```
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
    }
}
//发送数据并等待返回数据
- (NSString *)sentAndRecv:(NSString *)msg {
   const char *str = msg.UTF8String;
//发消息
    ssize_t sendLen = send(_clientSocket, str, strlen(str), 0);
//收消息
    char *buf[1024];
    ssize_t recvLen = recv(_clientSocket, buf, sizeof(buf), 0);
    NSString *recvStr = [[NSString alloc] initWithBytes:buf length:recvLen encoding:NSUTF8StringEncoding];
    return recvStr;
}

```
案例效果图:

![image](http://upload-images.jianshu.io/upload_images/3222021-4f9cad812d011444.gif?imageMogr2/auto-orient/strip)
案例一:多线程实现服务端与客户端简单的交互,我的demo地址:
服务端:https://github.com/zhonghphuan/ServerSocket.git
客户端:https://github.com/zhonghphuan/ClientSocket.git

案例二:利用Socket发送HTTP格式的请求并且通过浏览器监控:
https://github.com/FieldsOfHope/Socket_Interactive.git

如果有其他问题,请私信我:<a href="mailto:zhonghphuan@hotmail.com">zhonghphuan@hotmail.com</a>

github Demo已更新【20190228】：域名与IP问题转换
感谢@十二月青 提出的问题。
![图片.png](https://upload-images.jianshu.io/upload_images/3222021-dfa594689c623470.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
