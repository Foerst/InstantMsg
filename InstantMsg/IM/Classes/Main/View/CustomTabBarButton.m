//
//  CustomBarButton.m
//  IM
//
//  Created by Chan on 15/1/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "CustomTabBarButton.h"
#define kImageHeightRatio 0.75

@implementation CustomTabBarButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 图标居中
        self.imageView.contentMode = UIViewContentModeCenter;
        // 文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 字体大小
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        //字体颜色
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
        
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{

    return CGRectMake(0, 0, contentRect.size.width, contentRect.size.height*kImageHeightRatio);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, contentRect.size.height*kImageHeightRatio, contentRect.size.width, contentRect.size.height*(1 - kImageHeightRatio));
}



- (void)setItem:(UITabBarItem *)item
{
    _item = item;
    [self setImage:item.image forState:UIControlStateNormal];
    [self setImage:item.selectedImage forState:UIControlStateSelected];
    [self setTitle:item.title forState:UIControlStateNormal];

    
}
@end
