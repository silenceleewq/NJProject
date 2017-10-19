//
//  NJHoughLineViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/10/16.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJHoughLineViewController.h"

@interface NJHoughLineViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIButton *photoBtn;
@end

@implementation NJHoughLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.photoBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)photoBtn
{
    if (!_photoBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, UIScreen.mainScreen.bounds.size.height-60, 100, 60)];
        _photoBtn = btn;
        [_photoBtn setTitle:@"photo" forState:UIControlStateNormal];
        [_photoBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [_photoBtn addTarget:self action:@selector(photoBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}

- (void)photoBtnAction
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"INFO: \n%@", info);
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
