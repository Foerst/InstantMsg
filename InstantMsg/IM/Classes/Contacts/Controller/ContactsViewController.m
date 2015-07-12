//
//  ContactsViewController.m
//  IM
//
//  Created by Chan on 15/1/19.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "ContactsViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "HeaderView.h"
#import "FriendGroupModel.h"
#import "ChatViewController.h"
#import "AddContactViewController.h"
#import "GroupsViewController.h"
#import "MUCViewController.h"


@interface ContactsViewController ()<NSFetchedResultsControllerDelegate, HeaderViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSFetchedResultsController *_fetchedController;
    NSManagedObjectContext *_context;
    NSArray *_friendGroups;
}
@property (weak, nonatomic) IBOutlet UITableView *contactsView;
- (IBAction)gotoGroups:(UISegmentedControl *)sender;

@end

@implementation ContactsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *addContacts = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact:)];
    self.navigationItem.rightBarButtonItem = addContacts;
//    self.navigationController.navigationItem.rightBarButtonItem = addContacts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.contactsView.sectionHeaderHeight = 30;
//    self.contactsView.rowHeight = 60;
//    self.contactsView.sectionFooterHeight = 0;
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
    _fetchedController.delegate = self;
    NSError *error = nil;
    //执行查询请求，结果保存在_fetchedController中
    [_fetchedController performFetch:&error];
    if (error) {
        IMLog(@"error------>%@",[error localizedDescription]);
    }
    
//    [_fetchedController addObserver:self forKeyPath:@"" options:NSKeyValueObservingOptionNew context:nil];
    [self initFriendGroups];
   

}

- (void)initFriendGroups
{
    NSMutableArray *groups = [NSMutableArray array];
    
    for (NSInteger i = 0; i < _fetchedController.sections.count; i++) {
        FriendGroupModel *fgroup = [[FriendGroupModel alloc] init];
        fgroup.sectionInfo = _fetchedController.sections[i];
        [groups addObject:fgroup];
    }
    _friendGroups = groups;
    
}
#pragma  mark -tableview datasource 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /* Returns an array of objects that implement the NSFetchedResultsSectionInfo protocol.
     It's expected that developers use the returned array when implementing the following methods of the UITableViewDataSource protocol*/

    return _friendGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    
    FriendGroupModel *group = _friendGroups[section];
    
    return group.isOpened? group.totalNum : 0;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"ContactsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
    }
    //查询结果对象实例
    // 设置单元格
    XMPPUserCoreDataStorageObject *user = [_fetchedController objectAtIndexPath:indexPath];
   
    cell.textLabel.text = user.displayName;
    cell.detailTextLabel.text = @"今天天气阳光明媚！";
    cell.imageView.image = [self loadUserImage:user];
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 30.0f;
    
    return cell;
}

#pragma mark 加载用户头像
- (UIImage *)loadUserImage:(XMPPUserCoreDataStorageObject *)user
{
    // 1. 判断user中是否包含头像，如果有，直接返回
    if (user.photo) {
        return user.photo;
    }
    
    // 2. 如果没有头像，从用户的头像模块中提取用户头像
    
    NSData *photoData = [[kAppDelegate xmppvCardAvatarModule] photoDataForJID:user.jid];
    
    if (photoData) {
        return [UIImage imageWithData:photoData];
    }
    
    return [UIImage imageNamed:@"DefaultProfileHead"];
}
#pragma mark -自定义HeaderView
- (HeaderView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString * const HeaderViewID = @"HeaderView";
    HeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewID];
    if (headerView == nil) {
        headerView = [[HeaderView alloc] initWithReuseIdentifier:HeaderViewID];
    }
    headerView.headerViewDelegate = self;
    headerView.friendGroup = _friendGroups[section];
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
#pragma mark -tableview delegate方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    //查询结果对象实例
    XMPPUserCoreDataStorageObject *user = [_fetchedController objectAtIndexPath:indexPath];
    
    chatVC.title = user.displayName;
   
    chatVC.bareJidStr = user.jid.bare;
    [self.navigationController pushViewController:chatVC animated:YES];
    
}

#pragma mark -NSFetchedResultsControllerDelegate方法
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //当查询结果发生变化上刷新表格
    [self initFriendGroups];
    [self.contactsView reloadData];
}

#pragma mark -HeaderViewDelegate方法
- (void)headerViewDidClick:(HeaderView *)header
{
    [self.contactsView reloadData];
}
#pragma mark -添加联系人
- (void)addContact:(UIBarButtonItem *)sender
{
    AddContactViewController *addVC = [[AddContactViewController alloc] init];
    addVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addVC animated:YES];
    
}
- (IBAction)gotoGroups:(UISegmentedControl *)sender {
    if (1 == sender.selectedSegmentIndex) {
        GroupsViewController *groupsVC = [[GroupsViewController alloc] init];
        groupsVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:groupsVC animated:YES];
        sender.selectedSegmentIndex = 0;
//        MUCViewController *mucVC = [[MUCViewController alloc] init];
//        mucVC.title = @"muc";
//        mucVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:mucVC animated:YES];
//        sender.selectedSegmentIndex = 0;
        
    }
}


@end
