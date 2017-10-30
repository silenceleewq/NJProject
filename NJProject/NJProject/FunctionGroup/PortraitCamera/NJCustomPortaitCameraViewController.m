//
//  NJCustomPortaitCameraViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/14.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJCustomPortaitCameraViewController.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+NJOrientation.h"
#import "NJOpenCVUtils.h"
static CGFloat shadowWidth;
static CGFloat shadowHeight;
static CGFloat shadowMarginY;

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

@interface NJCustomPortaitCameraViewController () {
    AVCaptureStillImageOutput *stillImageOutput;
    UIView *flashView;
    CGFloat effectiveScale;
    dispatch_queue_t videoDataOutputQueue;
    BOOL _firstSetSampleBufferDelegate;
    BOOL headInSpecificArea;
    BOOL captureImageBlur;
}
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) UIButton *snipBtn;
@property (nonatomic, strong) UIImageView *headImageView;
//检测人脸
@property (nonatomic, strong) AVCaptureMetadataOutput *metaDataOutput;
@property (nonatomic, assign) CGRect headImageRect;
@property (nonatomic, strong) UIView *rectangleView;

@property (nonatomic, strong) NJOpenCVUtils *openCVUtil;
@property (nonatomic, strong) UILabel *tipLabel;
@end

@implementation NJCustomPortaitCameraViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idCardType = NJIDCardTypeHead;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"二维码扫描";
    self.view.autoresizingMask = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.hidesBottomBarWhenPushed = YES;
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //判断是否可以使用相机.
    [self checkCameraAvailability:^(BOOL auth) {
        if (!auth) {
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"提示" message:@"没有访问相机权限,\n请到设置中打开权限" preferredStyle:UIAlertControllerStyleAlert];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"立即开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertCtr animated:YES completion:nil];
        }
    }];
    
//    [self initUI:CGRectMake(0, -64, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self initUI:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*1.777)];
    [self addShadowLayer];

    [self.view addSubview:self.snipBtn];
    
    self.openCVUtil = [NJOpenCVUtils sharedManager];
    [self.view addSubview:self.tipLabel];
    _firstSetSampleBufferDelegate = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)initUI:(CGRect)previewFrame
{
    effectiveScale = 1.0;
    // 摄像头设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [self.device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    NSError *error = nil;
    
    // 设置输入口
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    
    if (error|| !self.input) {
        //NSLog(@"手机不支持二维码扫描!");
        return;
    }
    
    // 会话session, 把输入口加入会话
    self.session = [[AVCaptureSession alloc]init];
    
    [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    // 设置输出口，加入session, 设置输出口参数
    self.output = [[AVCaptureVideoDataOutput alloc]init];
    videoDataOutputQueue = dispatch_queue_create("videoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.output setSampleBufferDelegate:self queue:videoDataOutputQueue];
    //    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];// 使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    //添加人脸识别
    [self addFaceTypeRecognize];
    
    //添加still image output
    stillImageOutput = [AVCaptureStillImageOutput new];
    //    [stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:AVCaptureStillImageIsCapturingStillImageContext];
    [stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(AVCaptureStillImageIsCapturingStillImageContext)];
    if ([self.session canAddOutput:stillImageOutput]) {
        [self.session addOutput:stillImageOutput];
    }
    
    // 设置展示层(预览层)
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.backgroundColor = [[UIColor clearColor] CGColor];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspect;
    self.preview.frame = previewFrame;
    [self.view.layer addSublayer:self.preview];
    
    //设置扫码范围
    [self.session startRunning];// 启动session
    
    [self.view addSubview:self.headImageView];

}

- (void)takePhoto{
    AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];

    [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
    
    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG
                                                                    forKey:AVVideoCodecKey]];
    
    [stillImageOutput
     captureStillImageAsynchronouslyFromConnection:stillImageConnection
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         if (error) {
         }
         else {
              NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
              UIImage *img = [UIImage imageWithData:jpegData];
              NSLog(@"%@", img);
              NSLog(@"img.Orientation = %zd", img.imageOrientation);
              if (self.finishedSnip) {
                  img = [self imageFromImage:img inRect:CGRectMake(0, 0, 0, 0)];
                  img = [img normalizedImage];
                  UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
                  self.finishedSnip(img);
                  [self.navigationController popViewControllerAnimated:YES];
              }
          }
      }
     ];
}

// 执行一个闪烁
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"observeValue-------");
    if ( context == (__bridge void * _Nullable)(AVCaptureStillImageIsCapturingStillImageContext) ) {
        BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        
        if ( isCapturingStillImage ) {
            // do flash bulb like animation
            flashView = [[UIView alloc] initWithFrame:[self.preview frame]];
            [flashView setBackgroundColor:[UIColor whiteColor]];
            [flashView setAlpha:0.f];
            [[[self view] window] addSubview:flashView];
            
            [UIView animateWithDuration:.4f
                             animations:^{
                                 [flashView setAlpha:1.f];
                             }
             ];
        }
        else {
            [UIView animateWithDuration:.4f
                             animations:^{
                                 [flashView setAlpha:0.f];
                             }
                             completion:^(BOOL finished){
                                 [flashView removeFromSuperview];
                                 flashView = nil;
                             }
             ];
        }
    }
    
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        NSLog(@"%@", change);
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self updateTipText:@"请将头像对准指定区域内..."];
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        AVMetadataObject *transformedMetadataObject = [self.preview transformedMetadataObjectForMetadataObject:metadataObject];
        CGRect faceRegion = transformedMetadataObject.bounds;
        
        dispatch_async(dispatch_get_main_queue(), ^{
          self.rectangleView.frame = faceRegion;
        });
        
        if (metadataObject.type == AVMetadataObjectTypeFace) {
//            NSLog(@"%d", CGRectContainsRect(self.headImageRect, faceRegion));
//            NSLog(@"faceRegion = %@", NSStringFromCGRect(faceRegion));
//            NSLog(@"headImageFrame = %@", NSStringFromCGRect(self.headImageRect));

            if (CGRectContainsRect(self.headImageRect, faceRegion)) {
                headInSpecificArea = YES;
                //只有人臉區域的確在小框內時,才再去捕獲此時的這一幀圖像.
                if (!self.output.sampleBufferDelegate) {
                    _firstSetSampleBufferDelegate = NO;
                    [self.output setSampleBufferDelegate:self queue:videoDataOutputQueue];
                }
            } else {
                headInSpecificArea = NO;
                //人脸没有在指定区域
                [self updateTipText:@"请将头像对准指定区域内..."];
            }
        }
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (!_firstSetSampleBufferDelegate) {
        [self dealWithCMSampleBufferRef:sampleBuffer];
    }
    
    if (self.output.sampleBufferDelegate) {
        [self.output setSampleBufferDelegate:nil queue:videoDataOutputQueue];
    }
}

- (void)addShadowLayer {
    
    [self.view.layer addSublayer:self.shadowLayer];
    
    UIBezierPath *transparentRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowLayer.frame cornerRadius:self.shadowLayer.cornerRadius];
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.frame];
    [path appendPath:transparentRoundedRectPath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.6;
    
    [self.view.layer addSublayer:fillLayer];
}


- (void)dealloc
{
    NSLog(@"deallooc");
    [stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage"];
    AVCaptureInput* input = [self.session.inputs objectAtIndex:0];
    [self.session removeInput:input];
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[self.session.outputs objectAtIndex:0];
    [self.session removeOutput:output];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.session stopRunning];
    self.session = nil;
    [self.device removeObserver:self forKeyPath:@"adjustingFocus"];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    shadowWidth = self.shadowLayer.bounds.size.width;
    shadowHeight = (self.shadowLayer.bounds.size.width)/1.578;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
}


- (UIButton *)snipBtn
{
    if (!_snipBtn) {
        CGFloat w = KSCREENWIDTH, h = 30;
        CGFloat x = (KSCREENWIDTH - w) / 2, y = (KSCREENHEIGHT - h - 84);
        _snipBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [_snipBtn setTitle:@"SNIP" forState:UIControlStateNormal];
        [_snipBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_snipBtn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    }
    return _snipBtn;
}


// utility routing used during image capture to set up capture orientation
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}


// 检查相机权限
- (void)checkCameraAvailability:(void (^)(BOOL auth))block {
    BOOL status = NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        status = YES;
    } else if (authStatus == AVAuthorizationStatusDenied) {
        status = NO;
    } else if (authStatus == AVAuthorizationStatusRestricted) {
        status = NO;
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                if (block) {
                    block(granted);
                }
            } else {
                if (block) {
                    block(granted);
                }
            }
        }];
        return;
    }
    if (block) {
        block(status);
    }
}

//切图
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    
    CGFloat wScale = shadowWidth / KSCREENWIDTH;
    CGFloat hScale = shadowHeight / KSCREENHEIGHT;
    
    CGImageRef sourceImageRef = [image CGImage];
    size_t sourceImageWidth = CGImageGetWidth(sourceImageRef);
    size_t sourceImageHeight = CGImageGetHeight(sourceImageRef);
    CGFloat newW = hScale * sourceImageWidth;
    CGFloat newH = wScale * sourceImageHeight;
    CGFloat newX = shadowMarginY/(KSCREENWIDTH*1.777) * 1920;
    CGFloat newY = (sourceImageHeight - newH) / 2;
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(newX, newY, newW, newH));
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:0.0 orientation:UIImageOrientationRight];
//    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

#pragma mark - 手势方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self.view];
    [self focusAtPoint:touchPoint];
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = self.device;
    //聚焦
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            //focus Point of Interest
            // (0,0) top left, (1,1)bottom right.
            //convert point into camera device coordinate system.
            CGFloat x = point.x / self.preview.bounds.size.width;
            CGFloat y = point.y / self.preview.bounds.size.height;
            device.focusPointOfInterest = CGPointMake(x, y);
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        else{
            NSLog(@"%@", error.description);
        }
    }
    //曝光
//    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
//    {
//        NSError *error;
//        if ([device lockForConfiguration:&error]) {
//
//        }
//    }
}
#pragma mark - 懒加载
- (CAShapeLayer *)shadowLayer
{
    if (!_shadowLayer) {
        _shadowLayer = [CAShapeLayer layer];
        shadowMarginY = 100;
        _shadowLayer.frame = CGRectMake(5, shadowMarginY, KSCREENWIDTH-10, (KSCREENWIDTH-10)/1.578);
        _shadowLayer.borderColor = [UIColor redColor].CGColor;
        _shadowLayer.borderWidth = 1.5;
        _shadowLayer.cornerRadius = 15;
    }
    return _shadowLayer;
}

- (UIImageView *)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        UIImage *headImage = [UIImage imageNamed:@"idcard_front_head"];
        _headImageView.image = headImage;
        
        _headImageView.frame = self.headImageRect;
//        NSLog(@"%@", NSStringFromCGRect(_headImageView.frame));
        
    }
    return _headImageView;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, KSCREENWIDTH, 40)];
        _tipLabel.textColor = [UIColor redColor];
        _tipLabel.font = [UIFont systemFontOfSize:17];
    }
    return _tipLabel;
}

- (CGRect)headImageRect {
    CGFloat faceWidth = 200;
    CGFloat faceHeight = faceWidth * 0.812;
    CGFloat faceX = CGRectGetMaxX(self.shadowLayer.frame) - faceWidth+10;
    CGFloat faceY = self.shadowLayer.frame.origin.y + 45;
    return CGRectMake(faceX, faceY, faceWidth, faceHeight);
}

- (AVCaptureMetadataOutput *)metaDataOutput
{
    if (!_metaDataOutput) {
        _metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metaDataOutput setMetadataObjectsDelegate:self queue:videoDataOutputQueue];
    }
    return _metaDataOutput;
}

- (UIView *)rectangleView
{
    if (!_rectangleView) {
        _rectangleView = [[UIView alloc] init];
        _rectangleView.layer.borderColor = UIColor.redColor.CGColor;
        _rectangleView.layer.borderWidth = 2;
        _rectangleView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_rectangleView];
    }
    return _rectangleView;
}

- (UIImage *)imageFromCMSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    UIImage * uiimage = [UIImage imageWithCGImage:newImage];
    return uiimage;
}

- (UIImage *)getImageStream:(CVImageBufferRef)imageBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
    
    CGImageRelease(videoImage);
    return image;
}

#pragma mark - 图片处理
- (void)dealWithCMSampleBufferRef:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    UIImage *image = [self getImageStream:imageBuffer];
    
    BOOL blur = [self.openCVUtil checkForBurryImage:image];
    captureImageBlur = blur;
    //模糊检测
    if (blur) {
        [self updateTipText:@"图像模糊,请尝试调整角度..."];
        return;
    } else {
        [self updateTipText:@""];
        return;
    }
    
    //亮暗检测.
    
    
}

#pragma mark - 更新红色矩形
- (void)updateRectangleView
{
    
}

- (void)updateTipText:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipLabel.text = text;
    });
}

#pragma mark - 识别相关代码
- (void)addFaceTypeRecognize
{
    if (self.idCardType != NJIDCardTypeHead) return;
    
    //添加人脸识别output
    if ([self.session canAddOutput:self.metaDataOutput]) {
        [self.session addOutput:self.metaDataOutput];
    }
    self.metaDataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    [self updateTipText:@"请将头像对准指定区域内..."];
}
@end
























