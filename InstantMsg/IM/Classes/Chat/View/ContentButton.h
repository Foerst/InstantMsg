//
//  ContentButtonView.h
//  IM
//
//  Created by Chan on 15/4/17.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ContentButtonTypeText = 0,
    ContentButtonTypePicture,
    ContentButtonTypeVoice,
    ContentButtonTypeVideo,
    ContentButtonTypeCustom
} ContentButtonType;


@interface ContentButton : UIButton

@end
