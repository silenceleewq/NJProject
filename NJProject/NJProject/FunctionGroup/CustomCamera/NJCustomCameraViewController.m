//
//  NJCustomCameraViewController.m
//  NJProject
//
//  Created by lirenqiang on 2017/9/14.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJCustomCameraViewController.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NJOpenCVUtils.h"
// iPhone5/5c/5s/SE 4英寸 屏幕宽高：320*568点 屏幕模式：2x 分辨率：1136*640像素
#define iPhone5or5cor5sorSE ([UIScreen mainScreen].bounds.size.height == 568.0)

// iPhone6/6s/7 4.7英寸 屏幕宽高：375*667点 屏幕模式：2x 分辨率：1334*750像素
#define iPhone6or6sor7 ([UIScreen mainScreen].bounds.size.height == 667.0)

// iPhone6 Plus/6s Plus/7 Plus 5.5英寸 屏幕宽高：414*736点 屏幕模式：3x 分辨率：1920*1080像素
#define iPhone6Plusor6sPlusor7Plus ([UIScreen mainScreen].bounds.size.height == 736.0)

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";
//static CGFloat shadowWidth = 240.0;
CGFloat shadowWidth;
CGFloat shadowHeight;

@interface NJCustomCameraViewController () {
    AVCaptureStillImageOutput *stillImageOutput;
    UIView *flashView;
    CGFloat effectiveScale;
    dispatch_queue_t videoDataOutputQueue;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureVideoPreviewLayer *previewLayer;

}
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) UIButton *snipBtn;
@property (nonatomic, strong) AVCaptureMetadataOutput *metaDataOutput;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (strong, nonatomic)AVCaptureDevice *device;

@property (strong, nonatomic)AVCaptureDeviceInput *input;
@property (strong, nonatomic)AVCaptureSession *session;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) NSNumber *outPutSetting;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, assign) CGRect faceDetectionFrame;

@property (nonatomic, strong) NJOpenCVUtils *utilManager;
@end

@implementation NJCustomCameraViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"扫描身份证";
    self.view.autoresizingMask = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor whiteColor];
//    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom;
    
    
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
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"SNIP" style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto)];
    UIBarButtonItem *torch = [[UIBarButtonItem alloc] initWithTitle:@"torch" style:UIBarButtonItemStylePlain target:self action:@selector(torchClick)];
    self.navigationItem.rightBarButtonItems = @[item, torch];

}

- (void)torchClick
{
    if ([self.device hasTorch]) {
        if (self.device.isTorchActive) {
            [self.device lockForConfiguration:nil];
            [self.device setTorchMode:AVCaptureTorchModeOff];
            [self.device unlockForConfiguration];
        } else {
            [self.device lockForConfiguration:nil];
            [self.device setTorchMode:AVCaptureTorchModeOn];
            [self.device unlockForConfiguration];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    shadowWidth = iPhone5or5cor5sorSE? 240: (iPhone6or6sor7? 270: 300);
    shadowHeight = shadowWidth * 1.578;
    [self setupAVCapture];
    [self addShadowLayer];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
}

#pragma mark 设置
- (void)setupAVCapture
{
    NSError *error = nil;
    //会话
    AVCaptureSession *session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    
    //输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.device = device;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

    //添加KVO进行监听聚焦
    [self.device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    
    
    if ([session canAddInput:deviceInput]) [session addInput:deviceInput];
    
    //静态图片输出
    stillImageOutput = [AVCaptureStillImageOutput new];
    [stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(AVCaptureStillImageIsCapturingStillImageContext)];
    if ([session canAddOutput:stillImageOutput]) [session addOutput:stillImageOutput];
    
    //视频数据输出
    videoDataOutput = [AVCaptureVideoDataOutput new];
    //BGRA, CoreGraphics和OpenGL对 'BGRA' 都很友好.
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    if ([session canAddOutput:videoDataOutput]) [session addOutput:videoDataOutput];
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    
    //设置人脸识别类型
    if ([session canAddOutput:self.metaDataOutput]) [session addOutput:self.metaDataOutput];
    self.metaDataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    
    effectiveScale = 1.0;
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setBackgroundColor:[UIColor redColor].CGColor];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setFrame:self.view.bounds];
    [self.view.layer addSublayer:previewLayer];
    [session startRunning];
    
    
    //MARK: 添加头像
    [self.view addSubview:self.headImageView];
}

#pragma mark 运行session
- (void)runSession {
    if (![self.session isRunning]) {
        dispatch_async(self.queue, ^{
            [self.session startRunning];
        });
    }
}

#pragma mark 禁止session
- (void)stopSession {
    if ([self.session isRunning]) {
        dispatch_async(self.queue, ^{
            [self.session stopRunning];
        });
    }
}

- (void)takePhoto{
    AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
    
    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG
                                                                    forKey:AVVideoCodecKey]];
    
    [stillImageOutput
     captureStillImageAsynchronouslyFromConnection:stillImageConnection
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
         {
             if (error) {
             }
             else {
                 NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 UIImage *img = [UIImage imageWithData:jpegData];
                 NSLog(@"%@", img);
                 if (self.finishedSnip) {
                     img = [self imageFromImage:img inRect:CGRectMake(0, 0, 0, 0)];
                     img = [UIImage imageWithCGImage:img.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                     self.finishedSnip(img);
                     
                     UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
             }
         }
     ];
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
    CGFloat newX = (sourceImageWidth - newW) / 2;
    CGFloat newY = (sourceImageHeight - newH) / 2;

    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(newX, newY, newW, newH));
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

//剪切一个小图来.
- (UIImage *)getSubImage:(CGRect)rect
                 inImage:(UIImage*)image
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, smallBounds, subImageRef);
    
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CFRelease(subImageRef);
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}

- (CGRect)getSubImageRect {
    
    CGFloat w = shadowWidth;
    CGFloat h = w * 1.578;
    CGFloat wRatio = w / KSCREENWIDTH, hRatio = h / KSCREENHEIGHT;
    CGFloat subW = wRatio * 720, subH = hRatio * 1280;
    CGFloat subX = 720/2 - subW/2, subY = 1280/2 - subH/2;
    
    return CGRectMake(subX, subY, subW, subH);
}

#pragma mark - KVO监听
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
        NSLog(@"");
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        AVMetadataObject *transformedMetadataObject = [previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        CGRect faceRegion = transformedMetadataObject.bounds;
        if (metadataObject.type == AVMetadataObjectTypeFace) {
            NSLog(@": %d, facePathRect: %@, faceRegion: %@", CGRectContainsRect(self.faceDetectionFrame, faceRegion), NSStringFromCGRect(self.faceDetectionFrame), NSStringFromCGRect(faceRegion));
            if (CGRectContainsRect(self.faceDetectionFrame, faceRegion)) {
                //只有人臉區域的確在小框內時,才再去捕獲此時的這一幀圖像.
                NSLog(@"-------------可以捕獲此時的這一幀圖像了-----------");
            }
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

- (void)addShadowLayer {
    [self.view.layer addSublayer:self.shadowLayer];
}


- (void)dealloc
{

    [stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage"];
    [self.device removeObserver:self forKeyPath:@"adjustingFocus"];
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

#pragma mark - 懒加载
- (UIImageView *)headImageView
{
    if (!_headImageView) {
        CGFloat facePathWidth = iPhone5or5cor5sorSE? 125: (iPhone6or6sor7? 150: 180);

        CGFloat facePathHeight = facePathWidth * 0.812;
        CGRect rect = self.shadowLayer.frame;
        CGRect frame = (CGRect){CGRectGetMaxX(rect) - facePathWidth - 35,CGRectGetMaxY(rect) - facePathHeight - 25,facePathWidth,facePathHeight};
        self.faceDetectionFrame = frame;
        _headImageView = [[UIImageView alloc] initWithFrame:frame];
        _headImageView.image = [UIImage imageNamed:@"idcard_front_head"];
        _headImageView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        _headImageView.contentMode = UIViewContentModeScaleToFill;
        
        UIBezierPath *facePath = [UIBezierPath bezierPathWithRect:frame];
        facePath.lineWidth = 1.5;
        [UIColor whiteColor];
        [facePath stroke];
        
        CAShapeLayer *faceLayer = [CAShapeLayer layer];
        faceLayer.frame = frame;
        faceLayer.borderColor = [UIColor whiteColor].CGColor;
        faceLayer.borderWidth = 1.5;
        faceLayer.cornerRadius = 0;
        [self.view.layer addSublayer:faceLayer];
    }
    return _headImageView;
}

- (CAShapeLayer *)shadowLayer
{
    if (!_shadowLayer) {
        _shadowLayer = [CAShapeLayer layer];
        _shadowLayer.bounds = CGRectMake(0, 0, shadowWidth, shadowHeight);
        _shadowLayer.position = self.view.layer.position;
        _shadowLayer.borderColor = [UIColor redColor].CGColor;
        _shadowLayer.borderWidth = 1.5;
        _shadowLayer.cornerRadius = 15;
    }
    return _shadowLayer;
}

- (AVCaptureMetadataOutput *)metaDataOutput
{
    if (!_metaDataOutput) {
        _metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metaDataOutput setMetadataObjectsDelegate:self queue:self.queue];
    }
    return _metaDataOutput;
}

- (dispatch_queue_t)queue
{
    if (!_queue) {
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _queue;
}


@end






















