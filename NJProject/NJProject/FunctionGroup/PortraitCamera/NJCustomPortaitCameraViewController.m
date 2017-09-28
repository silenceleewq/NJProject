//
//  NJCustomPortaitCameraViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/14.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJCustomPortaitCameraViewController.h"
#import <ImageIO/ImageIO.h>

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
    
    NSError *error = nil;
    
    // 设置输入口
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    
    if (error|| !self.input) {
        
        //NSLog(@"手机不支持二维码扫描!");
        return;
    }
    
    // 会话session, 把输入口加入会话
    self.session = [[AVCaptureSession alloc]init];
    if ([UIScreen mainScreen].bounds.size.height == 480)
    {
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    else
    {
        [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
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
    self.preview.backgroundColor = [[UIColor redColor] CGColor];
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
                                                          /*
                                                           if (doingFaceDetection) {
                                                           // Got an image.
                                                           CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
                                                           CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
                                                           CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
                                                           if (attachments)
                                                           CFRelease(attachments);
                                                           
                                                           NSDictionary *imageOptions = nil;
                                                           NSNumber *orientation = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyOrientation, NULL);
                                                           if (orientation) {
                                                           imageOptions = [NSDictionary dictionaryWithObject:orientation forKey:CIDetectorImageOrientation];
                                                           }
                                                           
                                                           // when processing an existing frame we want any new frames to be automatically dropped
                                                           // queueing this block to execute on the videoDataOutputQueue serial queue ensures this
                                                           // see the header doc for setSampleBufferDelegate:queue: for more information
                                                           dispatch_sync(videoDataOutputQueue, ^(void) {
                                                           
                                                           // get the array of CIFeature instances in the given image with a orientation passed in
                                                           // the detection will be done based on the orientation but the coordinates in the returned features will
                                                           // still be based on those of the image.
                                                           NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
                                                           CGImageRef srcImage = NULL;
                                                           OSStatus err = CreateCGImageFromCVPixelBuffer(CMSampleBufferGetImageBuffer(imageDataSampleBuffer), &srcImage);
                                                           check(!err);
                                                           
                                                           CGImageRef cgImageResult = [self newSquareOverlayedImageForFeatures:features
                                                           inCGImage:srcImage
                                                           withOrientation:curDeviceOrientation
                                                           frontFacing:isUsingFrontFacingCamera];
                                                           if (srcImage)
                                                           CFRelease(srcImage);
                                                           
                                                           CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                           imageDataSampleBuffer,
                                                           kCMAttachmentMode_ShouldPropagate);
                                                           [self writeCGImageToCameraRoll:cgImageResult withMetadata:(id)attachments];
                                                           if (attachments)
                                                           CFRelease(attachments);
                                                           if (cgImageResult)
                                                           CFRelease(cgImageResult);
                                                           
                                                           });
                                                           
                                                           [ciImage release];
                                                           }
                                                           else {*/
                                                          // trivial simple JPEG case
                                                          
                                                          
                                                          NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                          UIImage *img = [UIImage imageWithData:jpegData];
                                                          NSLog(@"%@", img);
                                                          if (self.finishedSnip) {
//                                                              img = [UIImage imageWithCGImage:img.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                                                              self.finishedSnip(img);
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                              //                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }
                                                          //                                                              CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                          //                                                                                                                          imageDataSampleBuffer,
                                                          //                                                                                                                          kCMAttachmentMode_ShouldPropagate);
                                                          //                                                              ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                                          //                                                              [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
                                                          //                                                                  if (error) {
                                                          //                                                                      [self displayErrorOnMainQueue:error withMessage:@"Save to camera roll failed"];
                                                          //                                                                  }
                                                          //                                                              }];
                                                          //
                                                          //                                                              if (attachments)
                                                          //                                                                  CFRelease(attachments);
                                                          //                                                              [library release];
                                                          /*}*/
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
    
    [self initUI:CGRectMake(0, 0, KSCREENWIDTH, KSCREENWIDTH/1.578)];
//    [self addShadowLayer];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"SNIP" style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto)];
    self.navigationItem.rightBarButtonItem = item;
    //    [self.view addSubview:self.snipBtn];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

- (void)addShadowLayer {
    
    self.shadowLayer = [CAShapeLayer layer];
    self.shadowLayer.bounds = CGRectMake(0, 0, 240, 240*1.578);
    self.shadowLayer.position = self.view.layer.position;
    self.shadowLayer.borderColor = [UIColor redColor].CGColor;
    self.shadowLayer.borderWidth = 1.5;
    self.shadowLayer.cornerRadius = 15;
    [self.view.layer addSublayer:self.shadowLayer];
    
    
    //    CGRect limitRect = CGRectMake(0, 0, 240, 240*1.578);
    //    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:limitRect cornerRadius:15];
    
    
    
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
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
}


- (UIButton *)snipBtn
{
    if (!_snipBtn) {
        CGFloat w = 60, h = 30;
        CGFloat x = (KSCREENWIDTH - w) / 2, y = (KSCREENHEIGHT - h - 20);
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


@end
