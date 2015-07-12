//
//  ReadWriteUtil.h
//  IM
//
//  Created by chan on 15/5/14.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadWriteUtil : NSObject
+ (void)saveToNSDefaultsWithObject:(id)object forKey:(NSString *)key;
+ (id)getObjectForKey:(NSString *)key;
@end
