//
//  TableViewCell.h
//  IM
//
//  Created by chan on 15/5/14.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RecentMsgModel;
#define kReuseId @"RecentMsgTableViewCell"
@interface RecentMsgTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avator;
@property (weak, nonatomic) IBOutlet UILabel *textLb;

@property (weak, nonatomic) IBOutlet UILabel *detailLb;

@property (weak, nonatomic) IBOutlet UILabel *timeLb;

@property (nonatomic, strong) RecentMsgModel *msgModel;

+ (instancetype)recentMsgTableViewCell;
@end
