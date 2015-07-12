//
//  TableViewCell.m
//  IM
//
//  Created by chan on 15/5/14.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "RecentMsgTableViewCell.h"
#import "RecentMsgModel.h"


@implementation RecentMsgTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecentMsgTableViewCell" owner:nil options:nil][0];
        self.avator.layer.masksToBounds = YES;
        self.avator.layer.cornerRadius = 30.0f;
    }
    return self;
}


+ (instancetype)recentMsgTableViewCell
{
    return [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseId];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setMsgModel:(RecentMsgModel *)msgModel
{
    _msgModel = msgModel;
   
    [self.avator setImage:msgModel.avatorImage];
    self.textLb.text = msgModel.nickname;
    self.detailLb.text = msgModel.body;
    self.timeLb.text = msgModel.timestamp;
}
@end
