//
//  LayAnswerViewManagerImpl.h
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayAnswerViewManager.h"
#import "LayAnswerType.h"

@interface LayAnswerViewManagerImpl : NSObject <LayAnswerViewManager>

+(LayAnswerViewManagerImpl*) instance;
    
// Returns YES if the view was registered successfully.
+(BOOL)registerAnswerView:(Class<LayAnswerView>)answerView forTypeOfAnswer:(LayAnswerTypeIdentifier)type;

@end
