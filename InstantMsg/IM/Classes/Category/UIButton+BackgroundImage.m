//
//  UIButton+BackgroundImage.m
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "UIButton+BackgroundImage.h"

@implementation UIButton (BackgroundImage)
#pragma mark 设置按钮普通和高亮状态下的背景图片
- (void)setAllStateBackgroundImageWithImageName:(NSString *)imgName
{
    if (imgName == nil || [[imgName trimString] isEqualToString:@""]) {
        [self setBackgroundImage:nil forState:UIControlStateNormal];
        [self setBackgroundImage:nil forState:UIControlStateHighlighted];
        return;
    }
    UIImage *imgNormal = [UIImage resizeImage:imgName];
    [self setBackgroundImage:imgNormal forState:UIControlStateNormal];
    UIImage *imgHI = [UIImage resizeImage:[imgName appendStringBeforeSuffix:@"HL"]];
    [self setBackgroundImage:imgHI forState:UIControlStateHighlighted];
    
}

#pragma mark 设置按钮普通和高亮状态下的图片
- (void)setAllStateImageWithImageName:(NSString *)imgName
{
    if (imgName == nil || [[imgName trimString] isEqualToString:@""]) {
        [self setImage:nil forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateHighlighted];
        return;
    }
    UIImage *imgNormal = [UIImage resizeImage:imgName];
    [self setImage:imgNormal forState:UIControlStateNormal];
    UIImage *imgHI = [UIImage resizeImage:[imgName appendStringBeforeSuffix:@"HL"]];
    [self setImage:imgHI forState:UIControlStateSelected];
    
}

@end
