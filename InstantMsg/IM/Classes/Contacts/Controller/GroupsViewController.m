//
//  GroupsViewController.m
//  IM
//
//  Created by chan on 15/5/14.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "GroupsViewController.h"
#import "GroupChatViewController.h"
#import "XMPP.h"
#import "RoomModel.h"

@interface GroupsViewController ()<UITableViewDataSource, UITableViewDelegate, XMPPRoomStorage>
{
    NSArray *_groupsNameArray;
 
}
@property (weak, nonatomic) IBOutlet UITableView *groupsTableView;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroups:) name:@"RefreshGroupsNotification" object:nil];
    // Do any additional setup after loading the view from its nib.
    self.title = @"群组";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加群组" style:UIBarButtonItemStylePlain target:self action:@selector(addGroup)];
    _groupsNameArray= @[];
    [self getAvaliableRooms];
}
- (void)refreshGroups:(NSNotification *)notif
{
    _groupsNameArray = notif.object;
    [_groupsTableView reloadData];
}
- (void)getAvaliableRooms
{
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"id" stringValue:@"disco2"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"to" stringValue:@"conference.chandemacbook-pro.local"];
    XMPPStream *xmppStream = [kAppDelegate xmppStream];
    NSString *jidStr = xmppStream.myJID.full;
    [iq addAttributeWithName:@"from" stringValue:jidStr];
    NSXMLElement *query= [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    
    [iq addChild:query];
    
    [xmppStream sendElement:iq];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addGroup
{
    
}

-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groupsNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"GroupsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
    }
    //查询结果对象实例
    // 设置单元格
    RoomModel *roomModel = _groupsNameArray[indexPath.row];
    cell.textLabel.text = roomModel.roomName;
    cell.detailTextLabel.text = roomModel.roomJid;
    cell.imageView.image = [UIImage imageNamed:@"avator0"];
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 30.0f;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupChatViewController *groupChatVC = [[GroupChatViewController alloc] init];
    RoomModel *roomModel = _groupsNameArray[indexPath.row];

    groupChatVC.title = roomModel.roomName;
    groupChatVC.roomModel = roomModel;
    [self.navigationController pushViewController:groupChatVC animated:YES];
    
   
}
@end
