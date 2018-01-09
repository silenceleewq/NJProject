//
//  NJEffectiveController.m
//  NJProject
//
//  Created by lirenqiang on 2017/12/29.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJEffectiveController.h"
#import "NJProtocolModel.h"

@interface NJEffectiveController () <NJProtocolDelegate>

@end

@implementation NJEffectiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    NJProtocolModel *model = [NJProtocolModel new];
    model.delegate = self;
    [model sendDelegateAction];
}

- (void)NJProtocol:(NJProtocolModel *)model didFailed:(NSError *)error
{
    NSLog(@"error: %@", error);
}

- (void)NJProtocol:(NJProtocolModel *)model didReceivedData:(NSData *)data
{
    NSLog(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
