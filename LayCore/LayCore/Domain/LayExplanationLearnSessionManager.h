//
//  LayQuestionQuerySessionManager.h
//  
//
//  Created by Rene Kollmorgen on 08.03.13.
//
//

#import <Foundation/Foundation.h>

typedef enum ExplanationSessionOrder_ {
    EXPLANATION_ORDER_BY_NUMBER,
    EXPLANATION_ORDER_RANDOM
} ExplanationSessionOrder;

@class LayExplanationLearnSession;
@class Catalog;
@class Explanation;
@interface LayExplanationLearnSessionManager : NSObject

+(LayExplanationLearnSessionManager*) instance;

-(LayExplanationLearnSession*)sessionWith:(Catalog*)catalog andOrder:(ExplanationSessionOrder)order considerTopicSelection:(BOOL)considerTopicSelection;

-(LayExplanationLearnSession*)sessionWith:(Catalog*)catalog explanation:(Explanation*)explanation andOrder:(ExplanationSessionOrder)ExplanationOrder;

-(LayExplanationLearnSession*)sessionWithListOfExplanations:(NSArray*)listOfExplanations;

@end
