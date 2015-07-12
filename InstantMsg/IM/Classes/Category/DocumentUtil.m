//
//  DocumentUitl.m
//  IM
//
//  Created by Chan on 15/2/5.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "DocumentUtil.h"

@implementation DocumentUtil
+ (void)findMainBundlePath;
{
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"shot.png" ofType:nil];
    NSString *path2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSLog(@"%@",path1);
}
@end
