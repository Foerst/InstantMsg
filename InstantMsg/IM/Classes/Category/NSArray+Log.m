//
//  
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//
#import "NSArray+Log.h"

@implementation NSArray (Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [NSMutableString stringWithFormat:@"%ld (\n", self.count];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@", obj];

        if (idx < self.count - 1) {
            [strM appendString:@",\n"];
        }
    }];
    [strM appendString:@"\n)"];

    return strM;
}

@end
