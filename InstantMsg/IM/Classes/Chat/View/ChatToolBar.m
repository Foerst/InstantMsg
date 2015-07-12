//
//  ChatView.m
//  IM
//
//  Created by Chan on 15/2/4.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "ChatToolBar.h"
#import "EmotionView.h"
#import "ShareMoreView.h"

@interface ChatToolBar ()<UITextFieldDelegate>
{
    UIButton *_voiceBtn;
    UITextField *_msgField;
    UIButton *_moreBtn;
    UIImageView *_toolBarBg;
    UIButton *_emojiBtn;
    UIButton *_recordVoiceBtn;
    
}

@end


@implementation ChatToolBar


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [voiceButton setAllStateBackgroundImageWithImageName:@"chat_bottom_voice"];
//        [self addSubview:voiceButton];
//        _voiceBtn = voiceButton;
//        
//        
//        UITextField *inputField = [[UITextField alloc] init];
//        [inputField setBackground:[UIImage imageNamed:@"chat_bottom_textfield"]];
//        [self addSubview:inputField];
//        _msgField = inputField;
        
        UIView *bgView = [[UIView alloc] init];
        bgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        bgView.userInteractionEnabled = YES;
        bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chat_bottom_bg"]];
        [self addSubview:bgView];
        //添加声音按钮
        UIButton *sendSoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendSoundBtn.frame = CGRectMake(0, 0, kChatToolBarHeight, kChatToolBarHeight);
        [sendSoundBtn setImage:[UIImage imageNamed:@"chat_bottom_voice"] forState:UIControlStateNormal];
        [sendSoundBtn addTarget:self action:@selector(showVoiceRecorderButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendSoundBtn];
        _voiceBtn = sendSoundBtn;
        
        //添加加号按钮
        UIButton *addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addMoreBtn.frame = CGRectMake(kScreenWidth - kChatToolBarHeight, 0, kChatToolBarHeight, kChatToolBarHeight);
        [addMoreBtn setImage:[UIImage imageNamed:@"chat_bottom_up"] forState:UIControlStateNormal];
        [self addSubview:addMoreBtn];
        _moreBtn = addMoreBtn;
        [_moreBtn addTarget:self action:@selector(showAddMore) forControlEvents:UIControlEventTouchUpInside];
        //添加表情按钮
        UIButton *expressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        expressBtn.frame = CGRectMake(kScreenWidth - kChatToolBarHeight * 2, 0, kChatToolBarHeight, kChatToolBarHeight);
       
        [expressBtn setAllStateImageWithImageName:@"chat_bottom_smile"];
        [self addSubview:expressBtn];
        [expressBtn addTarget:self action:@selector(showEmoji) forControlEvents:UIControlEventTouchUpInside];
        _emojiBtn = expressBtn;
        
        //添加输入文本框
        UITextField *textField = [[UITextField alloc] init];
        textField.returnKeyType = UIReturnKeySend;
        textField.enablesReturnKeyAutomatically = YES;
        textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 1)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.frame = CGRectMake(kChatToolBarHeight, (kChatToolBarHeight - kTextFieldH) * 0.5, kScreenWidth - 3*kChatToolBarHeight, kTextFieldH);
        IMLog(@"%@",NSStringFromCGRect(textField.frame));
        textField.background = [UIImage imageNamed:@"chat_bottom_textfield"];
        textField.delegate = self;
        [self addSubview:textField];
        _msgField = textField;
        
        //添加录音按钮
        UIButton *recordBtn = [[UIButton alloc] init];
        recordBtn.hidden = YES;
        recordBtn.alpha = 0.0f;
        [recordBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
        [recordBtn setTitle:@"释放 发送" forState:UIControlStateHighlighted];
        [self addSubview:recordBtn];
        [recordBtn setBackgroundColor:[UIColor greenColor]];
        _recordVoiceBtn = recordBtn;
        _recordVoiceBtn.frame = CGRectMake(kChatToolBarHeight, (kChatToolBarHeight - kTextFieldH) * 0.5, kScreenWidth - 2*kChatToolBarHeight, kTextFieldH);
        [_recordVoiceBtn addTarget:self action:@selector(startRecordingVoice) forControlEvents:UIControlEventTouchDown];
        [_recordVoiceBtn addTarget:self action:@selector(stopRecordingVocie) forControlEvents:UIControlEventTouchUpInside];
        [_recordVoiceBtn addTarget:self action:@selector(cancelRecordingVocie) forControlEvents:UIControlEventTouchDragExit];
        
    
    }
    return self;
}
#pragma mark -取消录音
- (void)cancelRecordingVocie
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBarDidCancleAudioRecording:)]) {
        [_delegate chatToolBarDidCancleAudioRecording:self];
    }
}
#pragma mark -开始录音
- (void)startRecordingVoice
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBarDidStartAudioRecording:)]) {
        [_delegate chatToolBarDidStartAudioRecording:self];
    }
    
}
#pragma mark -停止录音
- (void)stopRecordingVocie
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBarDidStopAudioRecording:)]) {
        [_delegate chatToolBarDidStopAudioRecording:self];
    }
}
#pragma mark -显示录音按钮
- (void)showVoiceRecorderButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _recordVoiceBtn.hidden = ! _recordVoiceBtn.hidden;
    _emojiBtn.hidden = !_emojiBtn.hidden;
    _msgField.hidden = !_msgField.hidden;
    //实现淡入淡出效果
    [UIView animateWithDuration:0.8f animations:^{
        _recordVoiceBtn.alpha = 1.0f;
        if (sender.isSelected) {
            [_voiceBtn setImage:[UIImage imageNamed:@"Album_ToolViewKeyboard"] forState:UIControlStateNormal];

        }else{
            [_voiceBtn setImage:[UIImage imageNamed:@"chat_bottom_voice"] forState:UIControlStateNormal];
            _recordVoiceBtn.alpha = 0.0f;

        }
        } completion:^(BOOL finished) {
       
    }];
    
}
#pragma mark -textfield delegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (self.textFieldShouldReturnBlock) {
        self.textFieldShouldReturnBlock(textField.text);
        textField.text = @"";
    }
    return YES;
}


#pragma mark -显示表情输入视图
- (void)showEmoji
{
    _emojiBtn.selected = !_emojiBtn.selected;
    if (_emojiBtn.isSelected) {//显示自定义键盘
        EmotionView *emotionView = [[EmotionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 250)];
         //赋值添加字符block
        emotionView.clickEmojiBlock = ^(NSString *text){
            UITextRange *selectedRange = [_msgField selectedTextRange];
            NSInteger offset = [_msgField offsetFromPosition:_msgField.endOfDocument toPosition:selectedRange.end];
            //修改内容
            NSString *currentText = _msgField.text;
            NSString *str1 = [currentText substringToIndex:currentText.length + offset];
            NSString *str2 = [currentText substringFromIndex:currentText.length + offset];
            currentText = [NSString stringWithFormat:@"%@%@%@",str1,text,str2];
            _msgField.text  = currentText;
            //修改文本框的文本后，重新打开光标所在位置UITextPosition如下：
            UITextPosition *newPos = [_msgField positionFromPosition:_msgField.endOfDocument offset:offset];
            _msgField.selectedTextRange = [_msgField textRangeFromPosition:newPos toPosition:newPos];
        };
        //赋值删除字符block
        emotionView.clickDeleteBtnBlock = ^{
            //为什么会有selectedTextRange：光标有左右两部分组成，默认startPosition = endPostion
            UITextRange *selectedRange = [_msgField selectedTextRange];
            //计算光标偏移量，负值
            NSInteger offset = [_msgField offsetFromPosition:_msgField.endOfDocument toPosition:selectedRange.end];
            //修改内容
            NSString *currentText = _msgField.text;
            int index = (int)(currentText.length - 1 + offset);
            if (index < 0) return ;
            NSString *str1 = [currentText substringToIndex:currentText.length - 1 + offset];
            NSString *str2 = [currentText substringFromIndex:currentText.length + offset];
            currentText = [NSString stringWithFormat:@"%@%@",str1,str2];
            _msgField.text  = currentText;
            //修改文本框的文本后，重新打开光标所在位置UITextPosition如下：
            UITextPosition *newPos = [_msgField positionFromPosition:_msgField.endOfDocument offset:offset];
            _msgField.selectedTextRange = [_msgField textRangeFromPosition:newPos toPosition:newPos];
            
          
        };
        _msgField.inputView = emotionView;
        [_msgField reloadInputViews];
        [_msgField becomeFirstResponder];
    }else{//重新加载键盘
        [_msgField setInputView:nil];
        [_msgField reloadInputViews];
    }
    
    
}
#pragma mark -显示分享
- (void)showAddMore
{
    //退出准备录音状态
    if (!_recordVoiceBtn.hidden) {
        [self showVoiceRecorderButton:_voiceBtn];
    }
    _moreBtn.selected = !_moreBtn.isSelected;
    if (_moreBtn.isSelected) {//显示自定义键盘
        ShareMoreView *shareView = [[ShareMoreView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        shareView.clickShareButtonBlock = ^(int tag){
            if (_shareBlock) {
                _shareBlock(tag);
            }
        };
        _msgField.inputView = shareView;
        [_msgField reloadInputViews];
        [_msgField becomeFirstResponder];
    }
    else{//重新加载键盘
        [_msgField setInputView:nil];
        [_msgField reloadInputViews];
    }

}
#pragma mark -隐藏键盘
- (void)hideKeyBoard
{
    [_msgField resignFirstResponder];
}

- (void)popKeyBoard
{
    [_msgField becomeFirstResponder];
}


@end
