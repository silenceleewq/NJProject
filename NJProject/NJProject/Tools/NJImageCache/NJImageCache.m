//
//  NJImageCache.m
//  NJProject
//
//  Created by lirenqiang on 2017/10/24.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJImageCache.h"

@interface NJCache: NSCache

@end

@implementation NJCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end

@interface NJImageCache ()

@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, copy) NSString *diskCachePath;
@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end

@implementation NJImageCache

+ (instancetype)sharedImageCache
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    NSString *namespace = @"default";
    NSString *path = [self makeDiskCachePath:namespace];
    return [self initWithNameSapce:namespace diskCacheDirectory:path];
}

- (instancetype)initWithNameSapce:(NSString *)ns diskCacheDirectory:(NSString *)directory
{
    self = [super init];
    
    if (self) {
        NSString *fullNameSpace = [@"com.ninja." stringByAppendingString:ns];
        
        //Create IO serial queue
        _ioQueue = dispatch_queue_create("com.ninja", DISPATCH_QUEUE_SERIAL);
        
        _memCache = [[NJCache alloc] init];
        _memCache.name = fullNameSpace;
        
        if (directory) {
            _diskCachePath = [directory stringByAppendingString:fullNameSpace];
        } 
    }
    
    return self;
}

- (NSString *)makeDiskCachePath:(NSString *)fullNameSpace
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:fullNameSpace];
}

@end

























