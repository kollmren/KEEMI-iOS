//
//  LayQuestionDatasourceDummy.m
//  LayCore
//
//  Created by Rene Kollmorgen on 08.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayQuestionDatasourceDummy.h"

#import "Catalog+Utilities.h"

@implementation LayQuestionDatasourceDummy

-(id)initWithCatalog:(Catalog*)catalog_ {
    self = [super init];
    if(self) {
        self->catalog = catalog_;
        self->questionList = [self->catalog questionListSortedByNumber];
        self->index = 0;
    }
    return self;
}

-(void)resetIndex {
    self->index = 0;
}

//
// LayQuestionDatasource
//
-(Catalog*) catalog {
    return self->catalog;
}

-(Question*) nextQuestion {
    Question *question = [questionList objectAtIndex:self->index];
    if(self->index < [self->questionList count] - 1) self->index++;
    return question;
}

-(Question*) previousQuestion {
    Question *question = nil;
    if(self->index > 0) {
        self->index--;
        question = [questionList objectAtIndex:self->index];
    }
    return question;
}

-(NSUInteger) numberOfQuestions {
    return [self->questionList count];
}

-(NSUInteger) currentQuestionCounterValue {
    return self->index + 1;
}

@end
