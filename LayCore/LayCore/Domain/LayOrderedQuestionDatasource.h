//
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayQuestionDatasource.h"

@class Catalog;
@class Question;
@interface LayOrderedQuestionDatasource : NSObject<LayQuestionDatasource> {
@private
    Catalog* catalog;
    NSArray* questionList;
    NSUInteger index;
    BOOL firstQuestionPassed;
}

-(id) initWithCatalog:(Catalog*)catalog;

-(id)initWithCatalog:(Catalog*)catalog_ andQuestionList:(NSArray*)listOfQuestions;

-(void)setStartQuestionTo:(Question*)question;

@end
