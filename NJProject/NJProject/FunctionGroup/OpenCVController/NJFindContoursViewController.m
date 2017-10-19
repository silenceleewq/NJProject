//
//  NJFindContoursViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/28.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJFindContoursViewController.h"

@interface NJFindContoursViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *numberImgView;
@end

@implementation NJFindContoursViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self makeUI];
    [self setupAction];
}

- (void)makeUI
{
    self.numberImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.changedImgView.frame)+20, KSCREENWIDTH, 50)];
    self.numberImgView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.numberImgView];
}

- (void)setupAction
{
    [self.btn addTarget:self action:@selector(callPickerSelect) forControlEvents:UIControlEventTouchUpInside];
}

- (void)callPickerSelect
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    [self presentViewController:imgPicker animated:YES completion:nil];
}


#pragma mark - imagePicker delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //求亮度均值
    [self.utilManager calculateAverageBrightness:image];
    
    NSArray <UIImage *> *imgArray = [self.utilManager opencvScanCard:image];

    self.originalImgView.image = image;
    self.changedImgView.image = imgArray[0];
    self.numberImgView.image = imgArray[1];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



@end
