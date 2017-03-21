//
//  NJUtilities.h
//  链式语法
//
//  Created by slience on 2017/3/21.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif



static inline id _NJBoxValue(const char *type, ...) {
    va_list v;
    va_start(v, type);
    id obj = nil;
    
    if (strcmp(type, @encode(CGPoint)) == 0) {
        id actual = va_arg(v, id);
        obj = actual;
    } else if (strcmp(type, @encode(int)) == 0) {
        int actual = (int)va_arg(v, int);
        obj = [NSNumber numberWithInt:actual];
    } else if (strcmp(type, @encode(float))) {
        float actual = (float)va_arg(v, double);
        obj = [NSNumber numberWithFloat:actual];
    } else if (strcmp(type, @encode(float))) {
        float actual = (float)va_arg(v, double);
        obj = [NSNumber numberWithFloat:actual];
    }
    va_end(v);
    return obj;
}



#define NJBoxValue(value) _NJBoxValue(@encode(__typeof__((value))), (value))




