//
//  UIButton+NJButton.m
//  链式语法
//
//  Created by slience on 2017/3/20.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "UIButton+NJButton.h"

@implementation UIButton (NJButton)
- (UIButton *(^)(NSString *title, UIControlState state))njTitle;
{
    return ^UIButton *(NSString *title, UIControlState state) {
        [self setTitle:title forState:state];
        return self;
    };
}

- (UIButton *(^)(UIColor *color, UIControlState state))njTitleColor
{
    return ^UIButton *(UIColor *color, UIControlState state) {
        [self setTitleColor:color forState:state];
        return self;
    };
}

- (UIButton *(^)(id target, SEL selector, UIControlEvents event))njAddAction
{
    return ^UIButton *(id target, SEL selector, UIControlEvents event) {
        [self addTarget:target action:selector forControlEvents:event];
        return self;
    };
}

- (UIButton *(^)(UIColor *color))njBackgroundColor
{
    return ^UIButton *(UIColor *color) {
        [self setBackgroundColor:color];
        return self;
    };
}

- (UIButton *(^)(UIImage *image, UIControlState state))njBackgroundImage
{
    return ^UIButton *(UIImage *image, UIControlState state) {
        [self setBackgroundImage:image forState:state];
        return self;
    };
}

- (UIButton *(^)(UIImage *image, UIControlState state))njImage
{
    return ^UIButton *(UIImage *image, UIControlState state) {
        [self setBackgroundImage:image forState:state];
        return self;
    };
}

@end
