//
//  CustomTabbar.h
//  IM
//
//  Created by Chan on 15/1/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabbar : UIView
@property (nonatomic,copy) void (^selectBlock)(int index);//用于通知控制器点击哪个按钮的block
- (void)addTabBarItem:(UITabBarItem *)item;
@end
