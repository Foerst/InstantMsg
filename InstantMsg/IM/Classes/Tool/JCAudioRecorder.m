//
//  JCAudioRecorder.m
//  IM
//
//  Created by Chan on 15/3/20.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "JCAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface JCAudioRecorder ()<AVAudioRecorderDelegate>
{
    AVAudioRecorder *_recorder;
    NSString *_mp3Path;
    NSString *_pcmPath;
    NSTimer *_timer;
}

@end


@implementation JCAudioRecorder

- (instancetype)init
{
    if (self = [super init]) {
        [self setMP3Path];
        [self setPCMPath];
        [self setupRecorder];
        //真机录音必加
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
    }
    return self;
}

- (void)setMP3Path
{
    if (_mp3Path) return;
    _mp3Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"mp3.caf"];
}

- (void)setPCMPath
{
    if (_pcmPath) return;
    _pcmPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"];
}
#pragma mark -初始化AVAudioRecorder
- (void)setupRecorder
{
    if (_recorder == nil) {
        NSURL *url = [NSURL fileURLWithPath:_pcmPath];
        NSMutableDictionary *settings = [NSMutableDictionary dictionary];
        //录音格式 无法使用
        [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [settings setValue:@(16) forKey:AVEncoderBitRatePerChannelKey];
       
        //采样率
        [settings setValue:@(8000.0f) forKey: AVSampleRateKey];//44100.0
        //通道数
        [settings setValue:@(1) forKey: AVNumberOfChannelsKey];
        //音频质量,采样质量
        [settings setValue:@(AVAudioQualityMax) forKey:AVEncoderAudioQualityKey];
        
        NSError *error = nil;
        _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        
        if (error) {
            if (_audioRecorderDelegate && [_audioRecorderDelegate respondsToSelector:@selector(audioRecorder:endWithFailure:)]) {
                [_audioRecorderDelegate audioRecorder:self endWithFailure:@"audio recorder created failure"];
            }
            return;
        }
        //开启音量检测
        [_recorder prepareToRecord];
        _recorder.meteringEnabled = YES;
        _recorder.delegate = self;
        [_recorder prepareToRecord];

    }
}

#pragma mark -start recording
- (void)record
{
    if (_recorder) {
        [_recorder record];
//        dispatch_queue_t queue = dispatch_get_main_queue();
//        dispatch_async(queue, ^{
            [ProgressHUD show:@"手指上滑，取消发送" imgage:[UIImage imageNamed:@"record_animate_01.png"] spin:NO hide:NO];
//        });
        //开启声音音量侦测
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    
    }
}
                  
- (void)detectionVoice
{
    [_recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    NSLog(@"%lf",lowPassResults);
    NSString *imgNameStr = @"";
    //最大50  0
    //图片 小-》大
    IMLog(@"音量大小--->：%f",lowPassResults);
    if (0<lowPassResults<=0.06) {
        imgNameStr = @"record_animate_01.png";
    }else if (0.06<lowPassResults<=0.13) {
        imgNameStr = @"record_animate_02.png";
    }else if (0.13<lowPassResults<=0.20) {
        imgNameStr = @"record_animate_03.png";
    }else if (0.20<lowPassResults<=0.27) {
        imgNameStr = @"record_animate_04.png";
    }else if (0.27<lowPassResults<=0.34) {
        imgNameStr = @"record_animate_05.png";
    }else if (0.34<lowPassResults<=0.41) {
        imgNameStr = @"record_animate_06.png";
    }else if (0.41<lowPassResults<=0.48) {
        imgNameStr = @"record_animate_07.png";
    }else if (0.48<lowPassResults<=0.55) {
        imgNameStr = @"record_animate_08.png";
    }else if (0.55<lowPassResults<=0.62) {
        imgNameStr = @"record_animate_09.png";
    }else if (0.62<lowPassResults<=0.69) {
        imgNameStr = @"record_animate_10.png";
    }else if (0.69<lowPassResults<=0.76) {
        imgNameStr = @"record_animate_11.png";
    }else if (0.76<lowPassResults<=0.83) {
        imgNameStr = @"record_animate_12.png";
    }else if (0.83<lowPassResults<=0.9) {
        imgNameStr = @"record_animate_13.png";
    }else {
        imgNameStr = @"record_animate_14.png";
    }

    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [ProgressHUD show:@"手指上滑，取消发送" imgage:[UIImage imageNamed:imgNameStr] spin:NO hide:NO];
    });
}

#pragma mark -暂停录音
- (void)pause
{
    if (_recorder) {
        [_recorder pause];
    }
}
#pragma mark -停止录音
- (void)stop
{
    if (_recorder) {
        [_recorder stop];
        [_timer invalidate];
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^{
            [ProgressHUD show:@"Stopped" duration:1.0f isCountDown:NO];
        });
        
    }
}

- (void)cancel
{
    [self stop];
}
#pragma mark -AVAudioRecorderDelegate methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    IMLog(@"----->audioRecorderDidFinishRecording");
    if (_audioRecorderDelegate && [_audioRecorderDelegate respondsToSelector:@selector(audioRecorder:endWithSuccess:)]) {
        NSURL *url = [NSURL fileURLWithPath:_pcmPath];
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (error) {
            IMLog(@"%@",error.localizedDescription);
            return;
        }
        [_audioRecorderDelegate audioRecorder:self endWithSuccess:data];
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    IMLog(@"----->audioRecorderEncodeErrorDidOccur");
    if (_audioRecorderDelegate && [_audioRecorderDelegate respondsToSelector:@selector(audioRecorder:endWithFailure:)]) {
        [_audioRecorderDelegate audioRecorder:self endWithFailure:error.description];
    }
}
@end
