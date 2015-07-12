//
//  RoomModelHandler.h
//  IM
//
//  Created by chan on 15/5/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomModelHandler : NSObject
+ (NSArray *)handleQueryXMLString:(NSString *)queryXml;
@end
