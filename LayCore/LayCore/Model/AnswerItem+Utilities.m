//
//  AnswerItem+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//
#import "AnswerItem+Utilities.h"
#import "Answer+Utilities.h"
#import "Question+Utilities.h"
#import "Media+Utilities.h"
#import "Catalog+Utilities.h"
#import "Explanation.h"

#import "LayMediaData.h"
#import "LayDataStoreUtilities.h"

#import "MWLogging.h"

@implementation AnswerItem (Utilities)

-(void)setMediaItem:(Media*)mediaItem {
    self.mediaRef = mediaItem;
}

-(LayMediaData*)mediaData {
    LayMediaData *mediaData = nil;
    if(self.mediaRef) {
        mediaData = [LayMediaData byMediaObject:self.mediaRef];
    }
    return mediaData;
}

-(Media*)mediaInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    Media *media = [LayDataStoreUtilities insertDomainObject: LayMedia :context];
    return media;
}

-(Media*)media {
    return self.mediaRef;
}

-(BOOL)hasMedia {
    BOOL hasMedia = NO;
    if(self.mediaRef) {
        hasMedia = YES;
    }
    return hasMedia;
}

-(NSNumber*)itemNumber {
    NSNumber* number = [NSNumber numberWithShort:self.number];
    return number;
}

-(AnswerMedia*) answerMedia {
    return self.answerMediaRef;
}

-(Explanation*)explanationInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    Explanation *explanation = [LayDataStoreUtilities insertDomainObject: LayExplanation :context];
    return explanation;
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

-(void)deleteAnswerItem {
    [self.managedObjectContext deleteObject:self];
}

@end
