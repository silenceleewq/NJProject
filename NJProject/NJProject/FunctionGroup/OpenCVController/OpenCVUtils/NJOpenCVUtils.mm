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

using namespace std;
using namespace cv;

#define cvQueryHistValue_1D( hist, idx0 ) \
((float)cvGetReal1D( (hist)->bins, (idx0)))

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
    IplImage *src = [self IplImageFromUIImage:image];
    
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
    
    return [self UIImageFromIplImage:histBlue];
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
    
    return [self UIImageFromIplImage:histGray];
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


#pragma mark - 判断图片是否清晰.
- (BOOL)checkForBurryImage:(UIImage *)srcImage {// Output:(cv::Mat &) outputFrame {
    cv::Mat matImage;
    UIImageToMat(srcImage, matImage);
    
    UIImage *copyImage = MatToUIImage(matImage);
    cv::Mat finalImage;
    
    cv::Mat matImageGrey;
    cv::cvtColor(matImage, matImageGrey, CV_BGRA2GRAY);
    matImage.release();
    
    cv::Mat newEX;
    const int MEDIAN_BLUR_FILTER_SIZE = 15; // odd number
    cv::medianBlur(matImageGrey, newEX, MEDIAN_BLUR_FILTER_SIZE);
    matImageGrey.release();
    
    cv::Mat laplacianImage;
    cv::Laplacian(newEX, laplacianImage, CV_8U); // CV_8U
    newEX.release();
    
    cv::Mat laplacianImage8bit;
    laplacianImage.convertTo(laplacianImage8bit, CV_8UC1);
    laplacianImage.release();
    cv::cvtColor(laplacianImage8bit,finalImage,CV_GRAY2BGRA);
    laplacianImage8bit.release();
    
    int rows = finalImage.rows;
    int cols= finalImage.cols;
    char *pixels = reinterpret_cast<char *>( finalImage.data);
    int maxLap = -16777216;
    for (int i = 0; i < (rows*cols); i++) {
        if (pixels[i] > maxLap)
            maxLap = pixels[i];
    }
    
    int soglia = -6118750;
    
    pixels=NULL;
    finalImage.release();
    //这里差不多上50就不算模糊了
    BOOL isBlur = (maxLap < 50)?  YES :  NO;
    NSString *text;
    if (isBlur) {
        NSLog(@"模糊");
        text = [@(maxLap).stringValue stringByAppendingString:@"  模糊"];
    } else {
        NSLog(@"不模糊");
        text = [@(maxLap).stringValue stringByAppendingString:@"  不模糊"];
    }
    NSLog(@"maxLap: %zd", maxLap);
    //    [self drawText:text onImage:copyImage];
    return isBlur;
}

//扫描身份证图片，并进行预处理，定位号码区域图片并返回
- (NSArray<UIImage *> *)opencvScanCard:(UIImage *)image {
    NSMutableArray *imgArrM = [NSMutableArray arrayWithCapacity:2];
    //将UIImage转换成Mat
    cv::Mat resultImage;
    UIImageToMat(image, resultImage);
    //转为灰度图
    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
    //利用阈值二值化
    cv::threshold(resultImage, resultImage, 100, 255, CV_THRESH_BINARY);
    //腐蚀，填充（腐蚀是让黑色点变大）
    cv::Mat erodeElement = getStructuringElement(cv::MORPH_RECT, cv::Size(50,50));
    cv::erode(resultImage, resultImage, erodeElement);
    [imgArrM addObject:MatToUIImage(resultImage)];
    /*** lrq ***/
//    return MatToUIImage(resultImage);
    /*** lrq ***/
    //轮廊检测
    std::vector<std::vector<cv::Point>> contours;//定义一个容器来存储所有检测到的轮廊
    cv::findContours(resultImage, contours, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
    cv::drawContours(resultImage, contours, -1, cv::Scalar(255),4);
    /*** lrq ***/
//    return MatToUIImage(resultImage);
    /*** lrq ***/
//    [imgArrM addObject:MatToUIImage(resultImage)];
    //取出身份证号码区域
    std::vector<cv::Rect> rects;
    cv::Rect numberRect = cv::Rect(0,0,0,0);
    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
    for ( ; itContours != contours.end(); ++itContours) {
        cv::Rect rect = cv::boundingRect(*itContours);
        rects.push_back(rect);
        //算法原理
        if (rect.width > numberRect.width && rect.width > rect.height * 5) {
            numberRect = rect;
        }
    }
    //身份证号码定位失败
    if (numberRect.width == 0 || numberRect.height == 0) {
        return nil;
    }//1236/781
    //定位成功，去原图截取身份证号码区域，并转换成灰度图、进行二值化处理
    cv::Mat matImage;
    UIImageToMat(image, matImage);
//    cv::Rect numberRect1 = cv::Rect(0,0,1236,781);
    resultImage = matImage(numberRect);
    /*** lrq ***/
//    return MatToUIImage(resultImage);
    /*** lrq ***/
    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
    cv::threshold(resultImage, resultImage, 80, 255, CV_THRESH_BINARY);
    //将Mat转换成UIImage
    UIImage *numberImage = MatToUIImage(resultImage);
//    return numberImage;
    [imgArrM addObject:numberImage];
    return imgArrM.copy;
}

- (void)calculateAverageBrightness:(UIImage *)image
{
    cv::Mat m;
    UIImageToMat(image, m);
    cv::cvtColor(m, m, CV_BGR2GRAY);
    Scalar s = cv::mean(m);
}

#pragma mark - 模板匹配
- (void)templateMatching:(UIImage *)srcImage complete:(NJTemplateMatchingCompleteBlock)completeBlock
{
    //模板图片
    //身份证号码
    NSString *target_path = [[NSBundle mainBundle] pathForResource:@"emblem" ofType:@".png"];
    UIImage *target_image = [UIImage imageWithContentsOfFile:target_path];
    
    
    IplImage *src = [self IplImageFromUIImage:srcImage];
    IplImage *srcResult = [self IplImageFromUIImage:srcImage];
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
    

    
    double minValue, maxValue;
    CvPoint minLoc, maxLoc;
    
    cvMatchTemplate(src, templat, result, CV_TM_SQDIFF);
    cvMinMaxLoc(result, &minValue, &maxValue, &minLoc, &maxLoc);
    
    cvRectangle(srcResult, minLoc, cvPoint(minLoc.x + templatW, minLoc.y+ templatH), cvScalar(0,0,255));
    
    /***************************** 姓名模板识别 *****************************/
    //姓名模板
    /*
    NSString *name_path = [[NSBundle mainBundle] pathForResource:@"name" ofType:@".png"];
    UIImage *name_image = [UIImage imageWithContentsOfFile:name_path];
    IplImage *nameTemplate = [self IplImageFromUIImage:name_image];
    int nameW = nameTemplate->width, nameH = nameTemplate->height;
    IplImage *nameResult;
    int nameResultW = srcW - nameW + 1, nameResultH = srcH - nameH + 1;
    nameResult = cvCreateImage(cvSize(nameResultW, nameResultH), 32, 1);
    CvPoint nameMinLoc;
    cvMatchTemplate(src, nameTemplate, nameResult, CV_TM_SQDIFF);
    cvMinMaxLoc(nameResult, &minValue, &maxValue, &nameMinLoc, &maxLoc);
    cvRectangle(srcResult, nameMinLoc, cvPoint(nameMinLoc.x + nameW, nameMinLoc.y+ nameH), cvScalar(0,255,255));
    */
    
    
//    CvPoint minLoc1, maxLoc1;
//    IplImage *result1 = [self resultImageFromIplImage:nameipl srcImage:src];
//    cvMatchTemplate(src, nameipl, result1, CV_TM_SQDIFF);
//    cvMinMaxLoc(result, &minValue, &maxValue, &minLoc1, &maxLoc1);
//    cvRectangle(srcResult, minLoc1, cvPoint(minLoc1.x + nameipl->width, minLoc1.y+ nameipl->height), cvScalar(0,0,255));
    
//    CvPoint minLoc2, maxLoc2;
//    IplImage *result2 = [self resultImageFromIplImage:genderipl srcImage:src];
//    cvMatchTemplate(src, genderipl, result2, CV_TM_SQDIFF);
//    cvMinMaxLoc(result, &minValue, &maxValue, &minLoc2, &maxLoc2);
//    cvRectangle(srcResult, minLoc2, cvPoint(minLoc2.x + genderipl->width, minLoc2.y+ genderipl->height), cvScalar(0,0,255));
    
    if (completeBlock != nil) {
        completeBlock([self UIImageFromIplImage:srcResult], [self UIImageFromIplImage:templat]);
    }
    
    cvReleaseImage(&result);
    cvReleaseImage(&templat);
    cvReleaseImage(&srcResult);
    cvReleaseImage(&src);
}

- (IplImage *)resultImageFromIplImage:(IplImage *)iplImage srcImage:(IplImage *)src
{
    IplImage *result;
    
    int iplW = iplImage->width;
    int iplH = iplImage->height;
    int srcW = src->width, srcH = src->height;
    result = cvCreateImage(cvSize((srcW-iplW)+1, (srcH-iplH)+1), 32, 1);
    

    
    return result;
}

@end
