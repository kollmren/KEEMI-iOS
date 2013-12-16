//
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayExplanationDatasource.h"

@class Catalog;
@class Explanation;
@interface LayOrderedExplanationDatasource : NSObject<LayExplanationDatasource> {
@private
    Catalog* catalog;
    NSArray* explanationList;
    NSUInteger index;
    BOOL firstExplanationPassed;
}

@property (nonatomic,readonly) BOOL considerTopicSelection;

-(id)initWithCatalog:(Catalog*)catalog_ considerTopicSelection:(BOOL)considerTopicSelection;

-(id)initWithCatalog:(Catalog*)catalog_ andExplanation:(Explanation*)explanation;

-(id)initWithListOfExplanations:(NSArray*)listOfExplanations;

// LayExplanationDatasource
-(Catalog*)catalog;

-(Explanation*)nextExplanation;

-(Explanation*)previousExplanation;

-(NSUInteger)numberOfExplanations;

-(NSUInteger)currentExplanationCounterValue;

@end
