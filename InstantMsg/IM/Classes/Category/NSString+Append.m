//
//  NSString+Append.m
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "NSString+Append.h"

@implementation NSString (Append)
- (NSString *)appendStringBeforeSuffix:(NSString *)end
{

    NSString *fileName = [self lastPathComponent];//获取文件名
    NSString *suffix = [fileName pathExtension];//获取后缀

    NSString *test = [[[fileName stringByDeletingPathExtension] stringByAppendingString:end] stringByAppendingPathExtension:suffix];
    
    return test;
}
@end
