//
//  NJCustomCameraViewController.h
//  NJProject
//
//  Created by lirenqiang on 2017/9/14.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^imageBlock)(UIImage *image);

@interface NJCustomCameraViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>


@property (nonatomic, strong)imageBlock finishedSnip;
@end
