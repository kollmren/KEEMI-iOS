//
//  LayExplanationLearnSessionManager.m
//  
//
//  Created by Rene Kollmorgen on 08.03.13.
//
//

#import "LayExplanationLearnSessionManager.h"

#import "LayExplanationLearnSession.h"
#import "LayExplanationDatasource.h"
#import "LayOrderedExplanationDatasource.h"
#import "LayRandomExplanationDataSource.h"

#import "Catalog+Utilities.h"

#import "MWLogging.h"

@implementation LayExplanationLearnSessionManager

+(LayExplanationLearnSessionManager*) instance {
    static LayExplanationLearnSessionManager* instance_ = nil;
    @synchronized(self)
    {
        if (instance_ == NULL)
            instance_= [[self alloc] init];
    }
    
    return(instance_);
}

-(LayExplanationLearnSession*)sessionWith:(Catalog*)catalog andOrder:(ExplanationSessionOrder)order considerTopicSelection:(BOOL)considerTopicSelection {
    id<LayExplanationDatasource> datasource = nil;
    if(order==EXPLANATION_ORDER_BY_NUMBER) {
        datasource = [[LayOrderedExplanationDatasource alloc]initWithCatalog:catalog considerTopicSelection:considerTopicSelection];
        MWLogDebug([LayExplanationLearnSessionManager class], @"Use ordered session to learn.");
    } else if( order == EXPLANATION_ORDER_RANDOM ) {
        datasource = [[LayRandomExplanationDataSource alloc]initWithCatalog:catalog considerTopicSelection:considerTopicSelection];
        MWLogDebug([LayExplanationLearnSessionManager class], @"Use random session to learn.");
    }
    
    LayExplanationLearnSession *session = [[LayExplanationLearnSession alloc] initWithDatasource:datasource];
    return session;
}

-(LayExplanationLearnSession*)sessionWith:(Catalog*)catalog explanation:(Explanation*)explanation andOrder:(ExplanationSessionOrder)ExplanationOrder {
    MWLogInfo([LayExplanationLearnSessionManager class], @"Create session with a set  explanation.");
    id<LayExplanationDatasource> datasource = [[LayOrderedExplanationDatasource alloc]initWithCatalog:catalog andExplanation:explanation];
    LayExplanationLearnSession *session = [[LayExplanationLearnSession alloc] initWithDatasource:datasource];
    return session;
}

-(LayExplanationLearnSession*)sessionWithListOfExplanations:(NSArray*)listOfExplanations {
    MWLogInfo([LayExplanationLearnSessionManager class], @"Create session with given list of explanations.");
    id<LayExplanationDatasource> datasource = [[LayOrderedExplanationDatasource alloc]initWithListOfExplanations:listOfExplanations];
    LayExplanationLearnSession *session = [[LayExplanationLearnSession alloc] initWithDatasource:datasource];
    return session;
}


@end
