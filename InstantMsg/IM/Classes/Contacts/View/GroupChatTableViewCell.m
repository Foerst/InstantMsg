//
//  GroupChatTableViewCell.m
//  IM
//
//  Created by chan on 15/5/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "GroupChatTableViewCell.h"

#import "GroupCellFrameModel.h"
#import "UIButton+WebCache.h"
#import "ImageBrowser.h"
#import "JCAudioPlayer.h"
#import "UploadFileUtil.h"
#import "GroupMessageModel.h"


#define kAudioImageViewWidth 30
#define kAudioImageViewHeight 30

@interface GroupChatTableViewCell ()<JCAudioPlayerDelegate>
{
    UILabel *_timeLb;
    UIButton *_textBtn;
    UIButton *_avatorBtn;
    UILabel *_nickLb;
    //    JCAudioPlayer *_player;
    
}

@end

@implementation GroupChatTableViewCell

#pragma mark -初始化cell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //日期
        _timeLb = [[UILabel alloc] init];
        [_timeLb setBackgroundColor:[UIColor clearColor]];
        [_timeLb setTextColor:[UIColor blackColor]];
        _timeLb.textAlignment = NSTextAlignmentCenter;
        _timeLb.font = [UIFont systemFontOfSize:10];
        //内容
        _textBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_textBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_textBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        _textBtn.backgroundColor = [UIColor clearColor];
        _textBtn.titleLabel.numberOfLines = 0;
        _textBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _textBtn.contentEdgeInsets = UIEdgeInsetsMake(kSpace, 2*kSpace, kSpace, 2*kSpace);
        [_textBtn addTarget:self action:@selector(clickTextButton:) forControlEvents:UIControlEventTouchUpInside];
        //播放音频按钮
        UIImageView *audioIV = [[UIImageView alloc] init];
        audioIV.hidden = YES;
        audioIV.tag = 999;
        audioIV.animationDuration = 1.0f;
        [_textBtn addSubview:audioIV];
        //播放视频按钮
        UIImageView *playImgView = [[UIImageView alloc] init];
        playImgView.hidden = YES;
        playImgView.tag = 1000;
        playImgView.image = [UIImage imageNamed:@"Fav_detail_voice_play"];
        [_textBtn addSubview:playImgView];
        //头像
        _avatorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatorBtn.layer.masksToBounds = YES;
        _avatorBtn.layer.cornerRadius = 18.0f;
        _avatorBtn.userInteractionEnabled = YES;
        //昵称
        _nickLb = [[UILabel alloc] init];
        _nickLb.textColor = [UIColor blackColor];
        _nickLb.textAlignment = NSTextAlignmentLeft;
        _nickLb.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_timeLb];
        [self.contentView addSubview:_avatorBtn];
        [self.contentView addSubview:_textBtn];
        [self.contentView addSubview:_nickLb];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceDidInterrupted:) name:@"VoiceHasInterrupted" object:nil];
        
    }
    return self;
}
#pragma mark -接收到通知停止播放声音
- (void)voiceDidInterrupted:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *audioIV = (UIImageView *)[_textBtn viewWithTag:999];
        //        if (![audioIV isAnimating]) return ;
        [audioIV stopAnimating];
        _cellFrame.isAnimation = NO;
        
        //发送刷新通知
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatViewShouldRefreshVoice" object:nil];
    });
}
#pragma mark -点击浏览大图或播放声音
- (void)clickTextButton:(UIButton *)sender
{
    switch (sender.tag) {
        case 0://浏览图片
            [ImageBrowser browseImage:_textBtn];
            break;
        case 1://audio
            [self tapToPlayVoice];
            break;
        case 2://video
            [self tapToPlayVideo];
            break;
        default:
            break;
    }
    
}

#pragma mark -更新cell中子控件的frame
- (void)setCellFrame:(GroupCellFrameModel *)cellFrame
{
    _cellFrame = cellFrame;
    _timeLb.frame = cellFrame.timeLbFrame;
    _textBtn.frame = cellFrame.textBtnFrame;
    _avatorBtn.frame = cellFrame.avatorBtnFrame;
    _nickLb.frame = cellFrame.nickFrame;
    
    //设置内容
    _timeLb.text = cellFrame.cellMsg.timestamp;
    _nickLb.text = cellFrame.cellMsg.nickname;
    //清空textBtn内容
    [_textBtn setTitle:@"" forState:UIControlStateNormal];
    [_textBtn setImage:nil forState:UIControlStateNormal];
    _textBtn.tag = 100;//默认值
    
    //    for (UIView *subView in _textBtn.subviews) {
    //        NSLog(@"%@",subView.description);
    ////        if ([subView isKindOfClass:NSClassFromString(@"UIImageView")]) {
    //            [subView removeFromSuperview];
    ////        }
    //    }
    UIImageView *audioIV = (UIImageView *)[_textBtn viewWithTag:999];
    audioIV.hidden = YES;
    UIImageView *playImgView = (UIImageView *)[_textBtn viewWithTag:1000];
    playImgView.hidden = YES;
    //    for (int i = 0; i < _textBtn.subviews.count; i ++) {
    //        IMLog(@"count ======== %lu",(unsigned long)_textBtn.subviews.count);
    //        NSLog(@"%@",[_textBtn.subviews[i] description]);
    //
    //        [_textBtn.subviews[i] removeFromSuperview];
    //    }
    if ([cellFrame.cellMsg.body hasPrefix:@"http"] || [cellFrame.cellMsg.body hasPrefix:@"file:///"]) {//链接
        int ft = [[cellFrame.cellMsg.body getParameterValue:@"ft"] intValue];
        if (0 == ft) {//图片
            [_textBtn setTitle:nil forState:UIControlStateNormal];
            [_textBtn setTitle:nil forState:UIControlStateHighlighted];
            NSURL *url = [NSURL URLWithString:cellFrame.cellMsg.body];
            [_textBtn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"shot"]];
            _textBtn.tag = 0;
        }else if (1 == ft){//声音
            UIImageView *audioIV = (UIImageView *)[_textBtn viewWithTag:999];
            audioIV.frame = cellFrame.voiceFrame;
            audioIV.hidden = NO;
            NSArray *animationImages = nil;
            if (cellFrame.cellMsg.isFromMe) {
                UIImage *img1 = [UIImage imageNamed:@"chat_animation_white1"];
                UIImage *img2 = [UIImage imageNamed:@"chat_animation_white2"];
                UIImage *img3 = [UIImage imageNamed:@"chat_animation_white3"];
                audioIV.image = img3;
                animationImages = @[img1, img2, img3];
            }else {
                UIImage *img1 = [UIImage imageNamed:@"chat_animation1"];
                UIImage *img2 = [UIImage imageNamed:@"chat_animation2"];
                UIImage *img3 = [UIImage imageNamed:@"chat_animation3"];
                audioIV.image = img3;
                animationImages = @[img1, img2, img3];
            }
            
            audioIV.animationImages = animationImages;
            _textBtn.tag = 1;
            if (cellFrame.isAnimation) {
                [audioIV startAnimating];
            }
        }else if (2 == ft){//视频
            
            [_textBtn setTitle:nil forState:UIControlStateNormal];
            [_textBtn setTitle:nil forState:UIControlStateHighlighted];
            NSURL *url = [NSURL URLWithString:cellFrame.cellMsg.body];
            [self thumbnailImageForVideo:url atTime:1];
            _textBtn.tag = 2;
        }
    }else{//文字
        [_textBtn setTitle:cellFrame.cellMsg.body forState:UIControlStateNormal];
        [_textBtn setTitle:cellFrame.cellMsg.body forState:UIControlStateHighlighted];
        _textBtn.tag = 10;
    }
    if (cellFrame.cellMsg.isFromMe) {
        [_textBtn setAllStateBackgroundImageWithImageName:@"chat_send"];
        
    }else{
        [_textBtn setAllStateBackgroundImageWithImageName:@"chat_recive"];
    }
    [_avatorBtn setBackgroundImage:cellFrame.cellMsg.avator forState:UIControlStateNormal];
    
}
- (void)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    NSString *filename = videoURL.lastPathComponent;
    IMLog(@"filename ====%@",filename);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLSession *session = [NSURLSession sharedSession];
            //建立任务
            NSURLSessionDataTask *task = [session dataTaskWithURL:videoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                //上传
                [UploadFileUtil uploadFilewWithServerUrl:kFileServerIP fileName:[NSString randomString] fileData:data finish:^(NSString *result) {
#warning do something to upload file
                }];
            }];
            [task resume];//启动任务
        });
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        int minute = 0, second = 0;
        second = asset.duration.value / asset.duration.timescale; // 获取视频总时长,单位秒
        //NSLog(@"movie duration : %d", second);
        if (second >= 60) {
            int index = second / 60;
            minute = index;
            second = second - index*60;
        }
        NSParameterAssert(asset);
        AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetImageGenerator.appliesPreferredTrackTransform = YES;
        assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        CFTimeInterval thumbnailImageTime = time;
        NSError *thumbnailImageGenerationError = nil;
        CGImageRef thumbnailImageRef = NULL;
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
        
        if (!thumbnailImageRef){
            NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
        }
        UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_textBtn setImage:thumbnailImage forState:UIControlStateNormal];
            UIImageView *playImgView = (UIImageView *)[_textBtn viewWithTag:1000];
            playImgView.hidden = NO;
            playImgView.bounds = CGRectMake(0, 0, 32, 32);
            playImgView.center = CGPointMake(_textBtn.bounds.size.width / 2, _textBtn.bounds.size.height / 2);
        });
        
    });
    
}
#pragma mark -播放视频
- (void)tapToPlayVideo
{
    
}
#pragma mark -播放音频
- (void)tapToPlayVoice
{
    //声音链接
    NSString *voicePath = self.cellFrame.cellMsg.body;
    NSURLSession *session = [NSURLSession sharedSession];
    //建立任务
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:voicePath] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
//        __weak typeof(self) *p = self;
        if (error == nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *err;
                JCAudioPlayer *player = [JCAudioPlayer sharedJCAudioPlayer];
                if (err == nil) {
                    player.delegate = self;
                    NSError *err;
                    [player playWithContentsOfData:data error:&err];
                    
                }
                
            });
        }
    }];
    [task resume];//启动任务
}

#pragma mark -JCAudioPlayerDelegate method
- (void)audioPlayerDidStartPlaying:(JCAudioPlayer *)player
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *audioIV = (UIImageView *)[_textBtn viewWithTag:999];
        //        if (![audioIV isAnimating]) return ;
        [audioIV startAnimating];
        _cellFrame.isAnimation = YES;
        
        
        //发送刷新通知
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatViewShouldRefreshVoice" object:nil];
    });
    
}
- (void)audioPlayerDidFinishPlaying:(JCAudioPlayer *)player
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *audioIV = (UIImageView *)[_textBtn viewWithTag:999];
        //        if (![audioIV isAnimating]) return ;
        [audioIV stopAnimating];
        _cellFrame.isAnimation = NO;
        
        //发送刷新通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatViewShouldRefreshVoice" object:nil];
    });
}


////- (void)audioPlayerDidInterrupted:(JCAudioPlayer *)player
////{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIImageView *audioIV = (UIImageView *)[_textBtn viewWithTag:999];
//        //        if (![audioIV isAnimating]) return ;
//        [audioIV stopAnimating];
//        _cellFrame.isAnimation = NO;
//
//        //发送刷新通知
//        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatViewShouldRefreshVoice" object:nil];
//    });
////}

@end
