//
//  NJOpenCVBaseViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/28.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJOpenCVBaseViewController.h"

@interface NJOpenCVBaseViewController ()

@end

@implementation NJOpenCVBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)setupUI
{
    [self.view addSubview:self.originalImgView];
    [self.view addSubview:self.changedImgView];
    [self.view addSubview:self.btn];
    
    UIImage *image = [UIImage imageNamed:@"2"];
    self.originalImgView.image = image;
    self.changedImgView.image = image;
}


#pragma mark - 懒加载
- (UIImageView *)originalImgView
{
    if (!_originalImgView) {
        _originalImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, KSCREENWIDTH, KSCREENWIDTH *0.55)];
        _originalImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _originalImgView;
}

- (UIImageView *)changedImgView
{
    if (!_changedImgView) {
        _changedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64+KSCREENWIDTH *0.55 + 20, KSCREENWIDTH, KSCREENWIDTH *0.55)];
        _changedImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _changedImgView;
}

- (UIButton *)btn
{
    if (!_btn) {
        _btn = [[UIButton alloc] initWithFrame:CGRectMake(0, KSCREENHEIGHT - 64, 120, 60)];
        [_btn setTitle:@"选择图片" forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    return _btn;
}

- (NJOpenCVUtils *)utilManager {
    if (!_utilManager)
    {
        _utilManager = [NJOpenCVUtils sharedManager];
    }
    return _utilManager;
}



@end
