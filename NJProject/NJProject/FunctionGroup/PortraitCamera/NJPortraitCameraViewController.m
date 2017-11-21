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
@property (weak, nonatomic) IBOutlet UIImageView *histImage;
@end

@implementation NJPortraitCameraViewController

- (instancetype)init
{
    if (self = [super init]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NJPortraitCameraViewController" bundle:nil];
        self = [sb instantiateInitialViewController];
        self.utilManager = [NJOpenCVUtils sharedManager];
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
    camera.idCardType = NJIDCardTypeHead;
    camera.finishedSnip = ^(UIImage *image) {
        self.imgView.image = image;
    };
    //    [self presentViewController:camera animated:YES completion:nil];
    [self.navigationController pushViewController:camera animated:YES];
}
- (IBAction)matchAction:(id)sender {
    if (!self.imgView.image) {
        return;
    }
    NJTemplateMatchingViewController *match = [[NJTemplateMatchingViewController alloc] init];
    match.srcImage = self.imgView.image;
    [self.navigationController pushViewController:match animated:YES];
}

- (IBAction)BackCamera:(UIButton *)sender {
    
}

- (IBAction)detectLight {
    
    UIImage *srcImage = self.imgView.image;
    if (!srcImage) {
        return;
    }
    UIImage *histImage = [self.utilManager draw1DHistogram:srcImage];
    
    [self.utilManager detectImageLight:srcImage done:^(float light, float black) {
        NSLog(@"light: %f, black: %f", light, black);
    }];
    self.histImage.image = histImage;
}


@end
