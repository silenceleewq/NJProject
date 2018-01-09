//
//  NJProtocolModel.h
//  NJProject
//
//  Created by lirenqiang on 2017/12/29.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const NJProtocolErrorDomain;
@class NJProtocolModel;
@protocol NJProtocolDelegate <NSObject>

@optional
- (void)NJProtocol:(NJProtocolModel *)model didReceivedData:(NSData *)data;

- (void)NJProtocol:(NJProtocolModel *)model didFailed:(NSError *)error;

@end

@interface NJProtocolModel : NSObject

@property (weak, nonatomic) id <NJProtocolDelegate> delegate;

- (void)sendDelegateAction;

@end
