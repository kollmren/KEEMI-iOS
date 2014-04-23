//
//  LayQuestionValidator.m
//  
//
//  Created by Rene Kollmorgen on 11.05.13.
//
//

#import "LayCatalogValidator.h"
#import "LayAnswerType.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Media+Utilities.h"

#import "MWLogging.h"

@implementation LayCatalogValidator

static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayCatalogValidator class];
}

+(BOOL) isValidQuestion:(Question*)question {
    BOOL valid = YES;
    if(!question.question) {
        valid = NO;
    } else {
        valid = [LayCatalogValidator isValidAnswer:question.answerRef];
    }
    return valid;
}

+(BOOL) isValidAnswer:(Answer*)answer {
    BOOL valid = YES;
    Question *question = answer.questionRef;
    NSInteger numberOfCorrectAnswers = 0;
    if(answer.answerItemRef && [answer.answerItemRef count]==0) {
        MWLogError(_classObj, @"At least one answerItem must be set! Question:%@", question.name);
        valid = NO;
    } else {
        for (AnswerItem* answerItem in answer.answerItemRef) {
            if([answerItem.correct boolValue]) {
                numberOfCorrectAnswers++;
            }
        }
    }
    //
    if(valid) {
        if(numberOfCorrectAnswers==0) {
            MWLogError(_classObj, @"At least one answerItem must be correct! Question:%@", question.name);
        } else {
            LayAnswerTypeIdentifier typeOfQuestion = [question questionType];
            switch (typeOfQuestion) {
                case ANSWER_TYPE_MULTIPLE_CHOICE:
                    if(numberOfCorrectAnswers < 1) {
                        valid = NO;
                        MWLogError(_classObj, @"MultiChoice answers must have at least one correct answerItem! Question:%@",question.name);
                    }
                    break;
                case ANSWER_TYPE_SINGLE_CHOICE:
                    if(numberOfCorrectAnswers != 1) {
                        valid = NO;
                        MWLogError(_classObj, @"SingleChoice answers must have exact one correct answerItem! Question:%@",question.name);
                    }
                    break;
                case ANSWER_TYPE_CARD:
                    if(numberOfCorrectAnswers < 1) {
                        valid = NO;
                        MWLogError(_classObj, @"Card answers must have at least one correct answerItem! Question:%@",question.name);
                    }
                    break;
                case ANSWER_TYPE_KEY_WORD_ITEM_MATCH:
                    if(numberOfCorrectAnswers < 1) {
                        valid = NO;
                        MWLogError(_classObj, @"Item-Match answers must have at least one correct answerItem! Question:%@",question.name);
                    }
                    break;
                case ANSWER_TYPE_WORD_RESPONSE:
                    if(numberOfCorrectAnswers < 1) {
                        valid = NO;
                        MWLogError(_classObj, @"Text answers must have at least one correct answerItem! Question:%@",question.name);
                    }
                    break;
                case ANSWER_TYPE_AGGRAVATED_SINGLE_CHOICE:
                    if(numberOfCorrectAnswers != 1) {
                        valid = NO;
                        MWLogError(_classObj, @"SingleChoice answers must have exact one correct answerItem! Question:%@",question.name);
                    }
                    break;
                case ANSWER_TYPE_AGGRAVATED_MULTIPLE_CHOICE:
                    if(numberOfCorrectAnswers < 1) {
                        valid = NO;
                        MWLogError(_classObj, @"MultiChoice answers must have at least one correct answerItem! Question:%@",question.name);
                    }
                    break;
                case ANSWER_TYPE_ORDER:
                    if(numberOfCorrectAnswers < 2) {
                        valid = NO;
                        MWLogError(_classObj, @"Ordered answers must have at least two correct answerItem! Question:%@",question.name);
                    }
                    break;
                default:
                    valid = NO;
                    MWLogError(_classObj, @"Upps! Unknown type:%u of question! Question:%@", typeOfQuestion, question.name);
                    break;
            }
        }
    }
    //
    
    return valid;
}

+(BOOL) isValidAnswerItem:(AnswerItem*)answerItem {
    BOOL valid = NO;
    
    return valid;
}

+(BOOL) isValidMedia:(Media*)media {
    BOOL valid = NO;
    
    return valid;
}

+(BOOL) isValidCatalog:(Catalog*)catalog {
    BOOL valid = YES;
    if(catalog) {
        BOOL atLeastOneQuestionFound = NO;
        for (Question* question in [catalog questionListSortedByNumber]) {
            atLeastOneQuestionFound = YES;
            BOOL validQuestion = [LayCatalogValidator isValidQuestion:question];
            if(!validQuestion) {
                valid = NO;
                break;
            }
        }
        if(!atLeastOneQuestionFound) {
            valid = NO;
            MWLogError(_classObj, @"A catalog must have at least one question!");
        }
    } else {
        valid = NO;
    }
    return valid;
}

@end
