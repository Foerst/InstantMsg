//
//  AppDelegate.m
//  InstantMessage
//
//  Created by Chan on 15/1/7.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "ProgressHUD.h"
#import "RoomModelHandler.h"
#import "WelcomeViewController.h"

@interface AppDelegate ()<XMPPStreamDelegate, XMPPRoomStorage, XMPPMUCDelegate>
{
    NSString                    *_password;//记录密码
    ConnectionBlock             _success;//记录成功block
    ConnectionBlock             _failure;//记录失败block
    XMPPReconnect               *_reconnet;//自动重连模块
    XMPPvCardTemp               *_vCard;
    XMPPvCardCoreDataStorage    *_vCardStorage;
    XMPPCapabilities            *_xmppCapabilities;     // 实体扩展模块
    XMPPCapabilitiesCoreDataStorage *_xmppCapabilitiesCoreDataStorage; // 数据存储模块
    NSMutableArray              *_socketLists;

    
}
/**
 *  开始发送连接服务器的请求
 */
- (void)connect;
/**
 *  取消连接xmpp服务器
 */
- (void)disconnect;
@end

@implementation AppDelegate

#pragma mark -初始化xmppstream ,且只初始化一次
- (void)setupStream
{
//    NSAssert(_xmppStream == nil, @"又初始化了一次");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_xmppStream == nil) {
           
            _xmppStream = [[XMPPStream alloc] init];
            
            // 让XMPP在真机运行时支持后台，在模拟器上是不支持后台服务运行的
#if !TARGET_IPHONE_SIMULATOR
            {
                // 允许XMPPStream在真机运行时，支持后台网络通讯！
                [_xmppStream setEnableBackgroundingOnSocket:YES];
            }
#endif
            //添加自动重连模块
            _reconnet = [[XMPPReconnect alloc] init];
            [_reconnet activate:_xmppStream];
            //添加电子名片模块
            _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
            _vCardModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
            [_vCardModule activate:_xmppStream];
            //添加花名册模块
            _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
            _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
            [_roster activate:_xmppStream];
            // 设置自动接收好友订阅请求
            _roster.autoAcceptKnownPresenceSubscriptionRequests = YES;
            //自动更新花名册
            _roster.autoFetchRoster = YES;
            //设置代理
            [_roster addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            //添加电子名片模块
            _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCardModule];
            [_xmppvCardAvatarModule activate:_xmppStream];
          

           
            // 实体扩展模块
            _xmppCapabilitiesCoreDataStorage = [[XMPPCapabilitiesCoreDataStorage alloc] init];
            _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesCoreDataStorage];
            [_xmppCapabilities activate:_xmppStream];

            //消息记录
            _msgArchivingCoreDataStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
            _msgArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgArchivingCoreDataStorage];
            [_msgArchiving activate:_xmppStream];
            
            [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

        }
    });
//
}


#pragma mark -xmpproom delegate
//创建聊天室成功
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    IMLog(@"//创建聊天室成功");
}
- (void)teardownStream
{

    [_xmppStream removeDelegate:self];
    [_roster removeDelegate:self];
    [_vCardModule deactivate];
    [_reconnet deactivate];
    _reconnet = nil;
    _vCardModule =nil;
    _xmppStream = nil;
    _roster = nil;
   
}
#pragma mark -上线
- (void)goOnline
{
    
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}
#pragma mark -下线
- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}

#pragma mark -发送连接服务器的请求
- (void)connect
{
    [self setupStream];
    UserModel *user = [UserModel sharedUserModel];
  
//    NSString *clientName = [NSString stringWithUTF8String:[kAppType UTF8String]];
    XMPPJID *jid = [XMPPJID jidWithString:[user.username stringByAppendingFormat:@"@%@",user.server] resource:kAppResource];
    [_xmppStream setMyJID: jid];
    _xmppStream.hostName = user.server;
    _password = user.password;
    
    //连接之前先判断是否已经连接，否则会报“Attempting to connect while already connected or connecting.”错误
    if (_xmppStream.isConnected){
        return;
        
    }
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        if (_failure) {
             _failure();
        }
       
        IMLog(@"%@",error.localizedDescription);
    }
}
#pragma mark -取消连接服务器
- (void)disconnect
{
    // 1. 发送离线状态
    [self goOffline];
    // 2. XMPPStream断开连接
    [_xmppStream disconnect];

}
#pragma mark -外部调用接口
- (void)connectionWithXmppServerSuccess:(ConnectionBlock)success failure:(ConnectionBlock)failure
{
    [ProgressHUD show:nil];
    _success = success;
    _failure = failure;
    
    [self connect];
}

#pragma mark XmppStreamDelegate代理方法
#pragma mark -发送长连接请求之后连接到服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    // 1. 验证密码
    NSError *error = nil;
    [_xmppStream authenticateWithPassword:_password error:&error];
    if (error) {
        if (_failure) {
            _failure();
        }
        IMLog(@"xmppStreamDidConnect：%ld",(long)error.code);
        
    }

}

#pragma mark -通过验证
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{

    [self goOnline];
    if (_success) {
        _success();
    }
}
#pragma mark 未通过验证
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    IMLog(@"xmppStream:didNotAuthenticate:%@", error);
    if (_failure) {
        _failure();
    }
}

#pragma mark -接收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if ([message.type isEqualToString:@"groupchat"]) {
        IMLog(@"groupmessage---------->%@",message.description);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentMsg" object:nil];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentMsg" object:nil];
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        // 设置时区
        
        notification.timeZone = [NSTimeZone defaultTimeZone];
        
        // 设置重复间隔
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.5f];
        notification.fireDate = fireDate;
        
        notification.repeatInterval = kCFCalendarUnitDay;
        
        // 推送声音
        
        notification.soundName = UILocalNotificationDefaultSoundName;
        //显示在icon上的红色圈中的数子
        
        notification.applicationIconBadgeNumber = 1;
        
        //设置userinfo 方便在之后需要撤销的时候使用
        
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"value"forKey:@"key"];
        
        notification.userInfo = info;
        
        
        notification.alertBody = [NSString stringWithFormat:@"%@\n%@",message.from.bare,message.body];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];

    });
    

}
#pragma mark -发送了消息
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    IMLog(@"didSendMessage--->%@",message.description);
}
#pragma  mark -接收到出席
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    
    IMLog(@"didReceivePresence----->%@",presence.description);
    NSString *presenceType = presence.type;
    if ([presenceType isEqualToString:@"available"]) {
        
    }
    
}

#pragma  mark -发送出席
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    IMLog(@"didSendPresence----->%@",presence.description);
}
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    IMLog(@"didSendIQ------->%@",iq);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    IMLog(@"didReceiveIQ------->%@",iq);
    if ([self isConferenceRequest:iq]) {
        NSArray *dataArray = [RoomModelHandler handleQueryXMLString:iq.description];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshGroupsNotification" object:dataArray];
    }
    // 0. 判断IQ是否为SI请求
    if ([self isSIRequest:iq]) {
        TURNSocket *socket = [[TURNSocket alloc] initWithStream:_xmppStream toJID:iq.to];
        
        [_socketLists addObject:socket];
        
        [socket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    } else if ([TURNSocket isNewStartTURNRequest:iq]) {
        // 1. 判断iq的类型是否为新的文件传输请求
        // 1) 实例化socket
        TURNSocket *socket = [[TURNSocket alloc] initWithStream:sender incomingTURNRequest:iq];
        
        // 2) 使用一个数组成员记录住所有传输文件使用的socket
        [_socketLists addObject:socket];
        
        // 3）添加代理
        [socket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return YES;

}

//#pragma mark 判断IQ是否为SI请求
- (BOOL)isSIRequest:(XMPPIQ *)iq
{
    NSXMLElement *si = [iq elementForName:@"si" xmlns:@"http://jabber.org/protocol/si"];
    NSString *uuid = [[si attributeForName:@"id"]stringValue];
    
    if(si &&uuid ){
        return YES;
    }
    
    return NO;
}

- (BOOL)isConferenceRequest:(XMPPIQ *)iq
{
    //id="disco2"
    NSXMLElement *si = [iq elementForName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSString *uuid = [[iq attributeForName:@"id"]stringValue];
    
    if(si && [uuid isEqualToString:@"disco2"] ){
        return YES;
    }
    
    return NO;
}
//#pragma mark - TURNSocket代理
//- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket
//{
//    NSLog(@"成功");
//    
//    // 保存或者发送文件
//    // 写数据方法，向其他客户端发送文件
//    //    socket writeData:<#(NSData *)#> withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>
//    // 读数据方法，接收来自其他客户端的文件
//    //    socket readDataToData:<#(NSData *)#> withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>
//    
//    // 读写操作完成之后断开网络连接
//    [socket disconnectAfterReadingAndWriting];
//    
//    [_socketLists removeObject:sender];
//}
//
//- (void)turnSocketDidFail:(TURNSocket *)sender
//{
//    NSLog(@"失败");
//    
//    [_socketLists removeObject:sender];
//}
#pragma mark -激活聊天室模块
- (void)activeXMPPRoomModule
{
    //聊天室模块
    XMPPRoomCoreDataStorage *roomStorage = [[XMPPRoomCoreDataStorage alloc] initWithDatabaseFilename:@"roomName.db" storeOptions:nil];
    _roomStorage = roomStorage;

//    _room = [[XMPPRoom alloc] initWithRoomStorage:roomStorage jid:_xmppStream.myJID dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
//    [_room addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
//    [_room activate:_xmppStream];
    _muc = [[XMPPMUC alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [_muc activate:_xmppStream];

    [_muc addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}
#pragma mark 切换根试图控制器
- (void)changeRootViewController
{
    [self activeXMPPRoomModule];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [mainBoard instantiateInitialViewController];
    });
    
}
#pragma mark AppDelegate方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //    self.window.rootViewController = [[LoginViewController alloc] init];
    //    self.window.backgroundColor = [UIColor redColor];
    //    [self.window makeKeyAndVisible];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 本地通知在ios8上需要先注册再使用。
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
        {

            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
            
        }
//#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
//        if (IS_OS_8_OR_LATER) {
//            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
//                                                    (UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
//            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//        } else {
//
//        }

        
    });

    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
   

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 断开连接
//    [self disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // 连接
//    [self connect];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iWeibo" message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
//    // 图标上的数字减1
//    application.applicationIconBadgeNumber -= 1;
//    
//    
//    //第三步：解除本地推送
//    // 获得 UIApplication
//    UIApplication *app = [UIApplication sharedApplication];
//    //获取本地推送数组
//    NSArray *localArray = [app scheduledLocalNotifications];
//    //声明本地通知对象
//    UILocalNotification *localNotification;
//    if (localArray) {
//        for (UILocalNotification *noti in localArray) {
//            NSDictionary *dict = noti.userInfo;
//            if (dict) {
//                NSString *inKey = [dict objectForKey:@"key"];
//                if ([inKey isEqualToString:@"value"]) {
//                    if (localNotification){
//                        
//                        localNotification = nil;
//                    }
//                    break;
//                }
//            }
//        }
//        
//        //判断是否找到已经存在的相同key的推送
//        if (!localNotification) {
//            //不存在初始化
//            localNotification = [[UILocalNotification alloc] init];
//        }
//        
//        if (localNotification) {
//            //不推送 取消推送
//            [app cancelLocalNotification:localNotification];
//            
//            return;
//        }
//    }
}

//- (void)dealloc
//{
//    [self teardownStream];
//}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message
{

}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitationDecline:(XMPPMessage *)
message
{
    
}
@end
