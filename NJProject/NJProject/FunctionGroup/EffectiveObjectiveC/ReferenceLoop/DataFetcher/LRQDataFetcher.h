//
//  LRQDataFetcher.h
//  LRQTest
//
//  Created by lirenqiang on 2018/1/8.
//  Copyright © 2018年 lirenqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LRQDataFetcherHandler)(void);

@interface LRQDataFetcher : NSObject

- (void)completionHandler:(LRQDataFetcherHandler)handler excute:(BOOL)excute;

@end
