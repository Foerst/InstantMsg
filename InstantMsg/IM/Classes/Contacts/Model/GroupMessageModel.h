//
//  GroupMessageModel.h
//  IM
//
//  Created by chan on 15/5/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//


#import "XMPPRoomMessageCoreDataStorageObject.h"


//static NSArray *membreList;

@interface GroupMessageModel : NSObject

@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, strong) UIImage *avator;

@property (nonatomic, retain) XMPPMessage * message;  // Transient (proper type, not on disk)
@property (nonatomic, retain) NSString * messageStr;  // Shadow (binary data, written to disk)

@property (nonatomic, strong) XMPPJID * roomJID;      // Transient (proper type, not on disk)
@property (nonatomic, strong) NSString * roomJIDStr;  // Shadow (binary data, written to disk)

@property (nonatomic, retain) XMPPJID * jid;          // Transient (proper type, not on disk)
@property (nonatomic, retain) NSString * jidStr;      // Shadow (binary data, written to disk)

@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * body;

@property (nonatomic, retain) NSDate * localTimestamp;
@property (nonatomic, strong) NSDate * remoteTimestamp;

@property (nonatomic, assign) BOOL isFromMe;
@property (nonatomic, strong) NSNumber * fromMe;
@property (nonatomic, strong) NSArray *membreList;

@property (nonatomic, strong) XMPPRoomMessageCoreDataStorageObject *obj;
- (instancetype)initWithXMPPRoomMessageCoreDataStorageObject:(XMPPRoomMessageCoreDataStorageObject *)obj;
@end
