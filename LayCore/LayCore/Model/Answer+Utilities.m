//
//  Answer+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Answer+Utilities.h"
#import "LayDataStoreUtilities.h"
#import "AnswerItem+Utilities.h"
#import "Question+Utilities.h"
#import "Catalog+Utilities.h"
#import "AnswerMedia.h"
#import "Media+Utilities.h"
#import "Explanation+Utilities.h"
#import "MWLogging.h"

@implementation Answer (Utilities)

-(NSArray*)answerItemRespectingLearnState {
    NSArray* itemList = nil;
    if( [self.shuffleAnswers boolValue] ) {
        NSMutableArray *itemsOrderedByLEarnState = [[NSMutableArray alloc]initWithCapacity:[self.answerItemRef count]];
        for (AnswerItem *item in self.answerItemRef) {
            [itemsOrderedByLEarnState addObject:item];
        }
        itemList = itemsOrderedByLEarnState;
    } else {
        itemList = [self answerItemListOrderedByNumber];
    }
    return itemList;
}

-(NSArray*)answerItemListSessionOrderPreserved {
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.answerItemRef count]];
    BOOL itemListIsSessionPreserved = [self answerItemListIsPreserved];
    if( !itemListIsSessionPreserved ) {
        NSArray *itemList = nil;
        BOOL shuffleAnswers = [self.shuffleAnswers boolValue];
        if(shuffleAnswers) {
            itemList = [self answerItemListRandom];
        } else {
            itemList = [self answerItemListOrderedByNumber];
        }
        NSUInteger sessionNumber = 1;
        for (AnswerItem* answerItem in itemList) {
            answerItem.sessionNumber = [NSNumber numberWithUnsignedInteger:sessionNumber];
            [sortedList addObject:answerItem];
            ++sessionNumber;
        }
    } else {
        NSMutableArray* itemsUsedInSession = [[NSMutableArray alloc]initWithCapacity:[self.answerItemRef count]];
        for (AnswerItem *item in self.answerItemRef) {
            NSInteger sessionNumber = [[item sessionNumber]integerValue];
            if(sessionNumber != 0 ) {
                [itemsUsedInSession addObject:item];
            }
        }
       [sortedList setArray:itemsUsedInSession];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"sessionNumber"
                            ascending:YES];
    [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    NSInteger numberOfVisiibleCorrectItems = [self.numberOfVisibleChoices integerValue];
    if(numberOfVisiibleCorrectItems > 0 ) {
        [self adjustAnswerItemList:sortedList toNumberOfVisibleCorrectItems:numberOfVisiibleCorrectItems];
    }
    
    return sortedList;
}

-(NSArray*)answerItemListRandom {
    NSMutableArray *answerItemList = [NSMutableArray arrayWithCapacity:[self.answerItemRef count]];
    [answerItemList setArray:[self.answerItemRef allObjects]];
    for (NSUInteger x = 0; x < [answerItemList count]; x++) {
        NSUInteger randInt = (random() % ([answerItemList count] - x)) + x;
        [answerItemList exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
    return answerItemList;
}

-(BOOL)answerItemListIsPreserved {
    BOOL preserved = NO;
    for (AnswerItem *item in self.answerItemRef) {
        NSUInteger sessionNumberPrimitiv = [item.sessionNumber unsignedIntegerValue];
        if(sessionNumberPrimitiv != 0) {
            preserved = YES;
            break;
        }
    }
    return preserved;
}

-(NSArray*)answerItemListOrderedByNumber {
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.answerItemRef count]];
    for (AnswerItem *answerItem in self.answerItemRef) {
        [sortedList addObject:answerItem];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    return sortedList;
}

-(void)adjustAnswerItemList:(NSMutableArray*)answerItemList toNumberOfVisibleCorrectItems:(NSInteger)numberOfVisibleCorrectItems {
    if(numberOfVisibleCorrectItems <= 0) return;
    
    NSMutableArray *indexesOfCorrectItems = [NSMutableArray arrayWithCapacity:[answerItemList count]];
    NSInteger index = 0;
    for (AnswerItem *item in answerItemList) {
        if([item.correct boolValue]) {
            [indexesOfCorrectItems addObject:[NSNumber numberWithInteger:index]];
        }
        ++index;
    }
    
    NSUInteger numberOfCorrectItems = [indexesOfCorrectItems count];
    if( numberOfVisibleCorrectItems < numberOfCorrectItems ) {
        const NSUInteger numberOfAnswerItemsToRemove = numberOfCorrectItems - numberOfVisibleCorrectItems;
        for (NSUInteger x = 0; x < numberOfCorrectItems; x++) {
            NSUInteger randInt = (random() % (numberOfCorrectItems - x)) + x;
            [indexesOfCorrectItems exchangeObjectAtIndex:x withObjectAtIndex:randInt];
        }
        
        NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSet];
        for (NSInteger itemToRemoveIdx = 0; itemToRemoveIdx < numberOfAnswerItemsToRemove; ++itemToRemoveIdx) {
            NSNumber *indexObj = [indexesOfCorrectItems objectAtIndex:itemToRemoveIdx];
            NSInteger indexOfItem = [indexObj integerValue];
            // reset the session number for the item
            AnswerItem *item = [answerItemList objectAtIndex:indexOfItem];
            item.sessionNumber = [NSNumber numberWithInteger:0];
            [indexesToRemove addIndex:indexOfItem];
        }
        
        [answerItemList removeObjectsAtIndexes:indexesToRemove];
    
    } else {
        MWLogError([Answer class], @"Number of correct items to show is greater as the number of correct items available!");
    }
}

-(AnswerItem*)answerItemInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    AnswerItem *answerItem = [LayDataStoreUtilities insertDomainObject: LayAnswerItem :context];
    NSUInteger numberAsPrimitive = [self.answerItemRef count] + 1;
    answerItem.number = [NSNumber numberWithUnsignedInteger:numberAsPrimitive];
    answerItem.answerRef = self;
    return answerItem;
}

-(void)addAnswerItem:(AnswerItem*)answerItem {
    [self addAnswerItemRefObject:answerItem];
}

-(NSArray*)mediaList {
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.answerMediaRef count]];
    for (AnswerMedia* answerMedia in self.answerMediaRef) {
        [sortedList addObject:answerMedia];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    NSMutableArray* sortedMediaList = [[NSMutableArray alloc]initWithCapacity:[self.answerMediaRef count]];
    for (AnswerMedia* answerMedia in sortedList) {
        [sortedMediaList addObject:answerMedia.mediaRef];
    }
    
    return sortedMediaList;
}

-(NSArray*)answerMediaList {
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.answerMediaRef count]];
    for (AnswerMedia* answerMedia in self.answerMediaRef) {
        [sortedList addObject:answerMedia];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return sortedList;
}

-(void)addMedia:(Media*)mediaItem linkedWith:(AnswerItem*)answerItem {
    NSManagedObjectContext* context = self.managedObjectContext;
    AnswerMedia *answerMedia = [LayDataStoreUtilities insertDomainObject: LayAnswerMedia :context];
    answerMedia.mediaRef = mediaItem;
    NSUInteger numberPrimitive = [self.answerMediaRef count] + 1;
    answerMedia.number = [NSNumber numberWithUnsignedInteger:numberPrimitive];
    answerMedia.answerRef = self;
    if(answerItem) {
        answerMedia.answerItemRef = answerItem;
        answerItem.answerMediaRef = answerMedia;
    }
    [self addAnswerMediaRefObject:answerMedia];
}

-(void)addMedia:(Media*)media {
    [self addMedia:media linkedWith:nil];
}

-(void)setExplanation:(Explanation*)explanation {
    self.explanationRef = explanation;
}

-(BOOL) hasExplanation {
    BOOL hasExplanation = NO;
    if(self.explanationRef) {
        hasExplanation = YES;
    }
    return hasExplanation;
}

-(Explanation*) explanation {
    return self.explanationRef;
}

-(BOOL)answeredByUser {
    BOOL answeredByUser = NO;
    for (AnswerItem *item in self.answerItemRef) {
        if([item.setByUser boolValue]) {
            answeredByUser = YES;
            break;
        }
    }
    
    // Question of type wordResponse don't set an item but the sessionAnswer
    if(!answeredByUser && self.sessionAnswer) {
        answeredByUser = YES;
    }
    
    return answeredByUser;
}

-(LayAnswerStyleType)styleType {
    LayAnswerStyleType styleType = [LayAnswerStyle styleTypeForDescription:self.style];
    return styleType;
}

@end


//
// LayAnswerItemStyle
//
static NSString* styleColumnDescription = @"column";

@implementation LayAnswerStyle

@synthesize plainStyleDescription;

static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayAnswerStyle class];
}

+(id)styleWithString:(NSString*)styleDescription {
    LayAnswerStyle *style = [[LayAnswerStyle alloc]initWithStyleDescription:styleDescription];
    return style;
}

-(id)initWithStyleDescription:(NSString*)plainStyleDescription_ {
    self = [super init];
    if(self) {
        self->listWithPossibleStyles = [NSArray arrayWithObjects:styleColumnDescription, nil];
        self->styleList = [NSMutableArray arrayWithCapacity:4];
        plainStyleDescription = plainStyleDescription_;
        if([self processStyle:plainStyleDescription_]) {
            return self;
        } else {
            return nil;
        }
    }
    return nil;
}

-(BOOL)hasStyle:(LayAnswerStyleType)styleType {
    BOOL hasStyle = NO;
    NSNumber *styleTypeNumber = [NSNumber numberWithInteger:styleType];
    if([self->styleList containsObject:styleTypeNumber]) {
        hasStyle = YES;
    }
    return hasStyle;
}

-(BOOL)processStyle:(NSString*)plainStyleDescription_ {
    BOOL validStyle = YES;
    NSString* styleSeparator = @";";
    NSArray *styleDescriptionList = [plainStyleDescription_ componentsSeparatedByString:styleSeparator];
    for (NSString* possibleStyle in self->listWithPossibleStyles) {
        if([styleDescriptionList containsObject:possibleStyle]) {
            LayAnswerStyleType styleType = [LayAnswerStyle styleTypeForDescription:possibleStyle];
            NSNumber *styleTypeNumber = [NSNumber numberWithInteger:styleType];
            [self->styleList addObject:styleTypeNumber];
        }
    }
    return validStyle;
}

+(LayAnswerStyleType)styleTypeForDescription:(NSString*)description {
    LayAnswerStyleType styleType = NoStyle;
    if([description isEqualToString:styleColumnDescription]) {
        styleType = StyleColumn;
    }
    return styleType;
}

@end
