//
//  LRQBaseClass.m
//  LRQTest
//
//  Created by lirenqiang on 2018/1/9.
//  Copyright © 2018年 lirenqiang. All rights reserved.
//

#import "LRQBaseClass.h"

@implementation LRQBaseClass

+ (void)initialize
{
    if (self == [LRQBaseClass class]) {
        NSLog(@"self = %@", self);
    }
}

- (void)run {
    NSLog(@" LRQBaseClass  run ");
}



@end
