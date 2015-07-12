//
//  LoginViewController.m
//  InstantMessage
//
//  Created by Chan on 15/1/12.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *idField;
@property (weak, nonatomic) IBOutlet UITextField *serverField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
- (IBAction)login:(UIButton *)sender;
- (IBAction)regist:(UIButton *)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
#if TARGET_IPHONE_SIMULATOR
    self.idField.text = @"lisi";
    self.passwordField.text = @"lisi";
#else
    self.idField.text = @"maliu";
    self.passwordField.text = @"maliu";
#endif

    [self.loginBtn setAllStateBackgroundImageWithImageName:@"LoginGreenBigBtn.png"];
    [self.registBtn setAllStateBackgroundImageWithImageName:@"LoginwhiteBtn"];
 
}



- (IBAction)login:(UIButton *)sender
{

    NSString *idStr = self.idField.text;
    NSString *serverStr = self.serverField.text;
    NSString *passwordStr = self.passwordField.text;
    NSString *msg = nil;
    
    if ([[idStr trimString] isEmptyString]|| [[serverStr trimString] isEmptyString]|| [passwordStr isEmptyString]) {//输入信息有误
       
        //改变焦点
        if ([[idStr trimString] isEmptyString]) {
            msg = @"请输入用户名！";
            [self.idField becomeFirstResponder];
        }else if ([[serverStr trimString] isEmptyString]){
             msg = @"请输入服务器地址！";
            [self.serverField becomeFirstResponder];
        }else if ([passwordStr isEmptyString]){
             msg = @"请输入密码！";
            [self.passwordField becomeFirstResponder];
        }
        //弹出框
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alerView show];
        return;
    }else{//输入无误，准备连接服务器
        UserModel *user = [UserModel sharedUserModel];
        user.username = idStr;
        user.server = serverStr;
        user.password = passwordStr;
        user.jid = [user.username stringByAppendingFormat:@"@%@",user.server];
        
        AppDelegate *appDelegate = [self applicationDelegete];
        
        [appDelegate connectionWithXmppServerSuccess:^{
            IMLog(@"登陆成功");
            [ProgressHUD dismiss];

            [appDelegate changeRootViewController];
            
        } failure:^{
            IMLog(@"登陆失败");
            //弹出框
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressHUD dismiss];
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"错误！" message:@"登陆信息错误，请检查" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alerView show];
            });
 
        }];
    }
}

- (IBAction)regist:(UIButton *)sender
{
//    LAContext *context = [[LAContext alloc] init];
//    NSError *error = nil;
//    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
//        NSLog(@"Touch ID is available.");
//       [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Test!!!" reply:^(BOOL success, NSError *error) {
//           if (success) {
//               NSLog(@"用Touch ID认证成功！");
//           } else {
//               if (error.code == kLAErrorUserFallback) {
//                   NSLog(@"用户点击输入密码！");
//               } else if (error.code == kLAErrorUserCancel) {
//                   NSLog(@"用户点击取消！");
//               } else {
//                   NSLog(@"认证失败！");
//               }
//           }
//       }];
//    }
    
}


- (AppDelegate *)applicationDelegete
{
    return [UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning
{
    
}
@end
