//
//  NJOpenCVBaseViewController.h
//  NJProject
//
//  Created by lirenqiang on 2017/9/28.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJOpenCVUtils.h"
@interface NJOpenCVBaseViewController : UIViewController
@property (nonatomic, strong) UIImageView *originalImgView;
@property (nonatomic, strong) UIImageView *changedImgView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) NJOpenCVUtils *utilManager;
@end
