//
//  LayRandomExplanationDataSource.m
//  LayCore
//
//  Created by Rene Kollmorgen on 16.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayRandomExplanationDataSource.h"

#import "Catalog+Utilities.h"
#import "Explanation+Utilities.h"
#import "Topic+Utilities.h"

#import "MWLogging.h"

@implementation LayRandomExplanationDataSource

static Class g_classObj = nil;

+(void)initialize {
    g_classObj = [LayRandomExplanationDataSource class];
}

-(id)initWithCatalog:(Catalog*)catalog_ considerTopicSelection:(BOOL)considerTopics {
    self = [super init];
    if( self ) {
        self->catalog = catalog_;
        self->considerSelectedTopics = considerTopics;
        [self prepareRandomExplanationDataSource];
    }
    return self;
}

-(void)prepareRandomExplanationDataSource {
    self->randomExplanations = [NSMutableArray arrayWithCapacity:[self->catalog numberOfExplanations]];
    for (Topic *topic in [self->catalog topicList]) {
        BOOL takeExplanations = YES;
        if( self->considerSelectedTopics ) {
            takeExplanations = [topic topicIsSelected];
        }
        if(takeExplanations) {
            for (Explanation *explanation in [topic explanationSet]) {
                [self->randomExplanations  addObject:explanation];
            }
        }
    }
    
    NSUInteger numberOfExplanations = [self->randomExplanations count];
    if( numberOfExplanations > 0 ) {
        for (NSUInteger x = 0; x < numberOfExplanations; x++) {
            NSUInteger randInt = (random() % (numberOfExplanations - x)) + x;
            [self->randomExplanations exchangeObjectAtIndex:x withObjectAtIndex:randInt];
        }
    } else {
        MWLogError(g_classObj, @"Internal! No explanations to order!");
    }
}

#pragma mark LayExplanationDatasource

-(Catalog*) catalog {
    return self->catalog;
}

-(Explanation*) nextExplanation {
    Explanation *explanation = nil;
    if(self->firstExplanationPassed && self->index < ([self->randomExplanations count] - 1)) {
        self->index++;
    }
    
    MWLogDebug(g_classObj, @"Get explanation with index:%u",self->index);
    explanation = [self->randomExplanations objectAtIndex:self->index];
    if(self->index==0)firstExplanationPassed = YES;
    
    return explanation;
}

-(Explanation*) previousExplanation {
    Explanation *explanation = nil;
    if( [self->randomExplanations count] == 0 ) {
        MWLogWarning( g_classObj, @"No explanations in datasource!");
        return explanation;
    }
    
    if(self->index > 0) {
        self->index--;
    }
    MWLogDebug( g_classObj, @"Get(previous) explanation with index:%u",self->index);
    explanation = [self->randomExplanations objectAtIndex:self->index];
    return explanation;
}

-(NSUInteger) numberOfExplanations {
    return [self->randomExplanations count];
}

-(NSUInteger) currentExplanationCounterValue {
    return self->index + 1;
}

@end
