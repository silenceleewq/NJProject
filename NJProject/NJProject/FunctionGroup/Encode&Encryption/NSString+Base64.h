//
//  NSString+Base64.h
//  NJProject
//
//  Created by Maskkk on 2018/7/24.
//  Copyright © 2018 Ninja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

- (NSString *)base64EncodedString;

- (NSString *)base64DecodedString;

@end
