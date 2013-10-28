//
//  LayQuestionDatasource.h
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Catalog;
@class Explanation;

@protocol LayExplanationDatasource <NSObject>

@required
-(Catalog*) catalog;

-(Explanation*) nextExplanation;

-(Explanation*) previousExplanation;

-(NSUInteger) numberOfExplanations;

-(NSUInteger) currentExplanationCounterValue;

@end
