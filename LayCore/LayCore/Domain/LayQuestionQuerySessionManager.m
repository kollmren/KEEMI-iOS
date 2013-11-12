//
//  LayQuestionQuerySessionManager.m
//  
//
//  Created by Rene Kollmorgen on 08.03.13.
//
//

#import "LayQuestionQuerySessionManager.h"

#import "LayQuestionQuerySession.h"
#import "LayRandomLeitnerDatasource.h"
#import "LayOrderedQuestionDatasource.h"
#import "Catalog+Utilities.h"

#import "MWLogging.h"

@implementation LayQuestionQuerySessionManager

+(LayQuestionQuerySessionManager*) instance {
    static LayQuestionQuerySessionManager* instance_ = nil;
    @synchronized(self)
    {
        if (instance_ == NULL)
            instance_= [[self alloc] init];
    }
    
    return(instance_);
}

-(LayQuestionQuerySession*)queryQuestionSessionWith:(Catalog*)catalog andOrder:(QuerySessionQuestionOrder)questionOrder considerTopicSelection:(BOOL)considerTopicSelection {
    id<LayQuestionDatasource> datasource = nil;
    if(questionOrder==QUESTION_ORDER_RANDOM_LEITNER) {
        datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:considerTopicSelection];
        MWLogDebug([LayQuestionQuerySessionManager class], @"Use random-leitner for session.");
    } else if(questionOrder==QUESTION_ORDER_BY_NUMBER) {
         datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
        MWLogDebug([LayQuestionQuerySessionManager class], @"Use order by number for session.");
    }
    
    LayQuestionQuerySession *session = [[LayQuestionQuerySession alloc] initWithDatasource:datasource];
    return session;
}

-(LayQuestionQuerySession*)queryQuestionSessionWith:(Catalog*)catalog question:(Question*)question andOrder:(QuerySessionQuestionOrder)questionOrder {
    LayOrderedQuestionDatasource* datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    [datasource setStartQuestionTo:question];
    LayQuestionQuerySession *session = [[LayQuestionQuerySession alloc] initWithDatasource:datasource];
    return session;
}

-(LayQuestionQuerySession*)queryQuestionSessionWith:(Catalog*)catalog andQuestionList:(NSArray*)questionList {
    LayOrderedQuestionDatasource* datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog andQuestionList:questionList];
    LayQuestionQuerySession *session = [[LayQuestionQuerySession alloc] initWithDatasource:datasource];
    return session;
}

@end
