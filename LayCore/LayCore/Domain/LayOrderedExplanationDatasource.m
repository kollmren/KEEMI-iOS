//
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayOrderedExplanationDatasource.h"

#import "Catalog+Utilities.h"
#import "Topic+Utilities.h" 
#import "Explanation+Utilities.h"

#import "MWLogging.h"

@implementation LayOrderedExplanationDatasource

@synthesize considerTopicSelection;

-(id)initWithCatalog:(Catalog*)catalog_ considerTopicSelection:(BOOL)considerTopicSelection_ {
    self = [super init];
    if(self) {
        self->catalog = catalog_;
        self->index = 0;
        self->firstExplanationPassed = NO;
        considerTopicSelection = considerTopicSelection_;
        [self preparingExplanationList];
    }
    return self;
}

-(id)initWithListOfExplanations:(NSArray*)listOfExplanations {
    self = [super init];
    if(self) {
        self->catalog = nil;
        self->index = 0;
        self->firstExplanationPassed = NO;
        self->explanationList = listOfExplanations;
    }
    return self;
}

-(void)preparingExplanationList {
    NSMutableArray *preparedExplanationList = [NSMutableArray arrayWithCapacity:[self->catalog numberOfExplanations]];
    for (Topic *topic in [self->catalog topicList]) {
        BOOL takeExplanation = YES;
        if(self.considerTopicSelection) {
            takeExplanation = [topic topicIsSelected];
        }
        if(takeExplanation) {
            for (Explanation* e in [topic explanationSet]) {
                [preparedExplanationList addObject:e];
            }
        }
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [preparedExplanationList  sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    self->explanationList = preparedExplanationList;
}

//
// LayExplanationDatasource
//
-(Catalog*) catalog {
    return self->catalog;
}

-(Explanation*) nextExplanation {
    Explanation *explanation = nil;
    if(firstExplanationPassed && self->index < ([self->explanationList count] - 1)) {
        self->index++;
    }
    
    MWLogDebug([LayOrderedExplanationDatasource class], @"Get explanation with index:%u",self->index);
    explanation = [explanationList objectAtIndex:self->index];
    firstExplanationPassed = YES;
    return explanation;
}

-(Explanation*) previousExplanation {
    Explanation *explanation = nil;
    if(self->index > 0) {
        self->index--;
        MWLogDebug([LayOrderedExplanationDatasource class], @"Get(previous) explanation with index:%u",self->index);
    } else {
        self->index = 0;
    }
    
    explanation = [explanationList objectAtIndex:self->index];
    
    return explanation;
}

-(NSUInteger) numberOfExplanations {
    return [self->explanationList count];
}

-(NSUInteger) currentExplanationCounterValue {
    return self->index + 1;
}


@end
