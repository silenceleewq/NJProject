//
//  QRCodeScanController.m
//  NJProject
//
//  Created by slience on 2017/6/20.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "QRCodeScanViewController.h"
#import "NJQRCodeScanOC.h"


@interface QRCodeScanViewController () <NJQRCodeScanOCDelegate>


@end

@implementation QRCodeScanViewController

- (instancetype)init
{
    if (self = [super init]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QRCodeScanViewController" bundle:nil];
        self = [sb instantiateInitialViewController];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanButton:(UIButton *)sender {
    NJQRCodeScanOC *qrscan = [[NJQRCodeScanOC alloc] init];
    qrscan.delegate = self;
    [self.navigationController pushViewController:qrscan animated:YES];
}

- (void)qrCodeComplete:(NSString *)codeString {
    
}


@end
