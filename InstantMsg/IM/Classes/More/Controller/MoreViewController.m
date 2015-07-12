//
//  MoreViewController.m
//  IM
//
//  Created by Chan on 15/1/19.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "MoreViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "VCardViewController.h"

@interface MoreViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLb;
@property (weak, nonatomic) IBOutlet UILabel *jidLb;

@end

@implementation MoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    XMPPvCardTemp *vCard = [self getAppDelegate].vCardModule.myvCardTemp;
    if (vCard) {
        
        self.avatarImgView.image = [UIImage imageWithData:vCard.photo];
        self.nicknameLb.text = vCard.nickname;
        if (!vCard.jid) {
            IMLog(@"jid == nil");
            NSString *jidStr = [NSString stringWithFormat:@"%@@%@",[UserModel sharedUserModel].username,[UserModel sharedUserModel].server];
            vCard.jid = [XMPPJID jidWithString:jidStr];
        }
        [[self getAppDelegate].vCardModule updateMyvCardTemp:vCard];
        self.jidLb.text = vCard.jid.bare;
        
       
       
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AppDelegate *)getAppDelegate
{
    return [UIApplication sharedApplication].delegate;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (0 == indexPath.section) {
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        VCardViewController *vCardController = [mainSB instantiateViewControllerWithIdentifier:@"vCard"];
        vCardController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vCardController animated:YES];
//        self.tabBarController.tabBar.hidden = YES;
    }
}

@end
