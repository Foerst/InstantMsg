//
//  SocketClient.m
//  IM
//
//  Created by Chan on 15/3/16.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "SocketClient.h"

@interface SocketClient ()<NSStreamDelegate>
{
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
}

@end

@implementation SocketClient

//- (void)setSocketClientDelegate:(id)socketClientDelegate
//{
//    //set delegate
//    _socketClientDelegate = socketClientDelegate;
//    _inputStream.delegate = socketClientDelegate;
//    _outputStream.delegate = socketClientDelegate;
//}
- (void)setupSocketWithHost:(NSString *)hostAddress port:(UInt32)port
{
    //convert nsstring to cfstringref
    CFStringRef host = (__bridge CFStringRef)hostAddress;
    CFReadStreamRef rStream;
    CFWriteStreamRef wStream;
    //create socket
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &rStream, &wStream);
    //convert from cf to ns
    _inputStream = (__bridge NSInputStream *)(rStream);
    _outputStream = (__bridge NSOutputStream *)(wStream);
    
    //set delegate
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    
    //add to runloop
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    //open stream
    [_inputStream open];
    [_outputStream open];
    
}


#pragma mark -nsstrema delegate method
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone://no response
            NSLog(@"NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted://stream opened,ready to read&write
            NSLog(@"NSStreamEventOpenCompleted");
            break;
        case NSStreamEventHasBytesAvailable://can read bytes
            NSLog(@"NSStreamEventHasBytesAvailable");
            //do read here
            [self readStream];
            break;
        case NSStreamEventHasSpaceAvailable://can write bytes
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
        case NSStreamEventErrorOccurred:// error occurred
            NSLog(@"NSStreamEventErrorOccurred");
            break;
        case NSStreamEventEndEncountered://stream close
            NSLog(@"NSStreamEventEndEncountered");
            break;
            
        default:
            break;
    }
}

- (void)writeStream:(NSString *)msg
{
  
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    if (_outputStream) {
        NSInteger writtenBytes = [_outputStream write:[msgData bytes] maxLength:msgData.length];
    }
    
}

- (void)readStream
{
    //建立一个缓冲区 可以放1024个字节
    uint8_t buf[1024];
    
    // 返回实际装的字节数
    NSInteger len = [_inputStream read:buf maxLength:sizeof(buf)];
    
    // 把字节数组转化成字符串
    NSData *data = [NSData dataWithBytes:buf length:len];
    
    // 从服务器接收到的数据
    NSString *recStr =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    IMLog(@"------------received string:%@",recStr);
    
}

- (void)sendString:(NSString *)msgStr
{
     [self writeStream:msgStr];
//    __weak SocketClient *sClient = self;
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//       
//    });
    
}
@end
