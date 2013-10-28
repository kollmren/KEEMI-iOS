//
//  LayConfigurationManager.h
//  Lay
//
//  Created by Rene Kollmorgen on 12.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum QuerySessionModes_ {
    QUERY_SESSION_TRAINING_MODE,
    QUERY_SESSION_TEST_MODE
} QuerySessionModes;

@interface LayConfigurationManager : NSObject

@property (nonatomic, readonly) QuerySessionModes querySessionMode;

+(LayConfigurationManager*) instance;

@end
