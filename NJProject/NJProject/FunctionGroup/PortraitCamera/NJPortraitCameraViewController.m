//
//  NJPortraitCameraViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/14.
//  Copyright © 2017年 Ninja. All rights reserved.
//


#define USE_TEMPLATE 1
#import "NJPortraitCameraViewController.h"
#import "NJCustomPortaitCameraViewController.h"

#if USE_TEMPLATE
#import "NJTemplateMatchingViewController.h"
#else
#endif
#import "NJOpenCVUtils.h"

@interface NJPortraitCameraViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) NJOpenCVUtils *utilManager;
@end

@implementation NJPortraitCameraViewController

- (instancetype)init
{
    if (self = [super init]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NJPortraitCameraViewController" bundle:nil];
        self = [sb instantiateInitialViewController];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)JumpToCamera:(UIButton *)sender {
    
    NJCustomPortaitCameraViewController *camera = [[NJCustomPortaitCameraViewController alloc] init];
    //    camera.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    camera.finishedSnip = ^(UIImage *image) {
        self.imgView.image = image;
    };
    //    [self presentViewController:camera animated:YES completion:nil];
    [self.navigationController pushViewController:camera animated:YES];
}
- (IBAction)matchAction:(id)sender {
    NJTemplateMatchingViewController *match = [[NJTemplateMatchingViewController alloc] init];
    match.srcImage = self.imgView.image;
    [self.navigationController pushViewController:match animated:YES];
}

- (IBAction)detectLight {
    
    UIImage *srcImage = self.imgView.image;
    
    
    
}


@end
