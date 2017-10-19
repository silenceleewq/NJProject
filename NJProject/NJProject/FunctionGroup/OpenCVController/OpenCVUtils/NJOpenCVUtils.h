//
//  NJOpenCVUtils.h
//  NJProject
//
//  Created by lirenqiang on 2017/9/27.
//  Copyright © 2017年 Ninja. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef void(^NJTemplateMatchingCompleteBlock)(UIImage *resultImage, UIImage *templateImage);

@interface NJOpenCVUtils : NSObject
+ (instancetype)sharedManager;

- (UIImage *)draw1DHistogram:(UIImage *)image;

- (UIImage *)drawGrayScaleHistogram:(UIImage *)image;

- (BOOL)checkForBurryImage:(UIImage *)srcImage;


/**
 http://www.jianshu.com/p/ac4c4536ca3e
 上面这篇博客上面介绍的方法.

 @param image 扫描身份证图片,进行灰度/二值化/腐蚀/轮廓检测等方法
              对图片进行处理.
 @return UIimage
 */
- (NSArray<UIImage *> *)opencvScanCard:(UIImage *)image;

- (void)calculateAverageBrightness:(UIImage *)image;


/**
 模板匹配函数

 @param srcImage 需要匹配的源文件图片
 @param completeBlock 匹配完成后的结果.
 */
- (void)templateMatching:(UIImage *)srcImage complete:(NJTemplateMatchingCompleteBlock)completeBlock;

@end
