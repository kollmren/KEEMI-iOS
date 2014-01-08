//
//  LayExplanationQuerySession.m
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayExplanationLearnSession.h"
#import "LayCatalogManager.h"

#import "Catalog+Utilities.h"
#import "Explanation+Utilities.h"

#import "MWLogging.h"

@interface LayExplanationLearnSession() {
    NSMutableDictionary* presentedExplanationMap;
    NSDate* sessionStart;
    id<LayExplanationDatasource> datasource;
    Explanation* currentExplanation;
}
@end


@implementation LayExplanationLearnSession

-(id) initWithDatasource:(id<LayExplanationDatasource>)datasource_ {
    self = [super init];
    if(self) {
        datasource = datasource_;
        self->presentedExplanationMap = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

-(void)finish {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    catalogManager.currentCatalogShouldBeLearnedDirectly = NO;
    [self rememberPresentedExplanation:self->currentExplanation];
}

-(NSDictionary*)presentedExplanations {
    return self->presentedExplanationMap;
}

-(NSTimeInterval)neededTime {
    NSDate *sessionEnd = [NSDate date];
    NSTimeInterval neededTime_ = [sessionEnd timeIntervalSinceDate:sessionStart];
    return neededTime_;
}

-(void)dealloc {
    MWLogDebug([LayExplanationLearnSession class], @"dealloc");
    //Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    //NSManagedObjectContext *context = catalog.managedObjectContext;
    //[context rollback];
}

-(void)rememberPresentedExplanation:(Explanation*)explanation {
    if(explanation) {
        NSNumber *explanationNumber = [explanation number];
        Explanation* alreadyPresentedExplanation = [self->presentedExplanationMap objectForKey:explanationNumber];
        if(alreadyPresentedExplanation==nil) {
            [self->presentedExplanationMap setObject:explanation forKey:explanationNumber];
        }
    }
}

//
// LayExplanationDatasource
//
-(Catalog*) catalog {
    Catalog *catalog = nil;
    if(self->datasource) catalog = [self->datasource catalog];
    return catalog;
}
// Returns nil if there is no Explanations or the end of the list of Explanations is reached
-(Explanation*) nextExplanation {
    Explanation* explanation = nil;
    if(self->currentExplanation) {
        [self rememberPresentedExplanation:self->currentExplanation];
    }
    if(self->datasource) explanation = [self->datasource nextExplanation];
    self->currentExplanation = explanation;
    return explanation;
}

-(Explanation*) previousExplanation {
    Explanation* Explanation = nil;
    if(self->datasource) Explanation = [self->datasource previousExplanation];
    self->currentExplanation = Explanation;
    return Explanation;
}

-(NSUInteger) numberOfExplanations {
    NSUInteger number = 0;
    if(self->datasource) number = [self->datasource numberOfExplanations];
    return number;
}

-(NSUInteger) currentExplanationCounterValue {
    NSUInteger number = 0;
    if(self->datasource) number = [self->datasource currentExplanationCounterValue];
    return number;
}

@end
