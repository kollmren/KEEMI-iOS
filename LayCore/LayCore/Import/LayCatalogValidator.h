//
//  LayQuestionValidator.h
//  
//
//  Created by Rene Kollmorgen on 11.05.13.
//
//

#import <Foundation/Foundation.h>

@class Catalog;
@class Question;
@class Answer;
@class AnswerItem;
@class Media;
@interface LayCatalogValidator : NSObject

+(BOOL) isValidCatalog:(Catalog*)catalog;

@end
