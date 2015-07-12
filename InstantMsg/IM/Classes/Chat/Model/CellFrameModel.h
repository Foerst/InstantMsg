//
//  CellFrame.h
//  IM
//
//  Created by Chan on 15/2/10.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CellMessageModel.h"
#define kSpace 10

@interface CellFrameModel : NSObject

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGRect timeLbFrame;
@property (nonatomic, assign) CGRect avatorBtnFrame;
@property (nonatomic, assign) CGRect textBtnFrame;
@property (nonatomic, assign) CGRect voiceFrame;
@property (nonatomic, assign) Boolean isAnimation;
@property (nonatomic, strong) CellMessageModel *cellMsg;
@end
