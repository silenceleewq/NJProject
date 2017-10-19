//
//  NJHIstogramViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/27.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJHIstogramViewController.h"

@interface NJHIstogramViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation NJHIstogramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupAction];
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

    UIImage *newImage = [self.utilManager drawGrayScaleHistogram:image];
    if ([self.utilManager checkForBurryImage:image]){
        NSLog(@"模糊");
    } else {
        NSLog(@"不模糊");
    }
    self.originalImgView.image = image;
    self.changedImgView.image = newImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
