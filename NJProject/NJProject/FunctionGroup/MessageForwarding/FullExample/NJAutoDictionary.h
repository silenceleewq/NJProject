//
//  NJAutoDictionary.h
//  NJProject
//
//  Created by lirenqiang on 2017/12/26.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NJAutoDictionary : NSObject

@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) id opaqueObject;

@end
