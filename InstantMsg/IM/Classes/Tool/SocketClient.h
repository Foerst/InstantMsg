//
//  SocketClient.h
//  IM
//
//  Created by Chan on 15/3/16.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketClient : NSObject
@property (nonatomic, strong) id socketClientDelegate;


- (void)setupSocketWithHost:(NSString *)hostAddress port:(UInt32)port;


- (void)sendString:(NSString *)msgStr;
- (void)sendData:(NSData *)msgData;
- (void)sendPic:(UIImage *)img;

@end
