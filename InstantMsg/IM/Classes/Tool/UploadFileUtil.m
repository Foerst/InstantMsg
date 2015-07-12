//
//  UploadFileUtil.m
//  IM
//
//  Created by Chan on 15/2/28.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "UploadFileUtil.h"

@interface UploadFileUtil ()<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@end


@implementation UploadFileUtil



+ (NSString *)uploadFilewWithServerUrl:(NSString *)urlStr fileName:(NSString *)fileName fileData:(NSData *)data finish:(void(^)(NSString *result)) block
{
    NSString *boundary = @"_YJAYgDL082HLBJkC1laRbpjU5PlLgeJh_";

    // Request:
    
    //    NSURL* URL = [NSURL URLWithString:@"http://localhost:8080/UploadFile/upload.jsp"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30.000000;
    
    // Headers
    
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField: @"Content-Type"];
    
    
    // Body
    //路径以mac下yy用户为例，windows替换为c:\aaaa.dat
//    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    
    //    NSData * data = [NSData dataWithContentsOfFile:@"/Users/yy/Downloads/aaaa.dat"];
    NSStringEncoding encoding = NSUTF8StringEncoding; //NSASCIIStringEncoding;
    
    
    NSMutableData * senddata = [[NSMutableData alloc] init];
    
    [senddata appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:encoding]];
    [senddata appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n\r\n", fileName] dataUsingEncoding:encoding]];
    [senddata appendData:data];
    [senddata appendData:[@"\r\n" dataUsingEncoding:encoding]];
    [senddata appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:encoding]];
    
    
    request.HTTPBody = senddata; // Set your own body data
    
    // Connection
    
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    [NSURLConnection sendAsynchronousRequest:request queue:<#(NSOperationQueue *)#> completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//        NSLog(@"returnString: %@", returnString);
//
//    }];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"returnString: %@", returnString);
    return returnString;
}

+ (NSString *)uploadFilewWithServerUrl:(NSString *)urlStr fileName:(NSString *)fileName fileData:(NSData *)data
{
    NSString *boundary = @"_YJAYgDL082HLBJkC1laRbpjU5PlLgeJh_";
    
    // Request:
    
    //    NSURL* URL = [NSURL URLWithString:@"http://localhost:8080/UploadFile/upload.jsp"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30.000000;
    
    // Headers
    
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField: @"Content-Type"];
    
    
    // Body
    //路径以mac下yy用户为例，windows替换为c:\aaaa.dat
    //    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    //    NSData *data = [NSData dataWithContentsOfFile:path];
    //
    //    NSData * data = [NSData dataWithContentsOfFile:@"/Users/yy/Downloads/aaaa.dat"];
    NSStringEncoding encoding = NSUTF8StringEncoding; //NSASCIIStringEncoding;
    
    
    NSMutableData * senddata = [[NSMutableData alloc] init];
    
    [senddata appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:encoding]];
    [senddata appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n\r\n", fileName] dataUsingEncoding:encoding]];
    [senddata appendData:data];
    [senddata appendData:[@"\r\n" dataUsingEncoding:encoding]];
    [senddata appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:encoding]];
    
    
    request.HTTPBody = senddata; // Set your own body data
    
    // Connection
    
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_sync(queue, ^{
//        [conn start];
//    });
    
//        [NSURLConnection sendAsynchronousRequest:request queue:<#(NSOperationQueue *)#> completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//            NSLog(@"returnString: %@", returnString);
//    
//        }];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"returnString: %@", returnString);
    return returnString;
    
}


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    IMLog(@"bytesWritten---%ld   totalBytesWritten---%ld  totalBytesExpectedToWrite---%ld ",bytesWritten,totalBytesWritten, totalBytesExpectedToWrite);
}
@end
