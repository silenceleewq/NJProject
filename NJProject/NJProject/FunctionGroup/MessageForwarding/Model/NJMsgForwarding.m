//
//  NJMsgForwarding.m
//  NJProject
//
//  Created by lirenqiang on 25/12/2017.
//  Copyright © 2017 Ninja. All rights reserved.
//
/**
 主要用来测试resolveInstanceMethod 和 forwardingTargetForSelector
 resolveInstanceMethod, 主要在当前对象收到了一个不存在的对象时,会触发该方法.
 比如说, NJMsgForwarding 的一个实例对象 msf, 使用performSelector, 执行了一个 @selector(hello) 方法,
 由于 NJMsgForwarding 类并没有相应的 hello 方法,于是会触发 resolveInstanceMethod 方法,让程序员决定是否要动态添加一个方法.
 如果使用 Runtime 里面的方法,给 resolveInstanceMethod 方法中的 sel 参数, 动态添加了一个 方法实现(IMP),并且 return YES; 那么,上面执行的 hello 方法会转而去执行动态添加的那个 IMP.
 
 这就是 resolveInstanceMethod 的使用,但是具体的使用场景不太清楚.
 */

/**
 forwardingTargetForSelector
 这个方法sh
 */

#import "NJMsgForwarding.h"
#import <objc/runtime.h>
#import "NJMsgReplacement.h"

@implementation NJMsgForwarding

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    //判断参数 sel 是否是 hello 方法.这个判断也可以不用.
    BOOL isHelloSEL = [NSStringFromSelector(sel) isEqualToString:NSStringFromSelector(@selector(hello))];
    
    if (!isHelloSEL) {
        Method m = class_getInstanceMethod(self.class, @selector(forwardingMessage));
        NSLog(@"m.type = %s", method_getTypeEncoding(m));
        class_addMethod(self.class, sel, method_getImplementation(m), method_getTypeEncoding(m));
        return YES;
    }
    
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return [NJMsgReplacement new];
}

- (void)forwardingMessage {
    NSLog(@"forwardingMessage");
}

- (NSString *)description {
    return @"NJMsgForwarding description";
}

- (NSString *)debugDescription {
    return @"NJMsgForwarding debugDescription";
}

@end
