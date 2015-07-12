//
//  GroupCellFrameModel.h
//  IM
//
//  Created by chan on 15/5/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GroupMessageModel;
#define kSpace 10
@interface GroupCellFrameModel : NSObject
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGRect timeLbFrame;
@property (nonatomic, assign) CGRect avatorBtnFrame;
@property (nonatomic, assign) CGRect textBtnFrame;
@property (nonatomic, assign) CGRect voiceFrame;
@property (nonatomic, assign) CGRect nickFrame;
@property (nonatomic, assign) Boolean isAnimation;
@property (nonatomic, strong) GroupMessageModel *cellMsg;
@end
