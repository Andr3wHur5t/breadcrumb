//
//  BCScriptTests.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/20/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "Breadcrumb.h"
#import <XCTest/XCTest.h>

@interface BCScriptTests : XCTestCase

@end

@implementation BCScriptTests

#pragma mark Default Scripts
- (void)testStandardTransactionScriptGeneration {
  XCTAssert(
      [[[BCScript
          standardTransactionScript:
              [@"mufBQc5iD1T5dGdfahS7u9vhmg5kpWWXPn" toBitcoinAddress]] toData]
          isEqualToData:@"76a9149b2008e9998794e0ef27a878f57852d2311d091c88ac"
                            .hexToData],
      @"Pass");
}

@end