//
//  NJHIstogramViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/27.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJHIstogramViewController.h"
#import "NJOpenCVUtils.h"

@interface NJHIstogramViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *originalImgView;
@property (nonatomic, strong) UIImageView *changedImgView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) NJOpenCVUtils *utilManager;
@end

@implementation NJHIstogramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *image = [UIImage imageNamed:@"2"];
    self.originalImgView.image = image;
    self.changedImgView.image = image;
    [self setupUI];
}

- (void)setupUI
{
    [self.view addSubview:self.originalImgView];
    [self.view addSubview:self.changedImgView];
    [self.view addSubview:self.btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [_btn addTarget:self action:@selector(callPickerSelect) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark - 按钮方法
- (void)callPickerSelect
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    [self presentViewController:imgPicker animated:YES completion:nil];
}

#pragma mark - imagePicker delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    UIImage *newImage = [self.utilManager drawGrayScaleHistogram:image];
    self.originalImgView.image = image;
    self.changedImgView.image = newImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
