//
//  NJEncode&EncryptionTests.m
//  NJProjectTests
//
//  Created by Maskkk on 2018/7/24.
//  Copyright © 2018 Ninja. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Base64.h"
@interface NJEncode_EncryptionTests : XCTestCase

@end

@implementation NJEncode_EncryptionTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testBase64 {
    NSString *str = @"hello!";
    NSString *encode = [str base64EncodedString];
    NSAssert([encode isEqualToString:@"aGVsbG8h"], @"编码错误");
    NSLog(@"ecode = %@", encode);
    NSString *decode = [encode base64DecodedString];
    NSLog(@"decode = %@", decode);
}

@end
























