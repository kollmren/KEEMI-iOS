//
//  About+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 19.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "About+Utilities.h"

@implementation About (Utilities)

-(NSNumber*)numberForSection {
    NSUInteger currentSectionNumber = [self.sectionCounter unsignedIntegerValue];
    NSNumber* updatedSectionNumber = [NSNumber numberWithUnsignedInteger:++currentSectionNumber];
    self.sectionCounter = updatedSectionNumber;
    return updatedSectionNumber;
}

-(NSArray*)sectionList {
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.sectionRef count]];
    for (Section* s in self.sectionRef) {
        [sortedList addObject:s];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return sortedList;
}

@end
