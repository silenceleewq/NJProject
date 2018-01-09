//
//  NJErrorModel.m
//  NJProject
//
//  Created by lirenqiang on 2017/12/29.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJErrorModel.h"

NSString *const NJLowerStringErrorDomain = @"NJLowerStringErrorDomain";

@implementation NJErrorModel

- (BOOL)lowerString:(NSString *)string :(NSError **)error {
    
    if (!string) {
        if (error) {
            *error = [NSError errorWithDomain:NJLowerStringErrorDomain code:0 userInfo:nil];
        }
        return NO;
    }
    return YES;
}

@end
