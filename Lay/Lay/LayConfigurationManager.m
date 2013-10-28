//
//  LayConfigurationManager.m
//  Lay
//
//  Created by Rene Kollmorgen on 12.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayConfigurationManager.h"

@implementation LayConfigurationManager

@synthesize querySessionMode;

+(LayConfigurationManager*) instance {
    static LayConfigurationManager* instance_ = nil;
    @synchronized(self)
    {
        if (instance_ == NULL) {
            instance_= [[self alloc] init];
        }
    }
    
    return(instance_);
}

-(QuerySessionModes)querySessionMode {
    return QUERY_SESSION_TRAINING_MODE;
}

@end
