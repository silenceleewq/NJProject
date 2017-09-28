//
//  NJCameraViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/14.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJCameraViewController.h"
#import "NJCustomCameraViewController.h"

@interface NJCameraViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation NJCameraViewController

- (instancetype)init
{
    if (self = [super init]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NJCameraViewController" bundle:nil];
        self = [sb instantiateInitialViewController];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.s
    self.view.backgroundColor = [UIColor whiteColor];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)JumpToCamera:(id)sender {
    
    NJCustomCameraViewController *camera = [[NJCustomCameraViewController alloc] init];
//    camera.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    camera.finishedSnip = ^(UIImage *image) {
        self.imageView.image = image;
    };
//    [self presentViewController:camera animated:YES completion:nil];
    [self.navigationController pushViewController:camera animated:YES];
    
}


@end
