//
//  EmotionView.m
//  IM
//
//  Created by Chan on 15/2/25.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "EmotionView.h"
#define kRowCount 4
#define kColCount 7
#define kStartPoint CGPointMake(6, 20)
#define kButtonSize CGSizeMake(44, 44)

static unichar emotechars[28] =
{
    0xe415, 0xe056, 0xe057, 0xe414, 0xe405, 0xe106, 0xe418,
    0xe417, 0xe40d, 0xe40a, 0xe404, 0xe105, 0xe409, 0xe40e,
    0xe402, 0xe108, 0xe403, 0xe058, 0xe407, 0xe401, 0xe416,
    0xe40c, 0xe406, 0xe413, 0xe411, 0xe412, 0xe410, 0xe059,
};
@implementation EmotionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 设置背景颜色
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        // 使用一个临时数组记录所有的按钮
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:28];
        
        // 初始化界面选择的按钮，仅负责按钮的创建并设置位置
        for (NSInteger row = 0; row < kRowCount; row++) {
            for (NSInteger col = 0; col < kColCount; col++) {
                // 1. 计算出按钮索引（第几个按钮）
                NSInteger index = row * kColCount + col;
                
                // 2. 创建按钮
                // 1) 实例化
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                // 2) 设置位置，自定义视图中没有使用AutoLayout，因此，可以使用setFrame
                NSInteger x = kStartPoint.x + col * kButtonSize.width;
                NSInteger y = kStartPoint.y + row * kButtonSize.height;
                
                [button setFrame:CGRectMake(x, y, kButtonSize.width, kButtonSize.height)];
                
                //                // 3) 设置按钮文字
                //                NSString *string = [self emoteStringWithIndex:index];
                //                [button setTitle:string forState:UIControlStateNormal];
                
                // 4) 添加按钮监听方法
                button.tag = index;
                [button addTarget:self action:@selector(clickEmote:) forControlEvents:UIControlEventTouchUpInside];
                
                // 5) 添加到视图
                [self addSubview:button];
                
                // 6) 添加到临时数组
                [array addObject:button];
            }
        }
        
        // 遍历临时数组，设置按钮内容
        for (UIButton *button in array) {
            if (button.tag == 27) {
                // 最末尾的删除按钮，设置按钮图像
                UIImage *img = [UIImage imageNamed:@"DeleteEmoticonBtn"];
                UIImage *imgHL = [UIImage imageNamed:@"DeleteEmoticonBtnHL"];
                
                [button setImage:img forState:UIControlStateNormal];
                [button setImage:imgHL forState:UIControlStateHighlighted];
//                [button setAllStateBackgroundImageWithImageName:@"DeleteEmoticonBtn"];
            } else {
                // 设置其他按钮的文字
                NSString *string = [self emoteStringWithIndex:button.tag];
                [button setTitle:string forState:UIControlStateNormal];
            }
        }
    }
    
    return self;
}
#pragma mark -根据表情按钮的索引返回上面显示的unichar字符串，即表情文字
- (NSString *)emoteStringWithIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"%C", emotechars[index]];
}

#pragma mark -点击表情图标
- (void)clickEmote:(UIButton *)sender
{
    if (sender.tag <= 26) {
        NSString *text = [self emoteStringWithIndex:sender.tag];
        if (_clickEmojiBlock) {
            _clickEmojiBlock(text);
        }
        
    }else{
        if (_clickDeleteBtnBlock) {
            _clickDeleteBtnBlock();
        }
    }
    
}


@end
