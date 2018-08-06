//
//  EZJGradientProgressView.m
//  GradientView
//
//  Created by Maskkk on 2018/7/24.
//  Copyright © 2018 lirenqiang. All rights reserved.
//


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#import "NJGradientProgressView.h"

@interface NJGradientProgressView ()
@property (assign, nonatomic) NJGradientProgressViewType type;
@end

@implementation NJGradientProgressView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame type:(NJGradientProgressViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        self.layer.cornerRadius = 19.0/2.0;
        [self drawProgress];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"self.frame = %@", NSStringFromCGRect(self.frame));
}

- (void)drawProgress {
    CAGradientLayer *layer = (CAGradientLayer *)self.layer;
    if (_type == NJGradientProgressViewTypeNormal) {
        layer.colors = @[(__bridge id)UIColorFromRGB(0xFFF059).CGColor, (__bridge id)UIColorFromRGB(0xFFB001).CGColor];
        layer.startPoint = CGPointMake(0, 0);
        layer.endPoint = CGPointMake(0, 1);
    } else {
        layer.colors = @[(__bridge id)UIColorFromRGB(0xFFF059).CGColor, (__bridge id)UIColorFromRGB(0xFFB001).CGColor, (__bridge id)UIColorFromRGB(0xFF304F).CGColor];
        layer.locations = @[@0.0, @0.5, @1.0];
        layer.startPoint = CGPointMake(0, 1);
        layer.endPoint = CGPointMake(1, 1);
    }
}

- (void)setType:(NJGradientProgressViewType)type {
    _type = type;
    [self drawProgress];
}

@end
