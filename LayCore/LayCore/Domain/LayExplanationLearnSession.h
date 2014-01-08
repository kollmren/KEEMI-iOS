//
//  LayQuestionQuerySession.h
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayExplanationDatasource.h"

@class Explanation;
@interface LayExplanationLearnSession : NSObject<LayExplanationDatasource>

-(id) initWithDatasource:(id<LayExplanationDatasource>)datasource;

-(void)finish;

-(NSDictionary*)presentedExplanations;

@end
