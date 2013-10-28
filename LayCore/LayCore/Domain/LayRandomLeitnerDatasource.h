//
//  LayRandomLeitnerDatasource.h
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayQuestionDatasource.h"

@class Catalog;
@interface LayRandomLeitnerDatasource : NSObject<LayQuestionDatasource> {
@private
    Catalog* catalog;
    NSArray* questionList;
    NSUInteger index;
    BOOL firstQuestionPassed;
}

@property (nonatomic,readonly) BOOL considerTopicSelection;

-(id) initWithCatalog:(Catalog*)catalog considerTopicSelection:(BOOL)consider;

@end
