//
//  NJErrorModel.h
//  NJProject
//
//  Created by lirenqiang on 2017/12/29.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const NJLowerStringErrorDomain;

@interface NJErrorModel : NSObject

- (BOOL)lowerString:(NSString *)string :(NSError **)error;

@end
