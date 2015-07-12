//
//  RecentMsgModel.h
//  IM
//
//  Created by chan on 15/5/14.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentMsgModel : NSObject
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *bareJidStr;
@property (nonatomic, strong) UIImage *avatorImage;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy)   NSString *timestamp;

- (instancetype)initWithXMPPMessageArchivingMessageCoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)obj;
@end
