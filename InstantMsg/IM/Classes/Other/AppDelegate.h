//
//  AppDelegate.h
//  InstantMessage
//
//  Created by Chan on 15/1/7.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

typedef void(^ConnectionBlock)(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;//xmpp流

@property (nonatomic, strong, readonly) XMPPvCardTempModule  *vCardModule;//电子名片模块

@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *rosterStorage;//花名册存储模块

@property (nonatomic, strong, readonly) XMPPRoster *roster;

@property (nonatomic, strong, readonly) XMPPRoom *room;
@property (nonatomic, strong, readonly) XMPPRoomCoreDataStorage *roomStorage;
@property (nonatomic, strong, readonly) XMPPMUC *muc;

/**
 *  全局的XMPPvCardAvatar模块，只读属性
 */
@property (strong, nonatomic, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;

@property (nonatomic, strong, readonly) XMPPMessageArchiving *msgArchiving;
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *msgArchivingCoreDataStorage;
/**
 *  连接xmpp服务器
 *
 *  @param success 成功block
 *  @param failure 失败block
 */
- (void)connectionWithXmppServerSuccess:(ConnectionBlock) success failure:(ConnectionBlock) failure;

- (void)changeRootViewController;
@end

