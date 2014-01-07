//
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayOrderedQuestionDatasource.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"

#import "MWLogging.h"

@implementation LayOrderedQuestionDatasource

-(id)initWithCatalog:(Catalog*)catalog_ {
    self = [super init];
    if(self) {
        self->catalog = catalog_;
        self->questionList = [self->catalog questionListSortedByNumber];
        self->index = 0;
        self->firstQuestionPassed = NO;
    }
    return self;
}

-(id)initWithCatalog:(Catalog*)catalog_ andQuestionList:(NSArray*)listOfQuestions {
    self = [super init];
    if(self) {
        self->catalog = catalog_;
        self->questionList = listOfQuestions;
        self->index = 0;
        self->firstQuestionPassed = NO;
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayOrderedQuestionDatasource class], @"dealloc");
}

-(void)setStartQuestionTo:(Question*)questionToStartWith {
    self->index = [questionToStartWith numberAsPrimitive] - 1;
}

//
// LayQuestionDatasource
//
-(Catalog*) catalog {
    return self->catalog;
}

-(Question*) nextQuestion {
    Question *question = nil;
    if(firstQuestionPassed && self->index < ([self->questionList count] - 1)) {
        self->index++;
    }
    
    MWLogDebug([LayOrderedQuestionDatasource class], @"Get question with index:%u",self->index);
    question = [questionList objectAtIndex:self->index];
    firstQuestionPassed = YES;
    return question;
}

-(Question*) previousQuestion {
    Question *question = nil;
    if(self->index > 0) {
        self->index--;
        MWLogDebug([LayOrderedQuestionDatasource class], @"Get(previous) question with index:%u",self->index);
    } else {
        self->index = 0;
    }
    
    question = [questionList objectAtIndex:self->index];
    
    return question;;
}

-(NSUInteger) numberOfQuestions {
    return [self->questionList count];
}

-(NSUInteger) currentQuestionCounterValue {
    return self->index + 1;
}

-(NSUInteger)currentQuestionGroupCounterValue {
    return 0;
}

-(BOOL) hasNextGroupedQuestion {
    return NO;
}

-(void)stopFollowingCurrentQuestionGroup {
    
}

@end
