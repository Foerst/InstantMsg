//
//  User.h
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
@interface UserModel : NSObject
single_interface(UserModel)

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *password;
@property (nonatomic, copy) NSString * jid;
@property (nonatomic, strong) XMPPJID *xmppJID;

@end
