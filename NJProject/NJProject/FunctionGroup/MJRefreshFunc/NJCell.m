//
//  NJCell.m
//  NJProject
//
//  Created by lirenqiang on 2017/7/7.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJCell.h"

@implementation NJCell

//- (instancetype)initWithFrame:(CGRect)frame {
//    self  = [super initWithFrame:frame];
//    if (self) {
//        CALayer *iconLayer = [[CALayer alloc] init];
//        UIImage *img = [UIImage imageNamed:@"NJCellImg"];
//        iconLayer.contents = (__bridge id _Nullable)(img.CGImage);
//        iconLayer.frame = CGRectMake(8, 8, frame.size.height-16, 40);
//        [self.layer addSublayer:iconLayer];
//    }
//    return self;
//}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CALayer *iconLayer = [[CALayer alloc] init];
        UIImage *img = [UIImage imageNamed:@"nice"];
        iconLayer.contents = (__bridge id _Nullable)(img.CGImage);
        iconLayer.frame = CGRectMake(8, 8, 28, 44-16);
        [self.layer addSublayer:iconLayer];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end



















