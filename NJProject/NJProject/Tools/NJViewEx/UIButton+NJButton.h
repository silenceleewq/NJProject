//
//  UIButton+NJButton.h
//  链式语法
//
//  Created by slience on 2017/3/20.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (NJButton)
- (UIButton *(^)(NSString *title, UIControlState state))njTitle;
- (UIButton *(^)(UIColor *color, UIControlState state))njTitleColor;
- (UIButton *(^)(id target, SEL selector, UIControlEvents event))njAddAction;
- (UIButton *(^)(UIColor *color))njBackgroundColor;
- (UIButton *(^)(UIImage *image, UIControlState state))njBackgroundImage;
- (UIButton *(^)(UIImage *image, UIControlState state))njImage;
@end
