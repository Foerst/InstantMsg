//
//  AddContactViewController.m
//  IM
//
//  Created by Chan on 15/2/9.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "AddContactViewController.h"
#import "XMPPRosterCoreDataStorage.h"

@interface AddContactViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加好友";
    [self.searchField becomeFirstResponder];
    self.searchField.returnKeyType = UIReturnKeyJoin;

}
#pragma mark -textfield delegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self addContactWithJIdStr:textField.text.trimString];
    return YES;
}


- (void)addContactWithJIdStr:(NSString *)jidStr
{
    UserModel *user = [UserModel sharedUserModel];
    if ([jidStr rangeOfString:@"@"].location == NSNotFound) {
        jidStr = [jidStr stringByAppendingFormat:@"@%@",user.server];
    }
    if ([jidStr isEqualToString:user.jid]) {//不能添加自己
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"不能添加自己为好友" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }else{//检查是否已经是好友，是则不添加并提醒
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        Boolean isFriend = [appDelegate.rosterStorage userExistsWithJID:[XMPPJID jidWithString:jidStr] xmppStream:appDelegate.xmppStream];
        if (isFriend){//是好友
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"对方已经是自己的好友，不用添加" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }else{//不是好友
            [appDelegate.roster subscribePresenceToUser:[XMPPJID jidWithString:jidStr]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"好友请求已经发送" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
    
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    IMLog(@"%ld",(long)buttonIndex);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
