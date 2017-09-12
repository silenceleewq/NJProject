//
//  NJQRCodeScanShadowLayer.m
//  NJProject
//
//  Created by lirenqiang on 12/09/2017.
//  Copyright © 2017 Ninja. All rights reserved.
//

#import "NJQRCodeScanShadowLayer.h"

@implementation NJQRCodeScanShadowLayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
//        _IDCardScanningWindowLayer =  [CAShapeLayer layer];
//        _IDCardScanningWindowLayer.position = self.view.layer.position;
////        CGFloat width = iPhone5or5cor5sorSE? 240: (iPhone6or6sor7? 270: 300);
//        CGFloat width = 200;
//        _IDCardScanningWindowLayer.bounds = (CGRect){CGPointZero, {width, width}};
//        _IDCardScanningWindowLayer.cornerRadius = 15;
//        _IDCardScanningWindowLayer.borderColor = [UIColor whiteColor].CGColor;
//        _IDCardScanningWindowLayer.borderWidth = 1.5;
//        [self.view.layer addSublayer:_IDCardScanningWindowLayer];
//        
//        // 最里层镂空
//        UIBezierPath *transparentRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:_IDCardScanningWindowLayer.frame cornerRadius:_IDCardScanningWindowLayer.cornerRadius];
//        
//        // 最外层背景
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.frame];
//        [path appendPath:transparentRoundedRectPath];
//        [path setUsesEvenOddFillRule:YES];
//        
//        CAShapeLayer *fillLayer = [CAShapeLayer layer];
//        fillLayer.path = path.CGPath;
//        fillLayer.fillRule = kCAFillRuleEvenOdd;
//        fillLayer.fillColor = [UIColor blackColor].CGColor;
//        fillLayer.opacity = 0.6;
//        
//        [self.view.layer addSublayer:fillLayer];
    }
    return self;
}

@end
