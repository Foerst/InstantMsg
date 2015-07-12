//
//  FriendsGroupModel.m
//  IM
//
//  Created by Chan on 15/2/4.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "FriendGroupModel.h"
#import <CoreData/CoreData.h>


@implementation FriendGroupModel

- (void)setSectionInfo:(id<NSFetchedResultsSectionInfo>)sectionInfo
{
    _sectionInfo = sectionInfo;
    self.headTitle = [sectionInfo name];
    self.totalNum = [sectionInfo numberOfObjects];
    self.isOpened = YES;
    
}
- (void)setHeadTitle:(NSString *)headTitle
{
    
    NSString *stateName = nil;
    NSInteger state = [headTitle integerValue];
    
    switch (state) {
        case 0:
            stateName = @"在线";
            break;
        case 1:
            stateName = @"离开";
            break;
        case 2:
            stateName = @"下线";
            break;
        default:
            stateName = @"未知";
            break;
    }
    
    _headTitle = stateName;
}
@end
