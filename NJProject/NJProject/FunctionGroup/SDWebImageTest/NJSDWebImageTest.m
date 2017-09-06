//
//  NJSDWebImageTest.m
//  NJProject
//
//  Created by slience on 2017/6/21.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJSDWebImageTest.h"
#import "UIImageView+WebCache.h"

@interface NJSDWebImageTest ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@end

@implementation NJSDWebImageTest

- (instancetype)init
{
    if (self = [super init]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NJSDWebImageTest" bundle:nil];
        self = [sb instantiateInitialViewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlString = @"http://pic.58pic.com/58pic/14/27/45/71r58PICmDM_1024.jpg";
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self.imgView sd_setImageWithURL:url placeholderImage:nil options:0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
