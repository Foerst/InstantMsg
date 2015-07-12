//
//  UIImage+Stretch.h
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Stretch)
/**
 *  拉伸图片
 *
 *  @param imageName 图片名
 *
 *  @return 经过拉伸的图片
 */
+ (UIImage *)resizeImage:(NSString *)imageName;
@end
