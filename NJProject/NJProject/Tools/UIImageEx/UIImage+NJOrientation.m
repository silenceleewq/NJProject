//
//  UIImage+NJOrientation.m
//  NJProject
//
//  Created by lirenqiang on 2017/10/12.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "UIImage+NJOrientation.h"

@implementation UIImage (NJOrientation)

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
