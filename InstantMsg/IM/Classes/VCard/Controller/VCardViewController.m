//
//  VCardViewController.m
//  IM
//
//  Created by Chan on 15/1/19.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "VCardViewController.h"
#import "XMPPvCardTemp.h"
#import "AppDelegate.h"
#import "EditVCardViewController.h"

@interface VCardViewController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSArray *_titleArray;
}

@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;//头像
@property (weak, nonatomic) IBOutlet UILabel *nicknameLb;//昵称
@property (weak, nonatomic) IBOutlet UILabel *jibLb;//jid
@property (weak, nonatomic) IBOutlet UILabel *orgLb;//公司
@property (weak, nonatomic) IBOutlet UILabel *positionLb;//职位
@property (weak, nonatomic) IBOutlet UILabel *mobileLb;//手机号

@property (weak, nonatomic) IBOutlet UILabel *emailLb;//email

@property (nonatomic, strong) XMPPvCardTemp *vCard;
@end

@implementation VCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"电子名片";
    _titleArray = @[@[@"头像",@"昵称",@"jid"],
                    @[@"公司",@"职位",@"电话",@"email"]
                    ];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    self.vCard = appDelegate.vCardModule.myvCardTemp;
    if (self.vCard.jid == nil) {
        
        self.vCard.jid = appDelegate.xmppStream.myJID;
        [appDelegate.vCardModule updateMyvCardTemp:self.vCard];
    }
    [self.avatarBtn setBackgroundImage:[UIImage imageWithData:self.vCard.photo] forState:UIControlStateNormal];
    self.nicknameLb.text = self.vCard.nickname;
    self.jibLb.text = [self.vCard.jid bare];
    self.jibLb.textColor = [UIColor lightGrayColor];
    self.jibLb.font = [UIFont fontWithName:nil size:14];
    self.orgLb.text = self.vCard.orgName;
    self.positionLb.text = self.vCard.orgUnits[0];
    self.mobileLb.text = self.vCard.note;
    self.emailLb.text = self.vCard.mailer;
    
    
}
- (IBAction)selectAvatar:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"方式选择" delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:@"相机"otherButtonTitles:@"图库", nil];
    [sheet showInView:self.view];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"方式选择" message:@"msg" preferredStyle:UIAlertControllerStyleActionSheet];
//    [self presentViewController:alert animated:YES completion:nil];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    self.tabBarController.tabBar.hidden = NO;
//}
//#pragma mark 返回显示tabbar
//- (void)viewWillDisappear:(BOOL)animated
//{
//    IMLog(@"控制器个数：%lu",(unsigned long)self.navigationController.viewControllers.count);
//    if (1 == self.navigationController.viewControllers.count) {
//        self.tabBarController.tabBar.hidden = NO;
//    }
//    
//}


#pragma mark UIActionSheet 代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    IMLog(@"index = %ld",buttonIndex);
       if (2 == buttonIndex) return;
    UIImagePickerController *imgController = [[UIImagePickerController alloc] init];
    [imgController setAllowsEditing:YES];
    imgController.delegate = self;
    

    if(0 == buttonIndex){
      
#if TARGET_IPHONE_SIMULATOR
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"该设备不支持摄像" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;

#else
        [imgController setSourceType:UIImagePickerControllerSourceTypeCamera];
#endif
    }else{

        [imgController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

    }

    [self presentViewController:imgController animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImg = info[@"UIImagePickerControllerEditedImage"];
    [self.avatarBtn setImage:editedImg forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark tableview delegate方法
-  (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    IMLog(@"%d----->>>%d",indexPath.section,indexPath.row);
    NSInteger row = indexPath.row;
    if (((1 == row) && (0 == indexPath.section))||(1 == indexPath.section)) {
        EditVCardViewController *editVCardVC = [[EditVCardViewController alloc] init];
        UILabel *fixLb = (UILabel *)[[tableView cellForRowAtIndexPath:indexPath].contentView viewWithTag:11];
        editVCardVC.modifyLb = fixLb;
        editVCardVC.title = _titleArray[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:editVCardVC animated:YES];
    }
}
@end
