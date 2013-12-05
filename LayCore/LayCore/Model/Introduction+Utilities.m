//
//  Introduction+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 05.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Introduction+Utilities.h"

@implementation Introduction (Utilities)

-(NSArray*) orderedSectionList {
    NSMutableArray* sortedList = nil;
    if( [self.sectionRef count] > 0 ) {
        sortedList = [[NSMutableArray alloc]initWithCapacity:[self.sectionRef count]];
        for (Section* section in self.sectionRef) {
            [sortedList addObject:section];
        }
        NSSortDescriptor *sd = [NSSortDescriptor
                                sortDescriptorWithKey:@"number"
                                ascending:YES];
        [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    }
    return sortedList;
}

@end
