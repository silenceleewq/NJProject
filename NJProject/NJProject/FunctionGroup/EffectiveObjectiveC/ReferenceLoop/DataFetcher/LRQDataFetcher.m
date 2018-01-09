//
//  LRQDataFetcher.m
//  LRQTest
//
//  Created by lirenqiang on 2018/1/8.
//  Copyright © 2018年 lirenqiang. All rights reserved.
//

#import "LRQDataFetcher.h"

@implementation LRQDataFetcher {
    LRQDataFetcherHandler _fetcherHandler;
}

- (void)completionHandler:(LRQDataFetcherHandler)handler excute:(BOOL)excute
{
    _fetcherHandler = handler;
    if (excute) {
        if (handler) {
            handler();
        }
    }
}

@end
