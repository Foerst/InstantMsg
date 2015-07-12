//
//  FriendsGroupModel.h
//  IM
//
//  Created by Chan on 15/2/4.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSFetchedResultsController;

@interface FriendGroupModel : NSObject

@property (nonatomic, copy) NSString *headTitle;
@property (nonatomic, assign) NSInteger totalNum;
@property (nonatomic, assign) BOOL isOpened;
@property (nonatomic, strong) id<NSFetchedResultsSectionInfo> sectionInfo;

@end
