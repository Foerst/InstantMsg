//
//  JCAudioPlayer.m
//  IM
//
//  Created by Chan on 15/4/9.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "JCAudioPlayer.h"

@interface JCAudioPlayer ()<AVAudioPlayerDelegate>
{
    AVAudioPlayer *_player;
}


@end

@implementation JCAudioPlayer

single_implementation(JCAudioPlayer)

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *) error
{
    if (self = [super init]) {

        self = [[[self class] alloc] initWithContentsOfData:[NSData dataWithContentsOfURL:url] error:error];
    }
    return self;
}

- (instancetype)initWithContentsOfData:(NSData *)data error:(NSError *__autoreleasing *) error
{
    if (self = [super init]) {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
        NSError *err;
        _player = [[AVAudioPlayer alloc] initWithData:data error:&err];
        if (err) {
            IMLog(@"%@",err.localizedDescription);
            *error = err;
        }else {
            _player.volume = 1.0f;
            _player.delegate = self;
            [_player prepareToPlay];
        }
    }
    return self;
}
- (void)loadVoice
{
    
}

//- (Boolean)isPlaying
//{
//    return _player.isPlaying;
//}
static id<JCAudioPlayerDelegate> lastDelegate = nil;
- (void)setDelegate:(id<JCAudioPlayerDelegate>)delegate
{
    _delegate = delegate;
    if (lastDelegate == nil) {
        lastDelegate = _delegate;
    }
}
- (void)playWithContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *) error
{

    NSData *data = [NSData dataWithContentsOfURL:url];
    [self playWithContentsOfData:data error:error];

}
- (void)playWithContentsOfData:(NSData *)data error:(NSError *__autoreleasing *) error
{
//    [self.delegate audioPlayerDidFinishPlaying:self];
//    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
//    if (data == nil) return;
//    if (_player) {
//        [self stop];
//
//        if (lastDelegate  == _delegate) return;
//        lastDelegate = _delegate;
//    }
//
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VoiceHasInterrupted" object:nil];
    NSError *e;
    _player = [[AVAudioPlayer alloc] initWithData:data error:&e];
    if (e) {
        IMLog(@"--------------%@",e.localizedDescription);
        *error = e;
    }else {
        _player.delegate = self;
        [self play];
        
    }

}
- (void)destroy
{
    _player = nil;
}
- (void)play
{
    _player.volume = 1.0f;
    [_player prepareToPlay];
    [_player play];
    [self.delegate audioPlayerDidStartPlaying:self];
}
- (void)pause
{
    if (_player) {
        [_player pause];
    }
}
- (void)stop
{
    if (_player) {
        [_player stop];
        if (lastDelegate && [lastDelegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)]) {
            [lastDelegate audioPlayerDidFinishPlaying:self];
        }
    }

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (_delegate && [_delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)]) {
        [_delegate audioPlayerDidFinishPlaying:self];
    }
}



@end
