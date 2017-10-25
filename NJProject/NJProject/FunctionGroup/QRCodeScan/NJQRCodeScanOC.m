//
//  NJQRCodeScanOC.m
//  NJProject
//
//  Created by slience on 2017/6/20.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJQRCodeScanOC.h"

@interface NJQRCodeScanOC ()
{
    NSTimer *_timer;
    UIImageView *_imageView;
    
    UIImageView *_lineImageView;
    NSString *infoStr;
    CAShapeLayer *_IDCardScanningWindowLayer;
}
@end

@implementation NJQRCodeScanOC

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"二维码扫描";
    self.view.autoresizingMask = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.hidesBottomBarWhenPushed = YES;
    
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
}

// 识别到二维码 并解析转换为字符串
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    [self.session stopRunning];
    [self.preview removeFromSuperlayer];
    [_timer invalidate];
    if (metadataObjects != nil && metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *val = nil;
        
        if ([obj respondsToSelector:@selector(stringValue)]) {
            val = [(AVMetadataMachineReadableCodeObject *)obj stringValue];
        }
        //        [self qrCodeCompletion:val];
        [self.navigationController popViewControllerAnimated:NO];
        if ([self.delegate respondsToSelector:@selector(qrCodeComplete:)]) {
            [self.delegate qrCodeComplete:val];
            [self.session stopRunning];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"sample Buffer%@", sampleBuffer);
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initUiConfig];
    [self addShadowLayer];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_timer invalidate];
}

- (void)initUiConfig
{
    [self initUI:CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height)];
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg"]];
    _imageView.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 140, self.view.bounds.size.height * 0.5 - 140-64, 280, 280);
    [self.view addSubview:_imageView];
    
    
    _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    _lineImageView.image = [UIImage imageNamed:@"lineEWM"];
    [_imageView addSubview:_lineImageView];
    
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClick:)];
    //    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    //
    
    [self animation];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.4 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}

- (void)initUI:(CGRect)previewFrame
{
    // 摄像头设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    
    // 设置输入口
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    
    if (error|| !self.input) {
        
        if ([self.delegate respondsToSelector:@selector(qrCodeError:)]) {
            [self.delegate qrCodeError:error];
            [self.session stopRunning];
        }
        
        //NSLog(@"手机不支持二维码扫描!");
        return;
    }
    
    // 会话session, 把输入口加入会话
    self.session = [[AVCaptureSession alloc]init];
    
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    // 设置输出口，加入session, 设置输出口参数
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];// 使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
//    self.output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode];
    
    // 设置展示层(预览层)
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = previewFrame;
    
    [self.view.layer addSublayer:self.preview];
    
    if ([UIScreen mainScreen].bounds.size.height == 480)
    {
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    else
    {
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    //设置扫码范围
    
    self.output.rectOfInterest = CGRectMake((self.view.bounds.size.height * 0.5 - 140-64)/KSCREENHEIGHT,(1-280/KSCREENWIDTH)/2,280/KSCREENHEIGHT,280/KSCREENWIDTH);
    [self.session startRunning];// 启动session
}

- (void)animation
{
    [UIView animateWithDuration:1.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        _lineImageView.frame = CGRectMake(30, 260, 220, 2);
        
    } completion:^(BOOL finished) {
        _lineImageView.frame = CGRectMake(30, 10, 220, 2);
    }];
}

- (void)addShadowLayer {
    _IDCardScanningWindowLayer =  [CAShapeLayer layer];
    _IDCardScanningWindowLayer.position = self.view.layer.position;
//    CGFloat width = iPhone5or5cor5sorSE? 240: (iPhone6or6sor7? 270: 300);
    CGFloat width = 200;
    _IDCardScanningWindowLayer.bounds = (CGRect){CGPointZero, {width, width}};
    _IDCardScanningWindowLayer.cornerRadius = 15;
    _IDCardScanningWindowLayer.borderColor = [UIColor whiteColor].CGColor;
    _IDCardScanningWindowLayer.borderWidth = 1.5;
    [self.view.layer addSublayer:_IDCardScanningWindowLayer];
    
//    // 最里层镂空
    UIBezierPath *transparentRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:_IDCardScanningWindowLayer.frame cornerRadius:_IDCardScanningWindowLayer.cornerRadius];
    
    // 最外层背景
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

@end
