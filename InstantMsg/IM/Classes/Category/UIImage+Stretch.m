//
//  UIImage+Stretch.m
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "UIImage+Stretch.h"

@implementation UIImage (Stretch)

/**
 *  图片拉伸
 *
 *  @return 经过拉伸处理的图片
 */
#pragma mark 拉伸图片

+ (UIImage *)resizeImage:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGFloat imageW = image.size.width * 0.5;
    CGFloat imageH = image.size.height * 0.5;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(imageH, imageW, imageH, imageW) resizingMode:UIImageResizingModeTile];
}
@end
