//
//  EZJGradientProgressView.h
//  GradientView
//
//  Created by Maskkk on 2018/7/24.
//  Copyright © 2018 lirenqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NJGradientProgressViewType) {
    NJGradientProgressViewTypeNormal,
    NJGradientProgressViewTypeCritMode,
};

@interface NJGradientProgressView : UIView
- (instancetype)initWithFrame:(CGRect)frame type:(NJGradientProgressViewType)type;
- (void)setType:(NJGradientProgressViewType)type;
@end
