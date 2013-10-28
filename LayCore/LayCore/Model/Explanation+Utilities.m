//
//  Explanation+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 09.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Catalog+Utilities.h"
#import "Explanation+Utilities.h"
#import "Media+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Question+Utilities.h"
#import "LayDataStoreUtilities.h"

#import "LayUserDataStore.h"
#import "UGCCatalog+Utilities.h"
#import "UGCExplanation+Utilities.h"
#import "UGCResource+Utilities.h"

#import "MWLogging.h"

@implementation Explanation (Utilities)

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

-(BOOL)hasRelatedQuestions {
    BOOL hasRelatedQuestions = NO;
    if([self.answerRef count] > 0 || [self.answerItemRef count] > 0) {
        hasRelatedQuestions = YES;
    }
    return hasRelatedQuestions;
}

-(NSArray*)relatedQuestionList {
    NSMutableArray *relatedQuestionList = [NSMutableArray arrayWithCapacity:5];
    for (Answer* answer in self.answerRef) {
        Question *question = answer.questionRef;
        if(![relatedQuestionList containsObject:question]) {
            [relatedQuestionList addObject:question];
        }
    }
    
    for (AnswerItem* answerItem in self.answerItemRef) {
        Question *question = answerItem.answerRef.questionRef;
        if(![relatedQuestionList containsObject:question]) {
            [relatedQuestionList addObject:question];
        }
    }
    
    return relatedQuestionList;
}

-(void)setTopic:(Topic*)topic {
    self.topicRef = topic;
}

-(BOOL)hasLinkedResources {
    BOOL hasLinkedResources = NO;
    if([self.resourceRef count] > 0 || [[self ugcResourceList] count] > 0) {
        hasLinkedResources = YES;
    }
    return hasLinkedResources;
}

-(NSArray*)resourceList {
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.resourceRef count]];
    for (Resource* t in self.resourceRef) {
        [sortedList addObject:t];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    NSArray *ugcResourceList = [self ugcResourceList];
    [sortedList addObjectsFromArray:ugcResourceList];
    
    return sortedList;
}


-(NSArray*)ugcResourceList {
    LayUserDataStore *userDataStore = [LayUserDataStore store];
    UGCCatalog *uCatalog = [userDataStore findCatalogByTitle:self.catalogRef.title andPublisher:[self.catalogRef publisher]];
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.resourceRef count]];
    if(uCatalog) {
        UGCExplanation *uExplanation = [uCatalog explanationByName:self.name];
        if(uExplanation) {
            for(UGCResource* resource in uExplanation.resourceRef) {
                [sortedList addObject:resource];
            }
            NSSortDescriptor *sd = [NSSortDescriptor
                                    sortDescriptorWithKey:@"created"
                                    ascending:YES];
            [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        }
    }
    return sortedList;
}


-(NSArray*)noteList {
    LayUserDataStore *userDataStore = [LayUserDataStore store];
    UGCCatalog *uCatalog = [userDataStore findCatalogByTitle:self.catalogRef.title andPublisher:[self.catalogRef publisher]];
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.resourceRef count]];
    if(uCatalog) {
        UGCExplanation *uExplanation = [uCatalog explanationByName:self.name];
        if(uExplanation) {
            for(UGCNote* note in uExplanation.noteRef) {
                [sortedList addObject:note];
            }
            NSSortDescriptor *sd = [NSSortDescriptor
                                    sortDescriptorWithKey:@"created"
                                    ascending:YES];
            [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        }
    }
    return sortedList;
}

-(BOOL)hasLinkedNotes {
    BOOL hasLinkedNotes = NO;
    if([[self noteList] count] > 0 ) {
        hasLinkedNotes = YES;
    }
    return hasLinkedNotes;
}

-(void)markExplanationAsFavourite {
    UGCCatalog *uCatalog = [self ugcCatalog];
    if(uCatalog) {
        UGCExplanation *uExplanation = [uCatalog explanationByName:self.name];
        if(!uExplanation) {
            uExplanation = [uCatalog explanationInstance];
            uExplanation.name = self.name;
            uExplanation.title = self.title;
        }
        uExplanation.favourite = [NSNumber numberWithBool:YES];
        [self saveUgc];
    }
}

-(void)unmarkExplanationAsFavourite {
    UGCCatalog *uCatalog = [self ugcCatalog];
    if(uCatalog) {
        UGCExplanation *uExplanation = [uCatalog explanationByName:self.name];
        if(uExplanation) {
            uExplanation.favourite = [NSNumber numberWithBool:NO];
            [self saveUgc];
        }
    }
}

-(BOOL)isFavourite {
    BOOL isFavourite = NO;
    UGCCatalog *uCatalog = [self ugcCatalog];
    if(uCatalog) {
        UGCExplanation *uExplanation = [uCatalog explanationByName:self.name];
        isFavourite = [uExplanation.favourite boolValue];
    }
    return isFavourite;
}

-(void)saveUgc {
    LayUserDataStore *userDataStore = [LayUserDataStore store];
    if(userDataStore) {
        BOOL saved = [userDataStore saveChanges];
        if(!saved) {
            MWLogError([Explanation class], @"Could not save changes to User-Store!");
        }
    } else {
        MWLogError([Explanation class], @"Could not connect to User-Store!");
    }
}

-(UGCCatalog*)ugcCatalog {
    UGCCatalog *uCatalog = nil;
    Catalog *catalog = self.catalogRef;
    NSString *catalogTitle = catalog.title;
    NSString *nameOfPublisher = [catalog publisher];
    LayUserDataStore *userDataStore = [LayUserDataStore store];
    if(userDataStore) {
        uCatalog = [userDataStore findCatalogByTitle:catalogTitle andPublisher:nameOfPublisher];
        if(!uCatalog) {
            uCatalog = [userDataStore insertObject:UGC_OBJECT_CATALOG];
            uCatalog.title = catalogTitle;
            uCatalog.nameOfPublisher = nameOfPublisher;
        }
    } else {
        MWLogError([Explanation class], @"Could not connect to User-Store!");
    }
    return uCatalog;
}

@end
