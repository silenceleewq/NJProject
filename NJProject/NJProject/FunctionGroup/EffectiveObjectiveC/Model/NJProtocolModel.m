//
//  NJProtocolModel.m
//  NJProject
//
//  Created by lirenqiang on 2017/12/29.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJProtocolModel.h"

NSString *const NJProtocolErrorDomain = @"NJProtocolErrorDomain";

@interface NJProtocolModel () {
    struct {
        unsigned int didReceivedData: 1;
        unsigned int didFailed: 1;
    } _delegateFlags;
}

@end

@implementation NJProtocolModel

- (void)setDelegate:(id<NJProtocolDelegate>)delegate
{
    _delegate = delegate;
    
    _delegateFlags.didReceivedData = [_delegate respondsToSelector:@selector(NJProtocol:didReceivedData:)];
    _delegateFlags.didFailed = [_delegate respondsToSelector:@selector(NJProtocol:didFailed:)];
}


- (void)sendDelegateAction {
    
    if (_delegateFlags.didReceivedData) {
        NSData *data = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
        [_delegate NJProtocol:self didReceivedData:data];
    }
    
    if (_delegateFlags.didFailed) {
        NSError *error = [NSError errorWithDomain:NJProtocolErrorDomain code:0 userInfo:nil];
        [_delegate NJProtocol:self didFailed:error];
    }
    
}



@end
