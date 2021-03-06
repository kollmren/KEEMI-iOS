//
//  LayAnswerType.h
//  LayCore
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerType.h"

#import "MWLogging.h"

@implementation LayAnswerType

const NSString* LAY_ANSWER_TYPE_NAME_SINGLE_CHOICE = @"singleChoice";
const NSString* LAY_ANSWER_TYPE_NAME_MULTIPLE_CHOICE = @"multipleChoice";
const NSString* LAY_ANSWER_TYPE_NAME_CARD = @"flashcard";
const NSString* LAY_ANSWER_TYPE_WORD_RESPONSE = @"wordResponse";
const NSString* LAY_ANSWER_TYPE_ORDER = @"order";
const NSString* LAY_ANSWER_TYPE_NAME_AGGRAVATED_SINGLE_CHOICE = @"aggravatedSingleChoice";
const NSString* LAY_ANSWER_TYPE_NAME_AGGRAVATED_MULTIPLE_CHOICE = @"aggravatedMultipleChoice";
const NSString* LAY_ANSWER_TYPE_KEY_WORD_ITEM_MATCH = @"keywordItemMatch";
const NSString* LAY_ANSWER_TYPE_KEY_WORD_ITEM_MATCH_ORDERED = @"keywordItemMatchOrdered";


static Class _classObj = nil;

+(void)initialize {
    _classObj = [LayAnswerType class];
}

+(LayAnswerTypeIdentifier)answerTypeByString:(NSString*)answerType {
    LayAnswerTypeIdentifier identifier = ANSWER_TYPE_UNKNOWN;
    if([answerType isEqualToString:(NSString*)LAY_ANSWER_TYPE_NAME_SINGLE_CHOICE]) {
        identifier = ANSWER_TYPE_SINGLE_CHOICE;
    } else if([answerType isEqualToString:(NSString*)LAY_ANSWER_TYPE_NAME_MULTIPLE_CHOICE]) {
        identifier = ANSWER_TYPE_MULTIPLE_CHOICE;
    } else if([answerType isEqualToString:(NSString*)LAY_ANSWER_TYPE_NAME_CARD]) {
        identifier = ANSWER_TYPE_CARD;
    } else if([answerType isEqualToString:(NSString*)LAY_ANSWER_TYPE_NAME_AGGRAVATED_SINGLE_CHOICE]) {
        identifier = ANSWER_TYPE_AGGRAVATED_SINGLE_CHOICE;
    } else if([answerType isEqualToString:(NSString*)LAY_ANSWER_TYPE_NAME_AGGRAVATED_MULTIPLE_CHOICE]) {
        identifier = ANSWER_TYPE_AGGRAVATED_MULTIPLE_CHOICE;
    } else if([answerType isEqualToString:(NSString*)LAY_ANSWER_TYPE_WORD_RESPONSE]) {
        identifier = ANSWER_TYPE_WORD_RESPONSE;
    } else if([answerType isEqualToString:(NSString*)LAY_ANSWER_TYPE_ORDER]) {
        identifier = ANSWER_TYPE_ORDER;
    } else if([answerType isEqualToString:(NSString*)LAY_ANSWER_TYPE_KEY_WORD_ITEM_MATCH]) {
        identifier = ANSWER_TYPE_KEY_WORD_ITEM_MATCH;
    } else if([answerType isEqualToString:(NSString*)LAY_ANSWER_TYPE_KEY_WORD_ITEM_MATCH_ORDERED]) {
        identifier = ANSWER_TYPE_KEY_WORD_ITEM_MATCH_ORDERED;
    } else  {
        MWLogError(_classObj, @"Unknown type of answer:%@", answerType);
    }
    return identifier;
}

@end