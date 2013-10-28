//
//  LayErrorDomains.m
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayError.h"

#import "MWLogging.h"

@interface LayError() {
    NSMutableDictionary *errorIdentifierMap;
}
@end

//
// LayError
//
@implementation LayError

@synthesize details;

static Class _classObj = nil;

+(void)initialize {
    _classObj = [LayError class];
}

+(LayError*) withIdentifier:(LayErrorIdentifier)identifier_ andMessage:(NSString*)errorMessage {
    LayError* error = [[LayError alloc]initWithIdentifier:identifier_ andMessage:errorMessage];
    return error;
}

// Public methods
-(id) initWithIdentifier:(LayErrorIdentifier)identifier_ andMessage:(NSString*)errorMessage {
    if (!(self = [super init]))
    {
        MWLogError(_classObj, @"super init failed!");
        return nil;
    }
    
    self->errorIdentifierMap = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableArray *errorMessageList = [NSMutableArray arrayWithCapacity:5];
    [errorMessageList addObject:errorMessage];
    [self->errorIdentifierMap setObject:errorMessageList forKey:[NSNumber numberWithInteger:identifier_]];

    return self;
}

-(NSString*)details {
    NSMutableString *messageSummary = [NSMutableString stringWithCapacity:5];
    for (NSArray* errorMessageList in [self->errorIdentifierMap allValues]) {
        for (NSString *message in errorMessageList) {
            [messageSummary appendFormat:@"%@\n", message];
        }
    }
    return messageSummary;
}

-(void)addErrorWithIdentifier:(LayErrorIdentifier)errorIdentifier andMessage:(NSString*)errorMessage {
    NSNumber *identifierAsNumber = [NSNumber numberWithInteger:errorIdentifier];
    NSMutableArray *errorMessageList = [self->errorIdentifierMap objectForKey:identifierAsNumber];
    if(errorMessageList) {
        [errorMessageList addObject:errorMessage];
    } else {
        NSMutableArray *errorMessageList = [NSMutableArray arrayWithCapacity:5];
        [errorMessageList addObject:errorMessage];
        [self->errorIdentifierMap setObject:errorMessageList forKey:[NSNumber numberWithInteger:errorIdentifier]];
    }
}

-(NSArray*)listOfErrorIdentifiers {
    return [self->errorIdentifierMap allKeys];
}

-(NSArray*)errorMessagesForErrorIdentifier:(LayErrorIdentifier)errorIdentifier {
    NSArray *listOfErrorMessages = nil;
    NSNumber *identifierAsNumber = [NSNumber numberWithInteger:errorIdentifier];
    listOfErrorMessages = [self->errorIdentifierMap objectForKey:identifierAsNumber];
    return listOfErrorMessages;
}

-(void)addError:(LayError*)error {
    for (NSNumber *errorIdentifier in [error listOfErrorIdentifiers]) {
        LayErrorIdentifier identifier = [errorIdentifier integerValue];
        NSArray *listOfErrorMessages = [error errorMessagesForErrorIdentifier:identifier];
        for (NSString* message in listOfErrorMessages) {
            [self addErrorWithIdentifier:identifier andMessage:message];
        }
    }
}

-(BOOL)hasError:(LayErrorIdentifier)idenifier {
    BOOL hasError = NO;
    NSNumber *identifierAsNumber = [NSNumber numberWithInteger:idenifier];
    for (NSNumber *key in [self->errorIdentifierMap allKeys]) {
        if([key isEqualToNumber:identifierAsNumber]) {
            hasError = YES;
            break;
        }
    }
    return hasError;
}

@end
