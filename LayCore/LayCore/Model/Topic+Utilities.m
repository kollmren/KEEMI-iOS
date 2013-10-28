//
//  Topic+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 19.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Topic+Utilities.h"
#import "Catalog+Utilities.h"
#import "LayConstants.h"

#import "MWLogging.h"

@implementation Topic (Utilities)

-(BOOL)hasMedia {
    BOOL hasMedia = NO;
    if(self.mediaRef) {
        hasMedia = YES;
    }
    return hasMedia;
}

-(BOOL)hasExplanations {
    BOOL hasExplanations = NO;
    if(self.explanationRef && [self.explanationRef count] > 0) {
        hasExplanations = YES;
    }
    return hasExplanations;
}

-(BOOL)hasQuestions {
    BOOL hasQuestions = NO;
    if(self.questionRef && [self.questionRef count]>0) {
        hasQuestions = YES;
    }
    return hasQuestions;
}

-(BOOL)isDefaultTopic {
    BOOL isDefaultTopic = NO;
    NSString *importNameOfDefaultTopic = (NSString*)NAME_OF_DEFAULT_TOPIC;
    if([self.name isEqualToString:importNameOfDefaultTopic]) {
        isDefaultTopic = YES;
    }
return isDefaultTopic;
}

-(void)setMedia:(Media*)mediaItem {
    [self setMediaRef:mediaItem];
}

-(Media*)media {
    return self.mediaRef;
}

-(void)setTopicNumber:(NSUInteger)number {
    NSNumber *n = [NSNumber numberWithUnsignedInteger:number];
    [self setNumber:n];
}

-(NSUInteger)numberPrimitive {
    return [self.number unsignedIntegerValue];
}

-(NSSet*)questionSet {
    return self.questionRef;
    /*NSPredicate *predicate = [NSPredicate predicateWithFormat:@"topicRef.name = %@ AND catalogRef.title = %@",
                              self.name, self.catalogRef.title];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Question"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *allQuestionsInTopic = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (allQuestionsInTopic == nil) {
        MWLogError([Catalog class], @"Failure:%@ getting all questions for topic:%@", error, self.name);
    }
    return allQuestionsInTopic;*/
}

-(NSUInteger)numberOfQuestions {
    return [self.questionRef count];
}

-(NSSet*)explanationSet {
    return self.explanationRef;
}

-(NSUInteger)numberOfExplanations {
    return [self.explanationRef count];
}

-(BOOL)topicIsSelected {
    return [self.isSelected boolValue];
}

-(void)setTopicAsSelected {
    self.isSelected = [NSNumber numberWithBool:YES];
}

-(void)setTopicAsNotSelected {
    self.isSelected = [NSNumber numberWithBool:NO];
}

-(Catalog*)catalog {
    return self.catalogRef;
}

@end
