//
//  Resource+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 17.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Resource+Utilities.h"

#import "MWLogging.h"

@implementation Resource (Utilities)

-(NSNumber*)resourceNumber {
    return self.number;
}

-(NSUInteger)numberAsPrimitive {
    NSUInteger value = 0;
    if(self.number) {
        value = [self.number unsignedIntegerValue];
    }
    return value;
}

-(void)setResourceNumber:(NSUInteger)number {
    self.number = [NSNumber numberWithUnsignedInteger:number];
}

-(void)setResourceType:(NSUInteger)type {
    self.type = [NSNumber numberWithUnsignedInteger:type];
}

-(LayResourceTypeIdentifier) resourceType {
    NSUInteger typeAsPrimitive = [self.type unsignedIntegerValue];
    switch (typeAsPrimitive) {
        case RESOURCE_TYPE_BOOK:
            break;
        case RESOURCE_TYPE_WEB:
            break;
        case RESOURCE_TYPE_FILE:
            break;
        default:
            MWLogError([Resource class], @"Unknown type:%u of resource!", typeAsPrimitive);
            break;
    }
    return typeAsPrimitive;
}

-(NSArray*)questionList {
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.questionRef count]];
    for (Question* question in self.questionRef) {
        [sortedList addObject:question];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return sortedList;
}


-(NSArray*)explanationList {
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.explanationRef count]];
    for (Explanation* explanation in self.explanationRef) {
        [sortedList addObject:explanation];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return sortedList;
}

@end
