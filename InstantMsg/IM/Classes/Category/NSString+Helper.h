//
//  NSString+Helper.h
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

/**
 *  清空字符串中的空白字符
 *
 *  @return 清空空白字符串之后的字符串
 */
- (NSString *)trimString;

/**
 *  是否空字符串
 *
 *  @return 如果字符串为nil或者长度为0返回YES
 */
- (BOOL)isEmptyString;

/**
 *  返回沙盒中的文件路径
 *
 *  @return 返回当前字符串对应在沙盒中的完整文件路径
 */
- (NSString *)documentsPath;

/**
 *  写入系统偏好
 *
 *  @param key 写入键值
 */
- (void)saveToNSDefaultsWithKey:(NSString *)key;


- (CGSize)getContraintedSize:(CGSize) orignalSize  withFont:(UIFont *)font;

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
+ (NSString *)randomString;
- (NSString *)getParameterValue:(NSString *)param;

@end
