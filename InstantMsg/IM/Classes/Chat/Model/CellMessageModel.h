//
//  CellMessage.h
//  IM
//
//  Created by Chan on 15/2/10.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
@interface CellMessageModel : NSObject
@property (nonatomic, strong) NSData   *imgData;
@property (nonatomic, copy)   NSString *body;
@property (nonatomic, copy)   NSString *timestamp;
@property (nonatomic, assign) Boolean isOutgoing;
@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, strong) NSURL *remoteURL;
@property (nonatomic, strong) XMPPMessageArchiving_Message_CoreDataObject *obj;

- (instancetype)initWithXMPPMessageArchivingMessageCoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)obj;
@end
