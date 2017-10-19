//
//  NJIQKeyboardViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/10/19.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJIQKeyboardViewController.h"

@interface NJIQKeyboardViewController ()

@end

@implementation NJIQKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self setupUI];
}

- (void)setupUI
{
    //标准的文本输入框
    UITextField *bottomTf = [[UITextField alloc] initWithFrame:CGRectMake(20, KSCREENHEIGHT-30-20, 100, 30)];
    bottomTf.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:bottomTf];
    
    //没有UIToolBar的文本输入框
    UITextField *withoutToolBarTF = [[UITextField alloc] initWithFrame:CGRectMake(150, KSCREENHEIGHT-30-20, 100, 30)];
    withoutToolBarTF.borderStyle = UITextBorderStyleRoundedRect;
    withoutToolBarTF.placeholder = @"Without tool bar";
    withoutToolBarTF.inputAccessoryView = [UIView new];
    [self.view addSubview:withoutToolBarTF];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
