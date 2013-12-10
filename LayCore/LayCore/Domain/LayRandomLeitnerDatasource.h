//
//  LayRandomLeitnerDatasource.h
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayQuestionDatasource.h"

@class Catalog, Question;
@interface LayRandomLeitnerDatasource : NSObject<LayQuestionDatasource> {
@private
    Catalog* catalog;
    Question* firstQuestionInGroup;
    NSArray* questionList;
    NSUInteger index;
    BOOL firstQuestionPassed;
    NSString *currentQuestionGroupName;
    NSMutableDictionary* groupedQuestionMap;
    NSInteger groupedQuestionIndex;
    NSArray* currentGroupedQuestionList;
    BOOL cancelGroupMode;
}

@property (nonatomic,readonly) BOOL considerTopicSelection;

-(id) initWithCatalog:(Catalog*)catalog considerTopicSelection:(BOOL)consider;

@end
