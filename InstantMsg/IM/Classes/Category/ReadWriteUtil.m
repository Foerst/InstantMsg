//
//  ReadWriteUtil.m
//  IM
//
//  Created by chan on 15/5/14.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "ReadWriteUtil.h"

@implementation ReadWriteUtil
+ (void)saveToNSDefaultsWithObject:(id)object forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];//立即写入
}

+ (id)getObjectForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}


@end
