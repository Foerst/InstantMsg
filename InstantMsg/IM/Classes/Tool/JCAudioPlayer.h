//
//  JCAudioPlayer.h
//  IM
//
//  Created by Chan on 15/4/9.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol JCAudioPlayerDelegate;

@interface JCAudioPlayer : NSObject

single_interface(JCAudioPlayer)
@property (nonatomic, strong) id<JCAudioPlayerDelegate> delegate;
//@property (nonatomic, assign) Boolean isPlaying;

//- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *) error;
//- (instancetype)initWithContentsOfData:(NSData *)data error:(NSError *__autoreleasing *) error;
- (void)loadVoice;
- (void)playWithContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *) error;
- (void)playWithContentsOfData:(NSData *)data error:(NSError *__autoreleasing *) error;
- (void)play;
- (void)pause;
- (void)stop;
@end


@protocol JCAudioPlayerDelegate <NSObject>

@optional
- (void)audioPlayerDidStartPlaying:(JCAudioPlayer *)player;
- (void)audioPlayerDidFinishPlaying:(JCAudioPlayer *)player;
- (void)audioPlayerDidInterrupted:(JCAudioPlayer *)player;

@end