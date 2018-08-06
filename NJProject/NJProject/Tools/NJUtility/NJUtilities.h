//
//  NJUtility.h
//  NJProject
//
//  Created by lirenqiang on 2017/8/7.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NJUtilities : NSObject

+ (UIViewController *)getCurrentVC;

/**
 开启一个定时器
 
 @param target 定时器持有者
 @param timeInterval 执行间隔时间
 @param handler 重复执行事件
 @auth GerryZhu https://www.jianshu.com/u/222135004e13
 */
void dispatchTimer(id target, double timeInterval,void (^handler)(dispatch_source_t timer));
@end
