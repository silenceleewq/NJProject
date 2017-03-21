//
//  UIView+NJView.m
//  链式语法
//
//  Created by slience on 2017/3/20.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "UIView+NJView.h"

@implementation UIView (NJView)

- (UIView *(^)(CGFloat radius))nj_cornerRadius {
    return ^UIView *(CGFloat radius) {
        self.layer.cornerRadius = radius;
        return self;
    };
}

@end
