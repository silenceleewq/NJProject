//
//  LRQSubClass+Bury.m
//  LRQTest
//
//  Created by lirenqiang on 2018/1/9.
//  Copyright © 2018年 lirenqiang. All rights reserved.
//

#import "LRQSubClass+Bury.h"
#import <objc/runtime.h>

@implementation LRQSubClass (Bury)

- (void)run_category {
    [self run_category];
    NSLog(@"LRQSubClass run_category");
}

+ (void)load {

    lrq_exchangeImplementations(self.class,
                                NSSelectorFromString(@"run"),
                                NSSelectorFromString(@"run_category"));
}


/**
 交换方法

 @param class 要交换方法的类.
 @param originalSelector 原始的方法签名
 @param swizzledSelector 要交换的方法签名.
 */
void lrq_exchangeImplementations(Class class, SEL originalSelector, SEL swizzledSelector) {
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL addMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (addMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
