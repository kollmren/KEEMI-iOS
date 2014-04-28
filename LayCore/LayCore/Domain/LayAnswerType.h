//
//  LayAnswerType.h
//  LayCore
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum LayAnswerTypeIdentifier_ {
    ANSWER_TYPE_MULTIPLE_CHOICE = 1,
    ANSWER_TYPE_SINGLE_CHOICE,
    ANSWER_TYPE_AGGRAVATED_MULTIPLE_CHOICE,
    ANSWER_TYPE_AGGRAVATED_SINGLE_CHOICE,
    ANSWER_TYPE_MAP,
    ANSWER_TYPE_ASSIGN,
    ANSWER_TYPE_CARD,
    ANSWER_TYPE_WORD_RESPONSE,
    ANSWER_TYPE_ORDER,
    ANSWER_TYPE_KEY_WORD_ITEM_MATCH,
    ANSWER_TYPE_KEY_WORD_ITEM_MATCH_ORDERED,
    ANSWER_TYPE_UNKNOWN
} LayAnswerTypeIdentifier;

@interface LayAnswerType : NSObject

+(LayAnswerTypeIdentifier)answerTypeByString:(NSString*)answerType;

@end
