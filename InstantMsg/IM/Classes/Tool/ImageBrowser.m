//
//  ImageBrowser.m
//  IM
//
//  Created by Chan on 15/3/18.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "ImageBrowser.h"
#import <QuartzCore/QuartzCore.h>

static UIView *backgroundView;
static UIButton *originalBtn;

@implementation ImageBrowser
#pragma mark -overview the image
+ (void)browseImage:(UIButton *)orignImg
{

    originalBtn = orignImg;
    UIWindow *keyWindow = [[UIApplication sharedApplication].delegate window];
    UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgroundView = bgView;
    backgroundView.alpha = 0.0f;
    bgView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBg:)];
    [bgView addGestureRecognizer:tapGesture];
    
    CGRect newFrame = [orignImg convertRect:orignImg.bounds toView:keyWindow];//注意：这里用的是bounds属性
   
    UIButton *imgView = [UIButton buttonWithType:UIButtonTypeCustom];
    [imgView setUserInteractionEnabled:NO];
    [imgView setBackgroundImage:orignImg.imageView.image forState:UIControlStateNormal];
    
    imgView.frame = newFrame;
    
    [keyWindow addSubview:bgView];
    [bgView addSubview:imgView];
    
    [UIView animateWithDuration:0.5f animations:^{
        float sizingRatio = kScreenWidth / orignImg.imageView.image.size.width;
        CGFloat x = 0;
        CGFloat height = orignImg.imageView.image.size.height * sizingRatio;
        CGFloat y = (kScreenHeight - height)/2;
        
        imgView.frame = CGRectMake(x, y, kScreenWidth, height);
//        backgroundView.layer.opacity = 1.0f;
        
        backgroundView.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
    }];
  
}

#pragma mark -add tap gesture,tap to return
+ (void)tapBg:(UITapGestureRecognizer *)tap
{
    UIView *tapView = tap.view;
    __block CGRect originalFrame = [originalBtn convertRect:originalBtn.bounds toView:[[UIApplication sharedApplication].delegate window]];
    UIButton *sizingBtn = tapView.subviews[0];
    [UIView animateWithDuration:0.5f animations:^{
        sizingBtn.frame = originalFrame;
        backgroundView.alpha = 0.6f;
        
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];

    }];
  
    
}
@end
