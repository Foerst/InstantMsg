//
//  RecentMsgModel.m
//  IM
//
//  Created by chan on 15/5/14.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "RecentMsgModel.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"

@implementation RecentMsgModel

#pragma mark 加载用户头像
- (UIImage *)loadUserImage:(NSString *)jidStr
{
  //从用户的头像模块中提取用户头像
    
    NSData *photoData = [[kAppDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:jidStr]];
    
    if (photoData) {
        return [UIImage imageWithData:photoData];
    }
    
    return [UIImage imageNamed:@"DefaultProfileHead"];
}

- (instancetype)initWithXMPPMessageArchivingMessageCoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)obj
{
    if (self = [super init]) {
        _body = obj.body;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd"];
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [dateFormatter setTimeZone:timeZone];
        _timestamp = [dateFormatter stringFromDate:obj.timestamp];
        
        _avatorImage = [self loadUserImage:obj.bareJidStr];
        _bareJidStr = obj.bareJidStr;
    }
    return self;
}
@end
