//
//  LayQuestionQuerySessionManager.h
//  
//
//  Created by Rene Kollmorgen on 08.03.13.
//
//

#import <Foundation/Foundation.h>

typedef enum QuerySessionQuestionOrder_ {
    QUESTION_ORDER_RANDOM_LEITNER,
    QUESTION_ORDER_BY_NUMBER,
} QuerySessionQuestionOrder;

@class LayQuestionQuerySession;
@class Catalog;
@class Question;
@interface LayQuestionQuerySessionManager : NSObject

+(LayQuestionQuerySessionManager*) instance;

-(LayQuestionQuerySession*)queryQuestionSessionWith:(Catalog*)catalog andOrder:(QuerySessionQuestionOrder)questionOrder considerTopicSelection:(BOOL)considerTopicSelection;

-(LayQuestionQuerySession*)queryQuestionSessionWith:(Catalog*)catalog question:(Question*)question andOrder:(QuerySessionQuestionOrder)questionOrder;

-(LayQuestionQuerySession*)queryQuestionSessionWith:(Catalog*)catalog andQuestionList:(NSArray*)questionList;

@end
