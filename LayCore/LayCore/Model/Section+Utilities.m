//
//  Section+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 16.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Section+Utilities.h"

#import "LayDataStoreUtilities.h"

@implementation Section (Utilities)

-(NSArray*)sectionGroupList {
    NSMutableArray *sectionItemList = [NSMutableArray arrayWithCapacity:10];
    
    // Get the textItems arranged to the groupnumber
    NSMutableArray *textListItemsOrderedByGroupNumber = [NSMutableArray arrayWithCapacity:[self.sectionTextRef count]];
    for (SectionText *sectionText in self.sectionTextRef) {
        [textListItemsOrderedByGroupNumber addObject:sectionText];
    }
    NSSortDescriptor *groupNumberSd = [NSSortDescriptor
                            sortDescriptorWithKey:@"groupNumber"
                            ascending:YES];
    [textListItemsOrderedByGroupNumber sortUsingDescriptors:[NSArray arrayWithObject:groupNumberSd]];
    
    // Group text per groupnumber
    NSUInteger groupNumber = 0;
    LaySectionTextList *textList = nil;
    NSMutableArray *groupedTextList = [NSMutableArray arrayWithCapacity:10];
    for (SectionText *sectionText in textListItemsOrderedByGroupNumber) {
        NSUInteger currentGroupNumber = [sectionText.groupNumber unsignedIntegerValue];
        if(groupNumber != currentGroupNumber) {
            if(textList) {
                NSSortDescriptor *sd = [NSSortDescriptor
                                        sortDescriptorWithKey:@"number"
                                        ascending:YES];
                
                [groupedTextList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
                textList.textList = [groupedTextList copy];
                [sectionItemList addObject:textList];
            }
            [groupedTextList removeAllObjects];
            groupNumber = currentGroupNumber;
            textList = [LaySectionTextList new];
            textList.groupNumber = sectionText.groupNumber;
            
        }
        [groupedTextList addObject:sectionText];
    }
    // order the last added textItemGroup
    if(textList) {
        NSSortDescriptor *sd = [NSSortDescriptor
                                sortDescriptorWithKey:@"number"
                                ascending:YES];
        
        [groupedTextList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        textList.textList = [groupedTextList copy];
        [sectionItemList addObject:textList];
    }
    
    
    // Media
    NSArray *availableMediaListNumnbers = [self availableMediaListNumbers];
    for (NSNumber *mediaListNumber in availableMediaListNumnbers) {
        NSInteger mediaListNumberValue = [mediaListNumber integerValue];
        LaySectionMediaList* mediaList = [self orderedSectionMediaListByListNumber:mediaListNumberValue];
        if(mediaList) {
            [sectionItemList addObject:mediaList];
        }
    }
    
    // Question
    if(self.sectionQuestionRef) {
        [sectionItemList addObject:self.sectionQuestionRef];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"groupNumber"
                            ascending:YES];

    [sectionItemList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return sectionItemList;
}

-(SectionText*)sectionTextInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    SectionText *sectionText = [LayDataStoreUtilities insertDomainObject: LaySectionText :context];
    NSUInteger numberOfSectionItems = [self.sectionItemCounter unsignedIntegerValue];
    sectionText.sectionRef = self;
    NSNumber *updatedNumberOfSectionItems = [NSNumber numberWithUnsignedInteger:++numberOfSectionItems];
    sectionText.number = updatedNumberOfSectionItems;
    self.sectionItemCounter = updatedNumberOfSectionItems;
    return sectionText;
}

-(SectionMedia*)sectionMediaInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    SectionMedia *sectionMedia = [LayDataStoreUtilities insertDomainObject: LaySectionMedia :context];
    NSUInteger numberOfSectionItems = [self.sectionItemCounter unsignedIntegerValue];
    sectionMedia.sectionRef = self;
    NSNumber *updatedNumberOfSectionItems = [NSNumber numberWithUnsignedInteger:++numberOfSectionItems];
    sectionMedia.number = updatedNumberOfSectionItems;
    self.sectionItemCounter = updatedNumberOfSectionItems;
    return sectionMedia;
}

-(SectionQuestion*)sectionQuestionInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    SectionQuestion *sectionQuestion = [LayDataStoreUtilities insertDomainObject: LaySectionQuestion :context];
    NSUInteger numberOfSectionItems = [self.sectionItemCounter unsignedIntegerValue];
    sectionQuestion.sectionRef = self;
    NSNumber *updatedNumberOfSectionItems = [NSNumber numberWithUnsignedInteger:++numberOfSectionItems];
    sectionQuestion.number = updatedNumberOfSectionItems;
    self.sectionItemCounter = updatedNumberOfSectionItems;
    return sectionQuestion;
}

-(NSNumber*)newGroupNumber {
    NSInteger groupCounter = [self.sectionGroupCounter unsignedIntegerValue];
    NSNumber *number = [NSNumber numberWithInteger:++groupCounter];
    self.sectionGroupCounter = number;
    return number;
}

//
// Private
//
-(LaySectionMediaList*)orderedSectionMediaListByListNumber:(NSInteger)mediaListNumber {
    LaySectionMediaList *sectionMediaList = nil;
    NSMutableArray *mediaList = [NSMutableArray arrayWithCapacity:5];
    for (SectionMedia* sectionMedia in self.sectionMediaRef) {
        NSInteger sectionMediaListNumber = [sectionMedia.groupNumber integerValue];
        if(sectionMediaListNumber == mediaListNumber) {
            [mediaList addObject:sectionMedia];
        }
    }
    if([mediaList count] > 0) {
        NSSortDescriptor *sd = [NSSortDescriptor
                                sortDescriptorWithKey:@"number"
                                ascending:YES];
        
        [mediaList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        sectionMediaList = [LaySectionMediaList new];
        sectionMediaList.mediaList = mediaList;
        sectionMediaList.groupNumber = [NSNumber numberWithInteger:mediaListNumber];
    }
    
    return sectionMediaList;
}

-(NSArray*)availableMediaListNumbers {
    NSMutableArray *mediaNumberList = nil;
    NSMutableArray *orderedSectionMediaList = [NSMutableArray arrayWithCapacity:[self.sectionMediaRef count]];
    for (SectionMedia* sectionMedia in self.sectionMediaRef) {
        [orderedSectionMediaList addObject:sectionMedia];
    }
    if([orderedSectionMediaList count] > 0) {
        NSSortDescriptor *sd = [NSSortDescriptor
                                sortDescriptorWithKey:@"groupNumber"
                                ascending:YES];
        
        [orderedSectionMediaList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        mediaNumberList = [NSMutableArray arrayWithCapacity:10.0f];
        NSInteger mediaListNumber = -1;
        for (SectionMedia *sectionMedia in orderedSectionMediaList) {
            NSInteger sectionMediaListNumber = [sectionMedia.groupNumber integerValue];
            if(mediaListNumber != sectionMediaListNumber) {
                mediaListNumber = sectionMediaListNumber;
                [mediaNumberList addObject:sectionMedia.groupNumber];
            }
        }
    }
    
    return mediaNumberList;
}

@end

//
// LaySectionMediaList
//
@implementation LaySectionMediaList

@synthesize mediaList, groupNumber;

@end

//
// LaySectionTextList
//
@implementation LaySectionTextList

@synthesize textList, groupNumber;

@end
