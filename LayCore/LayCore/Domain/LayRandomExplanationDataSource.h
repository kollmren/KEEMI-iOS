//
//  LayRandomExplanationDataSource.h
//  LayCore
//
//  Created by Rene Kollmorgen on 16.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayExplanationDatasource.h"

@class Catalog;
@interface LayRandomExplanationDataSource : NSObject<LayExplanationDatasource> {
    @private
    Catalog *catalog;
    NSMutableArray *randomExplanations;
    BOOL considerSelectedTopics;
    //
    NSUInteger index;
    BOOL firstExplanationPassed;
};

-(id)initWithCatalog:(Catalog*)catalog considerTopicSelection:(BOOL)considerTopic;

@end
