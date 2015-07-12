//
//  CustomTabbar.m
//  IM
//
//  Created by Chan on 15/1/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "CustomTabbar.h"
#import "CustomTabBarButton.h"
#define kItemWidth

@interface CustomTabbar ()
{
    UIButton *_selectedButton;
}

@property (nonatomic, strong) NSMutableArray *tabBarButtonArray;

@end

@implementation CustomTabbar


#pragma mark  get method
- (NSMutableArray *)tabBarButtonArray
{
    if (_tabBarButtonArray == nil){
        _tabBarButtonArray = [NSMutableArray array];
    }
    return _tabBarButtonArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //设置背景图片
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbarBkg"]];

    }
    return self;
}

/**
 *  点击tabbar触发该方法
 *
 *  @param sender 点击的按钮
 */

#pragma mark 点击tabbar触发该方法
- (void)selectItem:(UIButton *)sender
{
    
    if (_selectBlock) {
        _selectedButton.selected = !_selectedButton.selected;
        _selectedButton = sender;
        sender.selected = !sender.selected;
        if (_selectBlock) {
             _selectBlock((int)sender.tag);
        }
    }
    
}


//- (void)adjustFrames
//{
//    CGFloat width  = kScreenWidth / self.subviews.count;
//    for (int i = 0; i < self.subviews.count; i ++) {
//        CustomTabBarButton *button = (CustomTabBarButton *)self.subviews[i];
//        button.frame = CGRectMake(i*width, 0, width, 49);
//    }
//}

/**
 *  为tabbar添加item
 *
 *  @param item UITabBarItem对象
 */

#pragma mark 为tabbar添加item
- (void)addTabBarItem:(UITabBarItem *)item
{
   
    static NSInteger count = 0;
    CustomTabBarButton *button = [CustomTabBarButton buttonWithType:UIButtonTypeCustom];

    button.item = item;
    button.tag = count;
    count ++;
    [self addSubview:button];
    [self.tabBarButtonArray addObject:button];
    
    if (1 == self.tabBarButtonArray.count) {
        [self selectItem:button];
    }
    [button addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -在这里调整子控件的frame ，代替adjustFrames方法。每添加一个子视图就会触发该方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width  = kScreenWidth / self.subviews.count;
    for (int i = 0; i < self.subviews.count; i ++) {
        CustomTabBarButton *button = (CustomTabBarButton *)self.subviews[i];
        button.frame = CGRectMake(i*width, 0, width, 49);
    }
    
}
@end
