//
//  GroupChatViewController.m
//  IM
//
//  Created by chan on 15/5/14.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "GroupChatViewController.h"
#import "AppDelegate.h"
#import "ChatToolBar.h"
#import "RoomModel.h"
#import "XMPPRoomMessageCoreDataStorageObject.h"
#import "GroupCellFrameModel.h"
#import "GroupMessageModel.h"
#import "GroupChatTableViewCell.h"
#import "MemberListModel.h"
#import "UserModel.h"
#import "XMPPvCardTemp.h"

@interface GroupChatViewController ()<XMPPRoomStorage, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, ChatToolBarDelegate, NSFetchedResultsControllerDelegate>
{
    XMPPRoom *_xmppRoom;
    UITableView *_chatView;
    ChatToolBar *_toolBar;
    NSArray * _cellFrameArray;
    NSFetchedResultsController *_fetchedResultControler;
//    NSMutableArray *_dataArray;
    NSMutableArray *_memberList;
    NSManagedObjectContext *_context;
}

@end

@implementation GroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _dataArray = [NSMutableArray array];
    _memberList = [NSMutableArray array];
    // Do any additional setup after loading the view from its nib.
    //初始化聊天室
    AppDelegate *appDelegate =[UIApplication sharedApplication].delegate;
    XMPPJID *roomJID = [XMPPJID jidWithString:_roomModel.roomJid];

    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:appDelegate.roomStorage jid:roomJID];
   
    XMPPStream *xmppStream = appDelegate.xmppStream;
    [_xmppRoom activate:xmppStream];
  
    XMPPvCardTemp * vCard = appDelegate.vCardModule.myvCardTemp;
    if (vCard.jid == nil) {
        
        vCard.jid = appDelegate.xmppStream.myJID;
        [appDelegate.vCardModule updateMyvCardTemp:vCard];
    }
    [_xmppRoom joinRoomUsingNickname:vCard.nickname history:nil];
    
    [_xmppRoom fetchConfigurationForm];
  
    [_xmppRoom configureRoomUsingOptions:nil];
    [_xmppRoom fetchMembersList];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    self.view.backgroundColor = [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0];
    

    //添加对话视图
    [self addChatView];

    //添加工具栏
    [self addChatToolBar];
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self setupFetchedController];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [self refreshChatViewAndScrollToLastRecord];
}
- (void)dealloc
{
    _fetchedResultControler = nil;
    [_xmppRoom leaveRoom];
}
#pragma mark -添加消息展示页面
- (void)addChatView
{
    UITableView *chatView = [[UITableView alloc] init];
    //    chatView.separatorColor = [UIColor clearColor];
    chatView.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉分割线
    //    chatView.separatorInset = UIEdgeInsetsZero;
    chatView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kChatToolBarHeight);
    [self.view addSubview:chatView];
    _chatView = chatView;
    _chatView.showsVerticalScrollIndicator = YES;
    //    _chatView.backgroundView = nil;
    _chatView.backgroundColor = [UIColor clearColor];
    _chatView.opaque = YES;
    
    chatView.delegate = self;
    chatView.dataSource = self;
    //点击tableview 关闭键盘
    UITapGestureRecognizer *tapReg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapReg.delegate = self;
    [chatView addGestureRecognizer:tapReg];
    chatView.delegate = self;
    
}

- (NSString *)persistentStoreDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    // Attempt to find a name for this application
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (appName == nil) {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    if (appName == nil) {
        appName = @"xmppframework";
    }
    
    
    NSString *result = [basePath stringByAppendingPathComponent:appName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:result])
    {
        [fileManager createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return result;
}
#pragma mark -加载CellFrameModel数据
- (void)setupFetchedController
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    _context = appDelegate.roomStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPRoomMessageCoreDataStorageObject"];
    NSSortDescriptor *des = [NSSortDescriptor sortDescriptorWithKey:@"localTimestamp" ascending:YES];
    request.sortDescriptors = @[des];
    request.predicate = [NSPredicate predicateWithFormat:@"roomJIDStr = %@", _roomModel.roomJid];
//    NSArray *objs = [context executeFetchRequest:request error:nil];
    _fetchedResultControler = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultControler.delegate = self;
    NSError *error = nil;
    if (![_fetchedResultControler performFetch:&error]) {
        IMLog(@"%@",[error localizedDescription]);
        return;
    }
//
//    IMLog(@"哈哈");
//    [self loadCellFrameModels];
//    
//    // 从应用程序包中加载模型文件
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"XMPPRoom" withExtension:@"momd"];
////    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];;
//    // 传入模型对象，初始化NSPersistentStoreCoordinator
//    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
//    // 构建SQLite数据库文件的路径
////    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *docsPath = [self persistentStoreDirectory];
//    NSString *storePath = [docsPath stringByAppendingPathComponent:@"roomName.db"];
//    NSURL *url = [NSURL fileURLWithPath:storePath];
//    // 添加持久化存储库，这里使用SQLite作为存储库
//    NSError *error = nil;
//    NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:@{ NSMigratePersistentStoresAutomaticallyOption: @(YES),
//        NSInferMappingModelAutomaticallyOption : @(YES) } error:&error];
//    if (store == nil) { // 直接抛异常
//        [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];
//    }
//    // 初始化上下文，设置persistentStoreCoordinator属性
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
//    context.persistentStoreCoordinator = psc;
//    // 用完之后，记得要[context release];
    
//    // 初始化一个查询请求
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    // 设置要查询的实体
//    request.entity = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject" inManagedObjectContext:aapContext];
//    // 设置排序（按照age降序）
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"localTimestamp" ascending:YES];
//    request.sortDescriptors = [NSArray arrayWithObject:sort];
//    // 设置条件过滤(搜索name中包含字符串"Itcast-1"的记录，注意：设置条件过滤时，数据库SQL语句中的%要用*来代替，所以%Itcast-1%应该写成*Itcast-1*)
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomJIDStr like %@", _roomModel.roomJid];
//    request.predicate = predicate;
//    // 执行请求
//    NSError *error1 = nil;
//    NSArray *objs = [aapContext executeFetchRequest:request error:&error1];
//    if (error1) {
//        [NSException raise:@"查询错误" format:@"%@", [error1 localizedDescription]];
//    }
//    // 遍历数据
//    for (NSManagedObject *obj in objs) {
//        NSLog(@"name=%@", [obj valueForKey:@"body"]);
//    }
//    _fetchedResultControler = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:@"roomMessageCache"];
//        _fetchedResultControler.delegate = self;
//        NSError *error2 = nil;
//        if (![_fetchedResultControler performFetch:&error2]) {
//            IMLog(@"%@",[error2 localizedDescription]);
//            return;
//        }
    
    
    
}

#pragma mark -加载CellFrameModel数据
- (void)loadCellFrameModels
{
    
//    NSArray *membreList = [ReadWriteUtil getObjectForKey:@"MemberList"];
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:_fetchedResultControler.fetchedObjects.count];
    for (XMPPRoomMessageCoreDataStorageObject *obj in _fetchedResultControler.fetchedObjects) {
        
        GroupMessageModel *msg = [[GroupMessageModel alloc] initWithXMPPRoomMessageCoreDataStorageObject:obj];
        if (_memberList) {
            msg.membreList = _memberList;
        }
        GroupCellFrameModel *frame = [[GroupCellFrameModel alloc] init];
        
        frame.cellMsg = msg;
        [frames addObject:frame];
        
    }
    _cellFrameArray  = frames;
   
}
static int count = 0;
- (void)refreshChatViewAndScrollToLastRecord
{
    IMLog(@"count === %i",++count);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadCellFrameModels];
        [_chatView reloadData];
        [self scrollToLastRecord:_chatView];
    });

}
#pragma mark -键盘即将打开或消失时调用
- (void)keyboardWillChangeFrame:(NSNotification *)notif
{
    NSDictionary *userInfo = notif.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];//根据UIKeyboardFrameEndUserInfoKey可知道keyFrame是键盘frame停止改变时的frame
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height;
    //    CGAffineTransformMakeTranslation每次都是以最初位置的中心点为起始参照
    //
    //    CGAffineTransformTranslate每次都是以传入的transform为起始参照
    //
    //    CGAffineTransformIdentity为最初状态，即最初位置的中心点
    
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, moveY);
    }];
    
    
}

#pragma mark -关闭键盘
- (void)dismissKeyBoard
{
    [_toolBar hideKeyBoard];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -滚动到最后一条
- (void)scrollToLastRecord:(UITableView *)tableview
{
    NSInteger row = _cellFrameArray.count - 1;
    if (row > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    }
    
}

#pragma mark -添加聊天工具条
- (void)addChatToolBar
{
    ChatToolBar *toolBar = [[ChatToolBar alloc] init];
    
    toolBar.delegate = self;
    toolBar.frame = CGRectMake(0, kScreenHeight - kChatToolBarHeight, kScreenWidth, kChatToolBarHeight);
    [self.view addSubview:toolBar];
    _toolBar = toolBar;
//    __weak typeof(self) pSelf = self;
    __weak XMPPRoom *room = _xmppRoom;
    _toolBar.textFieldShouldReturnBlock =^(NSString *msg){
//        [pSelf sendMessage:msg type:@"groupchat"];
        [room sendMessageWithBody:msg];
    };
    //点击ShareMoreView中的按钮调用
//    __weak typeof(self) *chatVC = self;
//    _toolBar.shareBlock = ^(int tag){
//        [chatVC shareMoreWithTag:tag];
//    };
}

#pragma mark -XMPPRoomStorage protocol
- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}

/**
 * Updates and returns the occupant for the given presence element.
 * If the presence type is "available", and the occupant doesn't already exist, then one should be created.
 **/
- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room
{
    
}

/**
 * Stores or otherwise handles the given message element.
 **/
- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
    
}
- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
    
}

/**
 * Handles leaving the room, which generally means clearing the list of occupants.
 **/
- (void)handleDidLeaveRoom:(XMPPRoom *)room
{
    
}

/**
 * May be used if there's anything special to do when joining a room.
 **/
- (void)handleDidJoinRoom:(XMPPRoom *)room withNickname:(NSString *)nickname
{
    
}

#pragma mark -XMPPRoomDelegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    IMLog(@"聊天室创建成功");
}

/**
 * Invoked with the results of a request to fetch the configuration form.
 * The given config form will look something like:
 *
 * <x xmlns='jabber:x:data' type='form'>
 *   <title>Configuration for MUC Room</title>
 *   <field type='hidden'
 *           var='FORM_TYPE'>
 *     <value>http://jabber.org/protocol/muc#roomconfig</value>
 *   </field>
 *   <field label='Natural-Language Room Name'
 *           type='text-single'
 *            var='muc#roomconfig_roomname'/>
 *   <field label='Enable Public Logging?'
 *           type='boolean'
 *            var='muc#roomconfig_enablelogging'>
 *     <value>0</value>
 *   </field>
 *   ...
 * </x>
 *
 * The form is to be filled out and then submitted via the configureRoomUsingOptions: method.
 *
 * @see fetchConfigurationForm:
 * @see configureRoomUsingOptions:
 **/
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    

    
}

- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    
}
- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}

/**
 * Invoked when a message is received.
 * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
 **/
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{

//    NSMutableArray *tmpArray = [NSMutableArray array];
//    [tmpArray addObject:message.body];
//    GroupMessageModel *msgModel = [[GroupMessageModel alloc] init];
//    msgModel.message = message;
//    msgModel.messageStr = message.body;
//    msgModel.localTimestamp = message
    
//    GroupCellFrameModel *cellFrame = [[GroupCellFrameModel alloc] init];
//    cellFrame.cellMsg = msgModel;
//    [_dataArray addObject:message.body];
    
//    dispatch_block_t block = ^{
//        [_chatView reloadData];
//        [self scrollToLastRecord:_chatView];
//        
//    };
//    dispatch_async(dispatch_get_main_queue(), block);
    
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    for (DDXMLElement *ele in items) {
        MemberListModel *model = [[MemberListModel alloc] init];
        model.element = ele;
        [_memberList addObject:model];
    }

//    [ReadWriteUtil saveToNSDefaultsWithObject:_memberList forKey:@"MemberList"];
    
    [self refreshChatViewAndScrollToLastRecord];
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult
{
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError
{
    
}

#pragma mark -tableview datasource
-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellFrameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"ChatRoomCell";
    GroupChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[GroupChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    //查询结果对象实例
    // 设置单元格
//    RoomModel *roomModel = _groupsNameArray[indexPath.row];
//    cell.textLabel.text = _dataArray[indexPath.row];
//    cell.imageView.image = [UIImage imageNamed:@"avator0"];
//    cell.imageView.layer.masksToBounds = YES;
//    cell.imageView.layer.cornerRadius = 30.0f;
    GroupCellFrameModel *cellFrame = _cellFrameArray[indexPath.row];
    cell.cellFrame = cellFrame;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCellFrameModel *cellFrame = _cellFrameArray[indexPath.row];
    return cellFrame.cellHeight;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    GroupChatViewController *groupChatVC = [[GroupChatViewController alloc] init];
//    RoomModel *roomModel = _groupsNameArray[indexPath.row];
//    
//    groupChatVC.title = roomModel.roomName;
//    groupChatVC.roomModel = roomModel;
//    [self.navigationController pushViewController:groupChatVC animated:YES];
//    
//    
//}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    [self refreshChatViewAndScrollToLastRecord];
    
}


@end
