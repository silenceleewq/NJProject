//
//  NJOpenCVUtils.h
//  NJProject
//
//  Created by lirenqiang on 2017/9/27.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NJOpenCVUtils : NSObject
+ (instancetype)sharedManager;

- (UIImage *)draw1DHistogram:(UIImage *)image;

- (UIImage *)drawGrayScaleHistogram:(UIImage *)image;

@end
