//
//  
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "NSString+Helper.h"
#define kRandomStringLength 16


@implementation NSString (Helper)

#pragma mark 清空字符串中的空白字符
- (NSString *)trimString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark 是否空字符串
- (BOOL)isEmptyString
{
    return  self.length == 0;
}

#pragma mark 返回沙盒中的文件路径
- (NSString *)documentsPath
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [path stringByAppendingString:self];
}

#pragma mark 写入系统偏好
- (void)saveToNSDefaultsWithKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:self forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];//立即写入
}

#pragma mark -给定字符串和字体，计算字体高度，宽带
- (CGSize)getContraintedSize:(CGSize) orignalSize  withFont:(UIFont *)font
{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    //    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName:paragraphStyle.copy
                                 };
    return [self boundingRectWithSize:orignalSize options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    //    //获取当前文本的属性
    //    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text];
    //    _label1.attributedText = attrStr;
    //    NSRange range = NSMakeRange(0, attrStr.length);
    //    // 获取该段attributedString的属性字典
    //    NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];
    //    return [text boundingRectWithSize:orignalSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
}


- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}


+ (NSString *)randomString
{
    char data[kRandomStringLength];
    for (int x = 0;x < kRandomStringLength; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:kRandomStringLength encoding:NSUTF8StringEncoding];
}
- (NSString *)getParameterValue:(NSString *)param
{
    NSString *params = [self componentsSeparatedByString:@"?"][1];
//    NSDictionary *dict = [[NSDictionary alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([params rangeOfString:@"&"].location != NSNotFound) {
        NSArray *keyValues = [params componentsSeparatedByString:@"&"];
        for (NSString * keyValue in keyValues) {
            NSString *key = [keyValue componentsSeparatedByString:@"="][0];
            NSString *value = [keyValue componentsSeparatedByString:@"="][1];
            [dict setObject:value forKey:key];//是setobject :
        }
    }else {
        NSArray *keyValues = [params componentsSeparatedByString:@"="];
        NSString *key = keyValues[0];
        NSString *value = keyValues[1];
        [dict setObject:value forKey:key];//是setobject :


    }
    return [dict objectForKey:param];
}
@end
