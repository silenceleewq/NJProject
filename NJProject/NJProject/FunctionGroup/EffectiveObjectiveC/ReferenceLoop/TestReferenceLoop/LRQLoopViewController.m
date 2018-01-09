//
//  LRQLoopViewController.m
//  LRQTest
//
//  Created by lirenqiang on 2018/1/8.
//  Copyright © 2018年 lirenqiang. All rights reserved.
//

#import "LRQLoopViewController.h"
#import "LRQDataFetcher.h"

@interface LRQLoopViewController ()
@property (strong, nonatomic) NSString *name;
@end

@implementation LRQLoopViewController {
    LRQDataFetcher *_dataFetcher;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"LoOp";
    
    _dataFetcher = [[LRQDataFetcher alloc] init];
//    __weak typeof (self)wSelf = self;
    [_dataFetcher completionHandler:^{
//        NSLog(@"dataFetcher: %@", wSelf.dataFetcher);
        self.name = @"hello";
    } excute:YES];
    
}

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
