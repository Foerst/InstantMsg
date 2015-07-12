//
//  EmotionView.h
//  IM
//
//  Created by Chan on 15/2/25.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmotionView : UIView
@property (nonatomic, copy) void (^clickEmojiBlock)(NSString *text);
@property (nonatomic, copy) void (^clickDeleteBtnBlock)();
@end
