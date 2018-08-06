//
//  NJUtility.m
//  NJProject
//
//  Created by lirenqiang on 2017/8/7.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJUtilities.h"

@implementation NJUtilities


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


void dispatchTimer(id target, double timeInterval,void (^handler)(dispatch_source_t timer))
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), (uint64_t)(timeInterval *NSEC_PER_SEC), 0);
    // 设置回调
    __weak __typeof(target) weaktarget  = target;
    dispatch_source_set_event_handler(timer, ^{
        if (!weaktarget)  {
            dispatch_source_cancel(timer);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) handler(timer);
            });
        }
    });
    // 启动定时器
    dispatch_resume(timer);
}

@end
