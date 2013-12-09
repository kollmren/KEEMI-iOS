//
//  Question+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Media+Utilities.h"
#import "AnswerMedia.h"
#import "Introduction.h"
#import "Thumbnail.h"
#import "LayDataStoreUtilities.h"

#import "LayUserDataStore.h"
#import "UGCCatalog+Utilities.h"
#import "UGCQuestion+Utilities.h"
#import "UGCResource+Utilities.h"

#import "MWLogging.h"

@implementation Question (Utilities)

-(Answer*)answerInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    Answer *answer = [LayDataStoreUtilities insertDomainObject: LayAnswer :context];
    answer.questionRef = self;
    return answer;
}

-(Introduction*)introductionInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    Introduction *intro = [LayDataStoreUtilities insertDomainObject: LayIntroduction :context];
    intro.title = NSLocalizedString(@"QuestionIntroTitle", nil);
    self.introRef = intro;
    return intro;
}

-(void)setAnswer:(Answer*)answer {
    self.answerRef = answer;
}

-(NSNumber*)questionNumber {
    return self.number;
}

-(NSUInteger)numberAsPrimitive {
    NSUInteger value = 0;
    if(self.number) {
        value = [self.number unsignedIntegerValue];
    }
    return value;
}

-(void)setQuestionNumber:(NSUInteger)number {
    self.number = [NSNumber numberWithUnsignedInteger:number];
}

-(void)setQuestionType:(NSUInteger)type {
    self.type = [NSNumber numberWithUnsignedInteger:type];
}

-(LayAnswerTypeIdentifier) questionType {
    NSUInteger typeAsPrimitive = [self.type unsignedIntegerValue];
    switch (typeAsPrimitive) {
        case ANSWER_TYPE_MULTIPLE_CHOICE:
            break;
        case ANSWER_TYPE_MAP:
            break;
        case ANSWER_TYPE_SINGLE_CHOICE:
            break;
        case ANSWER_TYPE_MULTIPLE_CHOICE_LARGE_MEDIA:
            break;
        case ANSWER_TYPE_SINGLE_CHOICE_LARGE_MEDIA:
            break;
        case ANSWER_TYPE_ASSIGN:
            break;
        case ANSWER_TYPE_CARD:
            break;
        case ANSWER_TYPE_WORD_RESPONSE:
            break;
        default:
            MWLogError([Question class], @"Unknown type:%u of answerType!", typeAsPrimitive);
            break;
    }
    return typeAsPrimitive;
}

-(BOOL)isChecked {
    BOOL isChecked = NO;
    if([self.checked boolValue]) {
        isChecked = [self.checked boolValue];
    }
    return isChecked;
}

-(void)setIsChecked:(BOOL)checked {
    self.checked = [NSNumber numberWithBool:checked];
    for ( AnswerItem* item in [self.answerRef answerItemListSessionOrderPreserved] ) {
        if([item.setByUser boolValue]) {
            if([item.correct boolValue]) {
                NSInteger knownCounter = [item.sessionKnownByUser integerValue];
                knownCounter++;
                item.sessionKnownByUser = [NSNumber numberWithInteger:knownCounter];
            } else {
                NSInteger unknownCounter = [item.sessionUnknownByUser integerValue];
                unknownCounter++;
                item.sessionUnknownByUser = [NSNumber numberWithInteger:unknownCounter];
            }
        } else {
            if([item.correct boolValue]) {
                NSInteger unknownCounter = [item.sessionUnknownByUser integerValue];
                unknownCounter++;
                item.sessionUnknownByUser = [NSNumber numberWithInteger:unknownCounter];
            }
        }
    }
}

-(void)setTopic:(Topic*)topic {
    self.topicRef = topic;
}

-(NSUInteger)caseNumberPrimitive {
    return [self.caseNumber unsignedIntegerValue];
}

-(void)setCaseNumberPrimitive:(NSUInteger )caseNumber {
    NSNumber *number = [NSNumber numberWithUnsignedInteger:caseNumber];
    self.caseNumber = number;
}

-(BOOL)hasLinkedResources {
    BOOL hasLinkedResources = NO;
    if([self.resourceRef count] > 0 || [[self ugcResourceList] count] > 0 ) {
        hasLinkedResources = YES;
    }
    return hasLinkedResources;
}

-(NSArray*)resourceList {
    NSMutableArray* sortedTopicList = [[NSMutableArray alloc]initWithCapacity:[self.resourceRef count]];
    for (Resource* t in self.resourceRef) {
        [sortedTopicList addObject:t];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedTopicList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    NSArray *ugcResourceList = [self ugcResourceList];
    [sortedTopicList addObjectsFromArray:ugcResourceList];
    
    return sortedTopicList;
}

-(NSArray*)ugcResourceList {
    LayUserDataStore *userDataStore = [LayUserDataStore store];
    UGCCatalog *uCatalog = [userDataStore findCatalogByTitle:self.catalogRef.title andPublisher:[self.catalogRef publisher]];
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.resourceRef count]];
    if(uCatalog) {
        UGCQuestion *uQuestion = [uCatalog questionByName:self.name];
        if(uQuestion) {
            for(UGCResource* resource in uQuestion.resourceRef) {
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
        UGCQuestion *uQuestion = [uCatalog questionByName:self.name];
        if(uQuestion) {
            for(UGCNote* note in uQuestion.noteRef) {
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

-(void)markQuestionAsFavourite {
    self.favourite = [NSNumber numberWithBool:YES];
}

-(void)unmarkQuestionAsFavourite {
    self.favourite = [NSNumber numberWithBool:NO];
}

-(BOOL)isFavourite {
    BOOL isFavourite = NO;
    isFavourite = [self.favourite boolValue];
    return isFavourite;
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
        MWLogError([Question class], @"Could not connect to User-Store!");
    }
    return uCatalog;
}

-(NSArray*)imageMediaList {
    NSMutableArray *questionImageList = [NSMutableArray arrayWithCapacity:10];
    Answer *answer = self.answerRef;
    for (AnswerMedia* answerMedia in answer.answerMediaRef) {
        if(answerMedia.mediaRef && [answerMedia.mediaRef isImage]) {
            [questionImageList addObject:answerMedia.mediaRef];
        }
    }
    
    for (AnswerItem* answerItem in answer.answerItemRef) {
        if(answerItem.mediaRef && [answerItem.mediaRef isImage]) {
            [questionImageList addObject:answerItem.mediaRef ];
        }
    }

    return questionImageList;
}

-(NSArray*)orderedThumbnailList {
    NSMutableArray *sortedList = [NSMutableArray arrayWithCapacity:[self.thumbnailRef count]];
    for (Thumbnail *thumbnail in self.thumbnailRef) {
        [sortedList addObject:thumbnail];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    return sortedList;
}

-(NSArray*)orderedThumbnailListAsMediaData {
    NSArray *orderedThumbnailList = [self orderedThumbnailList];
    NSMutableArray *thumbnailMediaDataList = [NSMutableArray arrayWithCapacity:[orderedThumbnailList count]];
    for (Thumbnail *thumbnail in orderedThumbnailList) {
        LayMediaData *mediaData = nil;
        if(thumbnail.data) {
            mediaData = [LayMediaData byData:thumbnail.data type:LAY_MEDIA_IMAGE andFormat:LAY_FORMAT_PNG];
        } else {
            mediaData = [LayMediaData byMediaObject:thumbnail.mediaRef];
        }
        [thumbnailMediaDataList addObject:mediaData];
    }
   
    return thumbnailMediaDataList;
}

-(BOOL)hasThumbnails {
    BOOL hasThumbnails = NO;
    if([self.thumbnailRef count] > 0) {
        hasThumbnails = YES;
    }
    
    return hasThumbnails;
}

@end
