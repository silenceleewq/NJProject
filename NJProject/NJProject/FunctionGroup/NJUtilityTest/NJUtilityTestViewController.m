//
//  NJUtilityTestViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/8/7.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJUtilityTestViewController.h"

@interface NJUtilityTestViewController ()

@end

@implementation NJUtilityTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIViewController *vc = [NJUtilities getCurrentVC];
    NSLog(@"vc: %@", vc);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
