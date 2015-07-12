//
//  MainframeViewController.m
//  IM
//
//  Created by Chan on 15/1/19.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "MainframeViewController.h"
#import "RecentMsgModel.h"
#import "ChatViewController.h"
#import "RecentMsgTableViewCell.h"

@interface MainframeViewController ()<NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSFetchedResultsController *_fetchedResultControler;
    NSFetchedResultsController *_fetchedController;
    NSManagedObjectContext *_context;
    NSArray *_recentMsgArray;
    NSArray *_bareArray;
}
@property (weak, nonatomic) IBOutlet UITableView *recentMsgTableView;

@end

@implementation MainframeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //regeist notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRecentMsg) name:@"RefreshRecentMsg" object:nil];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //实例化NSManagedObjectContext对象
    _context = appDelegate.rosterStorage.mainThreadManagedObjectContext;
    //实例化NSFetchRequest对象
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //实例化排序
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
    request.sortDescriptors = @[sort1, sort2];
    //实例化NSFetchedResultsController
    _fetchedController = [[NSFetchedResultsController  alloc] initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:@"sectionNum" cacheName:nil];
//    _fetchedController.delegate = self;
    NSError *error = nil;
    //执行查询请求，结果保存在_fetchedController中
    [_fetchedController performFetch:&error];
    if (error) {
        IMLog(@"error------>%@",[error localizedDescription]);
    }
    
    //    [_fetchedController addObserver:self forKeyPath:@"" options:NSKeyValueObservingOptionNew context:nil];
    [self initBareArray];
//    [self setupFetchedController];
    [self loadCellModel];
    

    

}


- (void)refreshRecentMsg
{
    for (NSInteger i = 0; i < 3; i++) {
        [self loadCellModel];
    }
    
    [_recentMsgTableView reloadData];
}
- (void)initBareArray
{
    NSMutableArray *bareArray = [NSMutableArray array];
    for (NSInteger i = 0; i < _fetchedController.sections.count; i++) {

        id<NSFetchedResultsSectionInfo> sectionInfo = _fetchedController.sections[i];
        NSArray *objs = [sectionInfo objects];
       
        for (NSInteger i = 0; i < objs.count; i++) {
            //查询结果对象实例
            XMPPUserCoreDataStorageObject *user = objs[i];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:user.nickname forKey:@"NickName"];
            [dict setObject:user.jid.bare forKey:@"BareJidStr"];
            [bareArray addObject:dict];
        }
       
    }
   [ReadWriteUtil saveToNSDefaultsWithObject:bareArray forKey:@"UserJidArray"];
    _bareArray = bareArray;
   
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark -加载CellFrameModel数据
- (void)loadCellModel
{
    NSMutableArray *msgArrary = [NSMutableArray arrayWithCapacity:_bareArray.count];
    for (NSInteger i = 0; i < _bareArray.count; i++) {
        NSDictionary *dict = _bareArray[i];
        [self setupFetchedControllerWithBareJidStr:dict[@"BareJidStr"]];
        XMPPMessageArchiving_Message_CoreDataObject *obj = [_fetchedResultControler.fetchedObjects lastObject];
        RecentMsgModel *msgModel = [[RecentMsgModel alloc] initWithXMPPMessageArchivingMessageCoreDataObject:obj];
        msgModel.nickname = dict[@"NickName"];
        [msgArrary addObject:msgModel];
    }
    _recentMsgArray = msgArrary;
}

- (void)setupFetchedControllerWithBareJidStr:(NSString *)bareJidStr
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.msgArchivingCoreDataStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSSortDescriptor *des = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[des];
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr CONTAINS[cd] %@ AND streamBareJidStr CONTAINS[cd] %@", bareJidStr, [UserModel sharedUserModel].jid];
    _fetchedResultControler = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultControler.delegate = self;
    NSError *error = nil;
    if (![_fetchedResultControler performFetch:&error]) {
        IMLog(@"%@",[error localizedDescription]);
        return;
    }

}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
}
#pragma mark -tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _recentMsgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellID = @"MainFrameCell";
    RecentMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseId];
    if (cell == nil) {
        cell = [RecentMsgTableViewCell recentMsgTableViewCell];
    }
    //查询结果对象实例
    // 设置单元格
//    XMPPUserCoreDataStorageObject *user = [_fetchedController objectAtIndexPath:indexPath];
    
//    cell.textLabel.text = user.displayName;
    RecentMsgModel *msgModel = _recentMsgArray[indexPath.row];
    cell.msgModel = msgModel;
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    RecentMsgModel *msgModel = _recentMsgArray[indexPath.row];
    chatVC.bareJidStr = msgModel.bareJidStr;
    chatVC.title = msgModel.nickname;
    [self.navigationController pushViewController:chatVC animated:YES];
    
}
@end
