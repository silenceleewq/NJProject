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
}
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) UIButton *snipBtn;

@end

@implementation NJCustomPortaitCameraViewController

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
    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"SNIP" style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto)];
//    self.navigationItem.rightBarButtonItem = item;
    [self.view addSubview:self.snipBtn];
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
//    if ([UIScreen mainScreen].bounds.size.height == 480)
//    {
//        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
//    }
//    else
//    {
//        [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
//    }
    
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
    
    //    self.output.rectOfInterest = CGRectMake((self.view.bounds.size.height * 0.5 - 140-64)/KSCREENHEIGHT,(1-280/KSCREENWIDTH)/2,280/KSCREENHEIGHT,280/KSCREENWIDTH);
    [self.session startRunning];// 启动session
}

- (void)takePhoto{
    //    [self.session stopRunning];
    //    self.session = nil;
    //    [self.navigationController popViewControllerAnimated:YES];
    //    return;
    AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
//    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
    
    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG
                                                                    forKey:AVVideoCodecKey]];
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                      if (error) {
                                                          //                                                          [self displayErrorOnMainQueue:error withMessage:@"Take picture failed"];
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


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

- (void)addShadowLayer {
    
    self.shadowLayer = [CAShapeLayer layer];
    shadowMarginY = 100;
    self.shadowLayer.frame = CGRectMake(5, shadowMarginY, KSCREENWIDTH-10, (KSCREENWIDTH-10)/1.578);
    self.shadowLayer.borderColor = [UIColor redColor].CGColor;
    self.shadowLayer.borderWidth = 1.5;
    self.shadowLayer.cornerRadius = 15;
    [self.view.layer addSublayer:self.shadowLayer];
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


@end
