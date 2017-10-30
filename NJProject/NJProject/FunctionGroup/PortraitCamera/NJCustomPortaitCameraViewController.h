//
//  NJCustomPortaitCameraViewController.h
//  NJProject
//
//  Created by lirenqiang on 2017/9/14.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, NJIDCardType) {
    NJIDCardTypeHead,
    NJIDCardTypeEmblem,
};

typedef void(^imageBlock)(UIImage *image);

@interface NJCustomPortaitCameraViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong,nonatomic)AVCaptureDevice *device;

@property (strong,nonatomic)AVCaptureVideoDataOutput *output;

@property (strong,nonatomic)AVCaptureDeviceInput *input;

@property (strong, nonatomic)AVCaptureSession *session;

@property (strong, nonatomic)AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong)imageBlock finishedSnip;

@property (nonatomic, assign) NJIDCardType idCardType;

@end
