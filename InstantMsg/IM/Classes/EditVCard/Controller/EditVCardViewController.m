//
//  EditVCardViewController.m
//  IM
//
//  Created by Chan on 15/1/21.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "EditVCardViewController.h"

@interface EditVCardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *modifyField;

@end

@implementation EditVCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.modifyField.text = self.modifyLb.text;
    [self.modifyField becomeFirstResponder];
//    self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStyleDone target:self action:@selector(modifyInfo)];
//    self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(modifyField)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStyleDone target:self action:@selector(modifyInfo)];

}

- (void)modifyInfo
{
    self.modifyLb.text = self.modifyField.text;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



@end
