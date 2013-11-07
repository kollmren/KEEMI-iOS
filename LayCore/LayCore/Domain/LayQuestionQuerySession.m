//
//  LayQuestionQuerySession.m
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayQuestionQuerySession.h"
#import "LayCatalogManager.h"
#import "LayUserDataStore.h"
#import "LayMainDataStore.h"

#import "Question+Utilities.h"
#import "Answer+Utilities.m"
#import "Catalog+Utilities.h"
#import "UGCCatalog+Utilities.h"

#import "MWLogging.h"

static const NSUInteger INIT_NUMBER_OF_QUESTIONS = 20;
static Class g_classObj = nil;

@interface LayQuestionQuerySession() {
    NSMutableDictionary* presentedQuestionMap;
    NSDate* sessionStart;
    id<LayQuestionDatasource> datasource;
    Question* currentQuestion;
}
@end


@implementation LayQuestionQuerySession

@synthesize numberOfWrongAnsweredQuestions, numberOfCorrectAnsweredQuestions,
numberOfSkippedQuestions, neededTime;


+(void)initialize {
    g_classObj = [LayQuestionQuerySession class];
}

-(id) initWithDatasource:(id<LayQuestionDatasource>)datasource_ {
    self = [super init];
    if(self) {
        datasource = datasource_;
        self->presentedQuestionMap = [NSMutableDictionary dictionaryWithCapacity:INIT_NUMBER_OF_QUESTIONS];
        self->sessionStart = [NSDate date];    }
    return self;
}

-(Question*) answeredQuestionByNumber:(NSUInteger)number {
    NSNumber* numberObj = [NSNumber numberWithUnsignedInteger:number];
    Question* question = [self->presentedQuestionMap objectForKey:numberObj];
    return question;
}

-(NSArray*)updatedQuestionList {
    NSMutableArray *changedQuestionList = [NSMutableArray arrayWithCapacity:[self->presentedQuestionMap count]];
    for (Question *question in [self->presentedQuestionMap allValues]) {
        Answer *answer = question.answerRef;
        if([question hasChanges] || [answer hasChanges]) {
            [changedQuestionList addObject:question];
        }
    }
    
    return changedQuestionList;
}

-(void)finish {
    [self rememberPresentedQuestion:self->currentQuestion];
    // Throw away temp session data (transient data)
    // Update UserDataStore and sync the the state of the questions with the MainDataStore
    [self saveUserGeneratedContent];
    LayMainDataStore *mainStore = [LayMainDataStore store];
    BOOL savedChanges = [mainStore saveChanges];
    if(!savedChanges) {
        MWLogError(g_classObj, @"Could not update state of questions to main-store!");
    }
    [self resetTemporarySessionData];
    //
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    catalogManager.selectedQuestions = nil;
    catalogManager.currentSelectedQuestion = nil;
    catalogManager.currentCatalogShouldBeQueriedDirectly = NO;
}

-(void)saveUserGeneratedContent {
    LayUserDataStore *userDataStore = [LayUserDataStore store];
    if(userDataStore) {
        Catalog *currentCatalog = [self->datasource catalog];
        NSString *catalogTitle = currentCatalog.title;
        NSString *nameOfPublisher = [currentCatalog publisher];
        UGCCatalog *uCatalog = [userDataStore findCatalogByTitle:catalogTitle andPublisher:nameOfPublisher];
        if(!uCatalog) {
            uCatalog = [userDataStore insertObject:UGC_OBJECT_CATALOG];
            uCatalog.title = catalogTitle;
            uCatalog.nameOfPublisher = nameOfPublisher;
        }
        [uCatalog syncStateOfQuestions:[self updatedQuestionList]];
    } else {
        MWLogError(g_classObj, @"Could not save user generated data!");
    }
}

-(NSTimeInterval)neededTime {
    NSDate *sessionEnd = [NSDate date];
    NSTimeInterval neededTime_ = [sessionEnd timeIntervalSinceDate:sessionStart];
    return neededTime_;
}

-(void)dealloc {
    MWLogDebug(g_classObj, @"dealloc");
}

-(void)rememberPresentedQuestion:(Question*)question {
    if(question) {
        NSNumber *questionNumber = [question questionNumber];
        Question* alreadyPresentedQuestion = [self->presentedQuestionMap objectForKey:questionNumber];
        if(alreadyPresentedQuestion==nil) {
            [self->presentedQuestionMap setObject:question forKey:questionNumber];
        }
        
        [self updateSessionNumberProperties];
    }
}

-(void)resetTemporarySessionData {
    for (Question *question in [self->presentedQuestionMap allValues]) {
        [question setIsChecked:NO];
        Answer *answer = question.answerRef;
        answer.sessionAnswer = nil;
        answer.correctAnsweredByUser = [NSNumber numberWithBool:NO];
        answer.sessionGivenByUser = [NSNumber numberWithBool:NO];
        for (AnswerItem *item in [answer answerItemListOrderedByNumber]) {
            item.setByUser =  [NSNumber numberWithBool:NO];
            item.sessionNumber = [NSNumber numberWithUnsignedInteger:0];
        }
    }
}

-(void)updateSessionNumberProperties {
    numberOfSkippedQuestions = 0;
    numberOfWrongAnsweredQuestions = 0;
    numberOfCorrectAnsweredQuestions = 0;
    NSArray* presentedQuestionList = [self->presentedQuestionMap allValues];
    for (Question *question in presentedQuestionList) {
        Answer* answer = question.answerRef;
        BOOL hasSetUserAnswer = [answer answeredByUser];
        if(!hasSetUserAnswer) {
            numberOfSkippedQuestions++;
        } else if([answer.correctAnsweredByUser boolValue]) {
            numberOfCorrectAnsweredQuestions++;
        } else {
            numberOfWrongAnsweredQuestions++;
        }
    }
}

//
// LayQuestionDatasource
//
-(Catalog*) catalog {
    Catalog *catalog = nil;
    if(self->datasource) catalog = [self->datasource catalog];
    return catalog;
}
// Returns nil if there is no questions or the end of the list of questions is reached
-(Question*) nextQuestion {
    Question* question = nil;
    if(self->currentQuestion) {
        [self rememberPresentedQuestion:self->currentQuestion];
    }
    if(self->datasource) question = [self->datasource nextQuestion];
    self->currentQuestion = question;
    return question;
}

-(Question*) previousQuestion {
    Question* question = nil;
    [self rememberPresentedQuestion:self->currentQuestion];
    if(self->datasource) question = [self->datasource previousQuestion];
    self->currentQuestion = question;
    return question;
}

-(NSUInteger) numberOfQuestions {
    NSUInteger number = 0;
    if(self->datasource) number = [self->datasource numberOfQuestions];
    return number;
}

-(NSUInteger) currentQuestionCounterValue {
    NSUInteger number = 0;
    if(self->datasource) number = [self->datasource currentQuestionCounterValue];
    return number;
}

@end
