//
//  HeaderView.m
//  IM
//
//  Created by Chan on 15/2/3.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "HeaderView.h"
#import "FriendGroupModel.h"

@interface HeaderView ()
{
    __block UIButton *_bgButton;
    UILabel *_detailLabel;
}

@end
@implementation HeaderView

#pragma mark -类构造方法
+ (instancetype)headerViewWithTableView:(UITableView *)tableView
{
    static NSString * const HeaderViewID = @"HeaderView";
    HeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewID];
    if (headerView == nil) {
        headerView = [[HeaderView alloc] initWithReuseIdentifier:HeaderViewID];
    }
    return headerView;
}

#pragma mark -初始化方法
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bgBtn setBackgroundImage:[UIImage imageNamed:@"buddy_header_bg"] forState:UIControlStateNormal];
        [bgBtn setBackgroundImage:[UIImage imageNamed:@"buddy_header_bg_highlighted"] forState:UIControlStateHighlighted];
        [bgBtn setImage:[UIImage imageNamed:@"buddy_header_arrow"]forState:UIControlStateNormal];
        [self addSubview:bgBtn];
        [bgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        bgBtn.imageView.contentMode = UIViewContentModeCenter;
        bgBtn.imageView.clipsToBounds = NO;
        bgBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        bgBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        bgBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [bgBtn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchDown];
//        bgBtn.tag = 0;
        _bgButton = bgBtn;
        
        UILabel *titleLb = [[UILabel alloc] init];
        titleLb.textAlignment = NSTextAlignmentRight;
        titleLb.font = [UIFont fontWithName:nil size:10];
        titleLb.text = @"10/10";
        [self addSubview:titleLb];
        _detailLabel = titleLb;
        
        
    }
    return self;
    
}
#pragma mark -布局子视图，自动调用
- (void)layoutSubviews
{
    [super layoutSubviews];
    _bgButton.frame = self.bounds;
    _detailLabel.frame = CGRectMake(self.frame.size.width - 70, 0, 70, self.frame.size.height);
}

#pragma mark -点击headerview触发
- (void)buttonClick
{
//    sender.tag = !sender.tag;
    self.friendGroup.isOpened = !self.friendGroup.isOpened;
//    [self rotateArrow];
    if ([self.headerViewDelegate respondsToSelector:@selector(headerViewDidClick:)]) {
        [self.headerViewDelegate headerViewDidClick:self];
    }
    
}

#pragma mark -箭头旋转90
//- (void)rotateArrow
//{
//    [UIView animateWithDuration:0.3f animations:^{
//                        _bgButton.imageView.transform = CGAffineTransformMakeRotation(M_PI_2 );
//        
//                    }];
//}


- (void)didMoveToSuperview
{
    _bgButton.imageView.transform = _friendGroup.isOpened ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformMakeRotation(0);
}

- (void)setFriendGroup:(FriendGroupModel *)friendGroup
{
    _friendGroup = friendGroup;
    [_bgButton setTitle:friendGroup.headTitle forState:UIControlStateNormal];
    [_bgButton setTitle:friendGroup.headTitle forState:UIControlStateHighlighted];
    _detailLabel.text = [NSString stringWithFormat:@"共%ld人",friendGroup.totalNum];
    _detailLabel.font = [UIFont systemFontOfSize:10.0f];
    
    
}
@end
