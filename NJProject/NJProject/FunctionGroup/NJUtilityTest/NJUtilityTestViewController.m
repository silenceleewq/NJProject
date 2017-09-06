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
    UIViewController *vc = [NJUtility getCurrentVC];
    NSLog(@"vc: %@", vc);
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
