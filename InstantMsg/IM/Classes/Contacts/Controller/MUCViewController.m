//
//  MUCViewController.m
//  IM
//
//  Created by chan on 15/5/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "MUCViewController.h"
#import "AppDelegate.h"


@interface MUCViewController ()<NSFetchedResultsControllerDelegate  >
{
    NSManagedObjectContext *_context;
    NSFetchedResultsController *_fetchedController;
}


@end

@implementation MUCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    XMPPMUC *muc = appDelegate.muc;
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    _context = appDelegate.roomStorage.mainThreadManagedObjectContext;
    //实例化NSFetchRequest对象
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPRoomCoreDataStorageObject"];
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

    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
