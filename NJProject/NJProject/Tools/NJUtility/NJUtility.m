//
//  NJUtility.m
//  NJProject
//
//  Created by lirenqiang on 2017/8/7.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJUtility.h"

@implementation NJUtility


/**
 这个方法并不是要找到ViewController.
 找到的可能是
 UINavigationController
 或者
 UITabBarController.

 @return UIViewController
 */
+ (UIViewController *)getCurrentVC {
    UIViewController *vc = nil;
    
    //找到主要的window.
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tempWindow in windows) {
            window = tempWindow;
            break;
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        vc = nextResponder;
    } else {
        vc = window.rootViewController;
    }
    
    return vc;
}

@end
