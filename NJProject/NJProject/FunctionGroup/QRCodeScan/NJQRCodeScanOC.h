//
//  NJQRCodeScanOC.h
//  NJProject
//
//  Created by slience on 2017/6/20.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol NJQRCodeScanOCDelegate <NSObject>

- (void)qrCodeComplete:(NSString *)codeString;
@optional
- (void)qrCodeError:(NSError *)error;

@end

@interface NJQRCodeScanOC : UIViewController <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak  ,nonatomic)id<NJQRCodeScanOCDelegate> delegate;

@property (strong,nonatomic)AVCaptureDevice *device;

@property (strong,nonatomic)AVCaptureMetadataOutput *output;

@property (strong,nonatomic)AVCaptureDeviceInput *input;

@property (strong, nonatomic)AVCaptureSession *session;

@property (strong, nonatomic)AVCaptureVideoPreviewLayer *preview;

@end
