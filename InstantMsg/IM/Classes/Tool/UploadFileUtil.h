//
//  UploadFileUtil.h
//  IM
//
//  Created by Chan on 15/2/28.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadFileUtil : NSObject

+ (NSString *)uploadFilewWithServerUrl:(NSString *)urlStr fileName:(NSString *)fileName fileData:(NSData *)data finish:(void(^)(NSString *result)) block;

+ (NSString *)uploadFilewWithServerUrl:(NSString *)urlStr fileName:(NSString *)fileName fileData:(NSData *)data;
@end
