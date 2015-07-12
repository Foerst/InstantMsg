//
//  MainViewController.m
//  IM
//
//  Created by Chan on 15/1/14.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "MainViewController.h"
#import "CustomTabbar.h"

@interface MainViewController ()

@end

@implementation MainViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 删除系统自动生成的UITabBarButton
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTabbar];
    
   

}

- (void)setupTabbar
{
    CustomTabbar *tabbar = [[CustomTabbar alloc] init];
    tabbar.frame = self.tabBar.bounds;
    [self.tabBar addSubview:tabbar];
    tabbar.selectBlock = ^(int index){
        self.selectedIndex = index;
    };
    
    NSArray *imagenameArray = @[@"tabbar_mainframe",@"tabbar_contacts",@"tabbar_me"];
    NSArray *titleArray = @[@"微聊",@"通讯录",@"我"];
    
    for (int i = 0;i < titleArray.count;i++) {
        UITabBarItem *item =[[UITabBarItem alloc] initWithTitle:titleArray[i] image:[UIImage imageNamed:imagenameArray[i]] selectedImage:[UIImage imageNamed:[imagenameArray[i] appendStringBeforeSuffix:@"HL"]]];
        [tabbar addTabBarItem:item];
    }
    
    
}


@end
