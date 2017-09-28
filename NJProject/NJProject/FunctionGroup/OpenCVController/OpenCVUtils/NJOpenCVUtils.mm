//
//  NJOpenCVUtils.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/27.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/core/core_c.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2//highgui/ios.h>

#define cvQueryHistValue_1D( hist, idx0 ) \
((float)cvGetReal1D( (hist)->bins, (idx0)))

using namespace std;
using namespace cv;

#import "NJOpenCVUtils.h"

static NJOpenCVUtils *_instance = nil;

@implementation NJOpenCVUtils

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [NJOpenCVUtils new];
        }
    });
    return _instance;
}

#pragma mark 繪製一維直方圖.
- (UIImage *)draw1DHistogram:(UIImage *)image
{
    //加载一张图片
//    UIImage *image = [UIImage imageNamed:@"1"];
    IplImage *src = [self convertToIplImage:image];
    
    //创建直方图
    //定义直方图的大小
    //因为有0-255种颜色,对每个颜色都进行获取.
    int dims = 1;
    int size = 256;
    //一维直方图取密集型
    //ranges:
    float range[] = {0, 255};
    float *ranges[] = {range};
    CvHistogram *hist = cvCreateHist(dims, &size, CV_HIST_ARRAY, ranges, 1);
    cvClearHist(hist);
    //8位单通道图像
    IplImage *imgRed = cvCreateImage(cvGetSize(src), 8, 1);
    IplImage *imgGreen = cvCreateImage(cvGetSize(src), 8, 1);
    IplImage *imgBlue = cvCreateImage(cvGetSize(src), 8, 1);
    
    //将原图像分解成后面的4个通道.因为原图像是3通道的图像.必须要按照BGR的顺序来排列.
    cvSplit(src, imgBlue, imgGreen, imgRed, NULL);
    
    //计算直方图
    cvCalcHist(&imgBlue, hist, 0, 0);
    IplImage *histBlue = DrawHistogram(hist);
    cvClearHist(hist);
    cvCalcHist(&imgGreen, hist, 0, 0);
    IplImage *histGreen = DrawHistogram(hist);
    cvClearHist(hist);
    cvCalcHist(&imgRed, hist, 0, 0);
    IplImage *histRed = DrawHistogram(hist);
    cvClearHist(hist);
    
    return [self convertToUIImage:histBlue];
}

#pragma mark 繪製灰度圖的直方圖.
- (UIImage *)drawGrayScaleHistogram:(UIImage *)image
{
    cv::Mat matImageGray = [self convertToGrayScale:image];
    IplImage src = IplImage(matImageGray);
    int dims = 1;
    int size = 256;
    float range[] = {0, 255};
    float *ranges[] = {range};
    CvHistogram *hist = cvCreateHist(dims, &size, CV_HIST_ARRAY, ranges, 1);
    cvClearHist(hist);
    
    IplImage *imgGray = cvCreateImage(cvGetSize(&src), 8, 1);
    cvSplit(&src, imgGray, NULL, NULL, NULL);
    cvCalcHist(&imgGray, hist, 0, 0);
    IplImage *histGray = DrawHistogram(hist, 3, 5);
    
    return [self convertToUIImage:histGray];
}

IplImage *DrawHistogram(CvHistogram *hist, float scaleX = 1, float scaleY = 1)
{
    //先取最大值,作为图像的高度
    float histMax = 0;
    cvGetMinMaxHistValue(hist, 0, &histMax, 0, 0);
    
    IplImage * imgHist = cvCreateImage(cvSize(256*scaleX, 64*scaleY), 8, 1);
    cvZero(imgHist);
    double histSum = 0.0;
    double histMoreThan200 = 0.0;
    //画柱条
    for (int i = 0; i < 255; i++)
    {
        //获取了两个bin的值
        float histValue = cvQueryHistValue_1D(hist, i);
        float nextValue = cvQueryHistValue_1D(hist, i+1);//该值的数值不知道到底有多大,所以需要进行归一化.
        //获取4个点的坐标.
        CvPoint pt1 = cvPoint(    i*scaleX, 64*scaleY);
        CvPoint pt2 = cvPoint((i+1)*scaleX, 64*scaleY);
        CvPoint pt3 = cvPoint((i+1)*scaleX, (64 - (nextValue/histMax)*64)*scaleY);
        CvPoint pt4 = cvPoint(    i*scaleX, (64 - (histValue/histMax)*64)*scaleY);
        
        //将这4个点放到一个数组中去.
        int numPts = 5;
        CvPoint pts[5];
        pts[0] = pt1;
        pts[1] = pt2;
        pts[2] = pt3;
        pts[3] = pt4;
        pts[4] = pt1;
        
        cvFillConvexPoly(imgHist, pts, numPts, cvScalar(255));
        
        histSum += histValue;
        NSLog(@"i: %zd --- histValue: %f", i, histValue);
        if (i > 230) {
            histMoreThan200 += histValue;
        }
    }
    
    NSLog(@"histSum = %f, histMoreThan200 = %f ratio = %f", histSum, histMoreThan200, histMoreThan200 / histSum);
    return imgHist;
}


/**
 UIImage 轉換為 灰度圖

 @param src 原始圖片
 @return cv::Mat 類型的灰度圖.
 */
- (cv::Mat)convertToGrayScale:(UIImage *)src
{
    cv::Mat matImage;
    cv::Mat matImageGray;
    UIImageToMat(src, matImage);
    cv::cvtColor(matImage, matImageGray, CV_BGRA2GRAY);
    matImage.release();
    return matImageGray;
}

#pragma mark UIImage 和 IplImage 互相转换

/**
 UIImage -> IplImage

 @param image UIImage
 @return IplImage
 */
-(IplImage*)convertToIplImage:(UIImage*)image
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
- (UIImage *)convertToUIImage:(IplImage *)image
{
    cv::Mat mat = cv::Mat(image);
    return MatToUIImage(mat);
}

@end
