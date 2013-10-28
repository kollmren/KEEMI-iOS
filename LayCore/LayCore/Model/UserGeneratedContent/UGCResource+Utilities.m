//
//  UGCResource+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 09.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "UGCResource+Utilities.h"
#import "UGCExplanation+Utilities.h"
#import "UGCQuestion+Utilities.h"

#import "Question+Utilities.h"
#import "Explanation+Utilities.h"
#import "Catalog+Utilities.h"

#import "MWLogging.h"

@implementation UGCResource (Utilities)

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
            MWLogError([UGCResource class], @"Unknown type:%u of resource!", typeAsPrimitive);
            break;
    }
    return typeAsPrimitive;
}


-(BOOL)linkedWithExplanationWithName:(NSString*)nameOfExplanation {
    BOOL linked = NO;
    for (UGCExplanation *ugcExplanation in self.explanationRef) {
        if([ugcExplanation.name isEqualToString:nameOfExplanation]) {
            linked = YES;
            break;
        }
    }
    return linked;
}

-(BOOL)linkedWithQuestionWithName:(NSString*)nameOfQuestion {
    BOOL linked = NO;
    for (UGCQuestion *ugcQuestion in self.questionRef) {
        if([ugcQuestion.name isEqualToString:nameOfQuestion]) {
            linked = YES;
            break;
        }
    }
    return linked;
}

-(NSArray*)questionList {
    NSMutableArray* sortedList = nil;
    if(self.questionRef && [self.questionRef count] > 0) {
        Catalog* catalog = [self.catalogRef sourceCatalog];
        if(catalog) {
            sortedList = [[NSMutableArray alloc]initWithCapacity:[self.questionRef count]];
            for (UGCQuestion* ugcQuestion in self.questionRef) {
                Question *question = [catalog questionByName:ugcQuestion.name];
                if(question) {
                    [sortedList addObject:question];
                }
            }
            NSSortDescriptor *sd = [NSSortDescriptor
                                    sortDescriptorWithKey:@"number"
                                    ascending:YES];
            [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        }
    }
    
    return sortedList;
}


-(NSArray*)explanationList {
    NSMutableArray* sortedList = nil;
    if(self.explanationRef && [self.explanationRef count] > 0) {
        NSMutableArray* sortedList = nil;
        Catalog* catalog = [self.catalogRef sourceCatalog];
        if(catalog) {
            sortedList = [[NSMutableArray alloc]initWithCapacity:[self.explanationRef count]];
            for (UGCExplanation* ugcExplanation in self.explanationRef) {
                Explanation *explanation = [catalog explanationByName:ugcExplanation.name];
                if(explanation) {
                    [sortedList addObject:explanation];
                }
            }
            NSSortDescriptor *sd = [NSSortDescriptor
                                    sortDescriptorWithKey:@"number"
                                    ascending:YES];
            [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        }
    }
    
    return sortedList;
}

@end
