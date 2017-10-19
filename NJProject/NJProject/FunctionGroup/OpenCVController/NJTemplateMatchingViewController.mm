//
//  NJTemplateMatchingViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/10/12.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/core/core_c.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2//highgui/ios.h>


#import "NJOpenCVUtils.h"
#import "NJTemplateMatchingViewController.h"
#import "UIImage+NJOrientation.h"

#define USE_OUTSIDE 1

@interface NJTemplateMatchingViewController ()  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImage *_resultImage;
    UIImage *_templateImage;
}
@end

@implementation NJTemplateMatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAction];
    self.originalImgView.image = _resultImage;
    self.changedImgView.image = _templateImage;
#if USE_OUTSIDE
    
#else
    [self templateMatching];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupAction
{
    [self.btn addTarget:self action:@selector(callPickerSelect) forControlEvents:UIControlEventTouchUpInside];
}

- (void)callPickerSelect
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    [self presentViewController:imgPicker animated:YES completion:nil];
}

#pragma mark - imagePicker delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"orientation: %zd", image.imageOrientation);
    UIImage *newImage = [image normalizedImage];

    [self.utilManager templateMatching:newImage complete:^(UIImage *resultImage, UIImage *templateImage) {
        self.originalImgView.image = resultImage;
        self.changedImgView.image = templateImage;
    }];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

#if USE_OUTSIDE

#else
- (void)templateMatching
{
    NSString *src_path = [[NSBundle mainBundle] pathForResource:@"src3" ofType:@".png"];
    NSString *target_path = [[NSBundle mainBundle] pathForResource:@"emblem" ofType:@".png"];
    UIImage *src_image = [UIImage imageWithContentsOfFile:src_path];
    UIImage *target_image = [UIImage imageWithContentsOfFile:target_path];
    
    IplImage *src = [self IplImageFromUIImage:src_image];
    IplImage *srcResult = [self IplImageFromUIImage:src_image];
    IplImage *templat = [self IplImageFromUIImage:target_image];
    IplImage *result;
    
    int srcW, srcH, templatW, templatH, resultH, resultW;
    srcW = src->width;
    srcH = src->height;
    templatW = templat->width;
    templatH = templat->height;
    if(srcW < templatW || srcH < templatH)
    {
        std::cout <<"模板不能比原图像小" << std::endl;
        return;
    }
    
    resultW = srcW - templatW + 1;
    resultH = srcH - templatH + 1;
    result = cvCreateImage(cvSize(resultW, resultH), 32, 1);
    cvMatchTemplate(src, templat, result, CV_TM_SQDIFF);
    double minValue, maxValue;
    CvPoint minLoc, maxLoc;
    cvMinMaxLoc(result, &minValue, &maxValue, &minLoc, &maxLoc);
    cvRectangle(srcResult, minLoc, cvPoint(minLoc.x + templatW, minLoc.y+ templatH), cvScalar(0,0,255));
    
    NSLog(@"x = %zd, y = %zd", minLoc.x, minLoc.y);
    NSLog(@"w = %zd, h = %zd", minLoc.x+templatW, minLoc.y + templatH);
    
    self.originalImgView.image = [self UIImageFromIplImage:srcResult];
    self.changedImgView.image = [self UIImageFromIplImage:templat];
    cvReleaseImage(&result);
    cvReleaseImage(&templat);
    cvReleaseImage(&srcResult);
    cvReleaseImage(&src);
}
#endif
#pragma mark UIImage 和 IplImage 互相转换

/**
 UIImage -> IplImage
 
 @param image UIImage
 @return IplImage
 */
-(IplImage *)IplImageFromUIImage:(UIImage*)image
{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplImage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
    CGContextRef contextRef = CGBitmapContextCreate(iplImage->imageData, iplImage->width, iplImage->height, iplImage->depth, iplImage->widthStep, colorSpace, kCGImageAlphaPremultipliedLast| kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    IplImage *ret = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplImage, ret, CV_RGB2BGR);
    cvReleaseImage(&iplImage);
    return ret;
}


/**
 IplImage -> UIImage
 
 @param image IplImage
 @return UIImage *
 */
- (UIImage *)UIImageFromIplImage:(IplImage *)image
{
    cv::Mat mat = cv::Mat(image);
    return MatToUIImage(mat);
}

- (void)setSrcImage:(UIImage *)srcImage
{
    _srcImage = srcImage;
    [self.utilManager templateMatching:srcImage complete:^(UIImage *resultImage, UIImage *templateImage) {
        _resultImage = resultImage;
        _templateImage = templateImage;
    }];
}



@end
