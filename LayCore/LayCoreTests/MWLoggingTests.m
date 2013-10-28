//
//  MWLoggingTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 02.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "MWLoggingTests.h"

#import "MWLogging.h"

@implementation MWLoggingTests

static Class _class = nil;

- (void) setUp {
    if(_class == nil) _class = [MWLoggingTests class];
}

- (void)testCritical
{
    MWLogCritical(_class, @"Critical");
}

- (void)testError
{
    MWLogError(_class, @"Error");
}

- (void)testWarning
{
    MWLogWarning(_class, @"Warning");
}

- (void)testNotice
{
    MWLogInfo(_class, @"Notice: Formated message:%@", @"Hello log!");
}

- (void)testInfo
{
    MWLogInfo(_class, @"Info");
}

- (void)testDebug
{
    MWLogDebug(_class, @"Debug");
}

@end
