//
//  LayAnswerItemStyleTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 23.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerStyleTests.h"
#import "Answer+Utilities.h"
#import "MWLogging.h"

@implementation LayAnswerStyleTests

static Class _classObj = nil;

+(void)setUp {
    _classObj = [LayAnswerStyleTests class];
}

-(void)testHasStyleWithValidStyleFormat {
    MWLogNameOfTest(_classObj);
    NSString *validStyleFormat = @"column;keep-height";
    LayAnswerStyle* itemStyle = [LayAnswerStyle styleWithString:validStyleFormat];
    STAssertNotNil(itemStyle, nil);
    BOOL hasStyle = [itemStyle hasStyle:StyleColumn];
    STAssertTrue(hasStyle, nil);
}


@end
