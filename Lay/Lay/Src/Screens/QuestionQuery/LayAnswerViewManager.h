//
//  LayAnswerViewManager.h
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayAnswerView.h"
#import "LayAnswerType.h"

@class Answer;
@protocol LayAnswerViewManager <NSObject>

@required
-(NSObject<LayAnswerView>*) viewForAnswerType:(LayAnswerTypeIdentifier)answerTypeId;

-(void)freeAllAnswerViewObjects;

@end
