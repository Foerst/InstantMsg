//
//  ChatView.h
//  IM
//
//  Created by Chan on 15/2/4.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kChatToolBarHeight 44
#define kTextFieldH 30

@protocol ChatToolBarDelegate;
typedef void (^ChatToolBarBlock)(NSString *);

@interface ChatToolBar : UIView

@property (nonatomic, copy) ChatToolBarBlock textFieldShouldReturnBlock;

@property (nonatomic, copy) void (^shareBlock)(int tag);

@property (nonatomic, weak) id<ChatToolBarDelegate> delegate;
- (void)hideKeyBoard;
- (void)popKeyBoard;

@end

@protocol ChatToolBarDelegate <NSObject>

- (void)chatToolBarDidStartAudioRecording:(ChatToolBar *)bar;
- (void)chatToolBarDidStopAudioRecording:(ChatToolBar *)bar;
- (void)chatToolBarDidCancleAudioRecording:(ChatToolBar *)bar;
@end