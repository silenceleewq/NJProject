//
//  NJPhotosController.m
//  NJProject
//
//  Created by slience on 2017/6/19.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJPhotosController.h"

@interface NJPhotosController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation NJPhotosController

+ (instancetype)photosController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NJPhotosController" bundle:nil];
    NJPhotosController * controller = [sb instantiateInitialViewController];
    return controller;
}

- (instancetype)init
{
    if (self = [super init]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NJPhotosController" bundle:nil];
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

- (IBAction)photoButton:(UIButton *)sender {
    //定义相册类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)cameraButton:(UIButton *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = NO;
    picker.delegate   = self;
    picker.sourceType = sourceType;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"INFO: \n%@", info);
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!image) {return;} else {
        self.imgView.image = image;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"NJPhotos Dealloc");
}

@end
