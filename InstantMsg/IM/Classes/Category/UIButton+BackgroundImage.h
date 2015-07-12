//
//  UIButton+BackgroundImage.h
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (BackgroundImage)
/**
 *  设置按钮普通和高亮状态下的背景图片
 *
 *  @param imgName 图片名称
 */
- (void)setAllStateBackgroundImageWithImageName:(NSString *)imgName;

- (void)setAllStateImageWithImageName:(NSString *)imgName;
@end
