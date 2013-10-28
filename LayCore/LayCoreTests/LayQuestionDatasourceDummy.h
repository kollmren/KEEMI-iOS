//
//  LayQuestionDatasourceDummy.h
//  LayCore
//
//  Created by Rene Kollmorgen on 08.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayQuestionDatasource.h"

#import <Foundation/Foundation.h>

@class Catalog;
@interface LayQuestionDatasourceDummy : NSObject<LayQuestionDatasource> {
    @private
    Catalog* catalog;
    NSArray* questionList;
    NSInteger index;
}

-(id)initWithCatalog:(Catalog*)catalog;

-(void)resetIndex;

@end
