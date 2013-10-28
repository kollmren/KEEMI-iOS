//
//  UGCNote+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 14.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "UGCNote+Utilities.h"
#import "UGCQuestion+Utilities.h"
#import "UGCExplanation+Utilities.h"
#import "UGCCatalog+Utilities.h"

#import "Catalog+Utilities.h"

@implementation UGCNote (Utilities)

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
