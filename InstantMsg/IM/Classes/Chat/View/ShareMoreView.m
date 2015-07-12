//
//  AddEtralView.m
//  IM
//
//  Created by Chan on 15/2/28.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "ShareMoreView.h"
#define kImageLength   kScreenWidth/4
#define kInputViewHight 200

@implementation ShareMoreView

- (instancetype)initWithFrame:(CGRect)frame
{

    if (self = [super initWithFrame:frame]) {
        UIImage *pic = [UIImage imageNamed:@"sharemore_pic"];
        UIImage *sight = [UIImage imageNamed:@"sharemore_sight"];
        UIImage *fav = [UIImage imageNamed:@"sharemore_myfav"];
        UIImage *wxtalk = [UIImage imageNamed:@"sharemore_wxtalk"];
        UIImage *location = [UIImage imageNamed:@"sharemore_location"];
        UIImage *video = [UIImage imageNamed:@"sharemore_video"];
        UIImage *voipvideo = [UIImage imageNamed:@"sharemore_videovoip"];
        UIImage *voiceinput = [UIImage imageNamed:@"sharemore_voiceinput"];
        UIImage *voipvoice = [UIImage imageNamed:@"sharemore_voipvoice"];
        UIImage *wallet = [UIImage imageNamed:@"sharemore_wallet"];
        UIImage *pay = [UIImage imageNamed:@"sharemorePay"];
        UIImage *service = [UIImage imageNamed:@"sharemore_service"];
        UIImage *card = [UIImage imageNamed:@"sharemore_friendcard"];
        UIImage *add = [UIImage imageNamed:@"sharemoreAdd"];
        NSArray *imgs = @[pic, sight, fav, wxtalk, location, video, voipvideo, voiceinput, voipvoice, wallet, pay
                          ,service, card, add];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 2*kScreenWidth, 200)];
//        [scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"sharemore_picbg"]]];
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kInputViewHight)];
        for (int row = 0; row < 2; row ++) {
            for (int col = 0; col < 4; col ++) {
                CGFloat x = col * kImageLength;
                CGFloat y = row * kImageLength;
                int index = row * 4 + col;
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setImage:imgs[index] forState:UIControlStateNormal];
                [btn setFrame:CGRectMake(x, y, kImageLength, kImageLength)];
                [btn setBackgroundColor:[UIColor clearColor]];
                btn.tag = index;
                [btn addTarget:self action:@selector(clickToShare:) forControlEvents:UIControlEventTouchUpInside];
                [view1 addSubview:btn];
            }
        }
        [scrollView addSubview:view1];
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kInputViewHight)];
        [self addSubview:scrollView];
    }
    return self;
}

- (void)clickToShare:(UIButton *)sender
{
    if (_clickShareButtonBlock) {
        _clickShareButtonBlock((int)sender.tag);
    }
}
@end
