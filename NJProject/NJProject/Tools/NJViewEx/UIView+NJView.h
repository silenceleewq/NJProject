//
//  UIView+NJView.h
//  链式语法
//
//  Created by slience on 2017/3/20.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (NJView)
- (UIView *(^)(CGFloat radius))nj_cornerRadius;
@end
