//
//  JCAudioRecorder.h
//  IM
//
//  Created by Chan on 15/3/20.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JCAudioRecorder;
@protocol  JCAudioRecorderDelegate;


@interface JCAudioRecorder : NSObject

@property (weak, nonatomic) id<JCAudioRecorderDelegate> audioRecorderDelegate;
- (void)record;
- (void)pause;
- (void)stop;
- (void)cancel;

@end


@protocol JCAudioRecorderDelegate <NSObject>
@required
- (void)audioRecorder:(JCAudioRecorder *) recorder endWithFailure:(NSString *)errorStr;
- (void)audioRecorder:(JCAudioRecorder *) recorder endWithSuccess:(NSData *)audioData;


@end