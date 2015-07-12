//
//  User.m
//  IM
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "UserModel.h"

#define kUserNameKey @"UserName"
#define kServerKey   @"Server"
#define kPasswordKey @"Password"
#define kJidKey      @"Jid"

@implementation UserModel
{
    NSString *_username;
    NSString *_server;
    NSString *_password;
    NSString *_jid;
}
single_implementation(UserModel)


- (void)setUsername:(NSString *)username
{
    _username = username;
    [_username saveToNSDefaultsWithKey:kUserNameKey];
}

- (NSString *)username
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserNameKey];
}

- (void)setServer:(NSString *)server
{
    _server = server;
    [_server saveToNSDefaultsWithKey:kServerKey];
}
- (NSString *)server
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kServerKey];
}
- (void)setPassword:(NSString *)password
{
    _password = password;
    [_password saveToNSDefaultsWithKey:kPasswordKey];
}
- (NSString *)password
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPasswordKey];
}

- (void)setJid:(NSString *)jid
{
    _jid = jid;
    [_jid saveToNSDefaultsWithKey:kJidKey];
}
- (NSString *)jid
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kJidKey];
}

- (XMPPJID *)xmppJID
{
    return [XMPPJID jidWithString:self.jid];
}
@end
