//
//  HeaderView.h
//  IM
//
//  Created by Chan on 15/2/3.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendGroupModel;
@protocol HeaderViewDelegate;


@interface HeaderView : UITableViewHeaderFooterView
@property (nonatomic, strong) FriendGroupModel *friendGroup;
@property (nonatomic, assign) id<HeaderViewDelegate> headerViewDelegate;
+ (instancetype)headerViewWithTableView:(UITableView *)tableView;

@end

@protocol HeaderViewDelegate <NSObject>
@optional
- (void)headerViewDidClick:(HeaderView *)header;

@end