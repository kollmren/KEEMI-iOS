//
//  LayCatalogDataFile_HeadFirstDesignPattern.m
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayCatalogDataFile_CitizenTest.h"
#import "LayTestDataHelper.h"

#import "Catalog+Utilities.h"
#import "Answer+Utilities.h"
#import "Question+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Explanation+Utilities.h"

#import "LayAnswerType.h"

@interface LayCatalogDataFile_CitizenTest() {
    NSInteger numberOfQuestions;
    NSInteger numberOfCatalog;
    NSString* pathToTestDataTemplate;
    Catalog* catalogRef;
}
@end

@implementation LayCatalogDataFile_CitizenTest

-(id)init {
    self = [super init];
    if(self) {
        g_titleTemplate = @"Einbürgerungstest Deutschland %d";
        pathToTestDataTemplate = @"TestData/germanCitizenshipTest/%@";
        numberOfCatalog = 0;
        numberOfQuestions = 10;
    }
    return self;
}

static NSString* g_titleTemplate;

-(void)data:(Catalog*)catalog {
    self->catalogRef = catalog;
    numberOfCatalog++;
    NSString *title = [[NSString alloc]initWithFormat:g_titleTemplate, numberOfCatalog];
    catalog.title = title;
    NSData* const cover = [LayTestDataHelper getDataOfFile:@"TestData/citizenTest" andType:@"jpeg"];
    [catalog setCoverImage:cover withType:LAY_FORMAT_JPG];
    catalog.catalogDescription = @"A detailed description ....";
    [catalog setAuthor:@"Bundesministerium des Inneren"];
    [catalog setPublisher:@"Bundesministerium des Inneren"];
    NSData* const logo = [LayTestDataHelper getDataOfFile:@"TestData/germanCitizenshipTest/bmi_logo" andType:@"png"];
    [catalog setPublisherLogo:logo withType:LAY_FORMAT_PNG];
    const int MAX_QUESTIONS_TO_IMPORT = 30;
    for (int i=1; i<=MAX_QUESTIONS_TO_IMPORT; ++i) {
        Question *question = [catalog questionInstance];
        [question setQuestionType:ANSWER_TYPE_MULTIPLE_CHOICE];
        [question setQuestionNumber:i];
        NSString* methodName = [@"question" stringByAppendingString:[NSString stringWithFormat:@"%d:", i]];
        SEL selector = NSSelectorFromString(methodName);
        if ([self respondsToSelector: selector]) {
            [self performSelector:selector withObject:question];
            [catalog addQuestion:question];
        } else {
            if(i%3) {
                question.question = [NSString stringWithFormat:@"This is question number %d",i];
            } else {
                question.question = [NSString stringWithFormat:@"This is a long question. The question has the number %d. Every question has a number. The number can be used to ...",i];
            }
            if(i%2) {
                NSString *intro = [NSString stringWithFormat:@"This is an introduction! The number of the intro is %d. An intro can be long!",i];
                question.introduction = intro;
            }
            [self addAnswersTo:question];
            [catalog addQuestion:question];
        }
    }
}

-(void)addAnswersTo:(Question*)question {
    Answer *answer = [question answerInstance];
    answer.number = 1;
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer";
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer";
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

-(NSString*)titleOfCatalog {
    return [[NSString alloc]initWithFormat:g_titleTemplate, numberOfCatalog];
}

-(NSString*)nameOfPublisher {
    return @"Bund";
}

-(void)setNumberOfQuestions:(NSInteger)num {
    self->numberOfQuestions = num;
}

-(NSInteger) numberOfQuestions {
    return self->numberOfQuestions;
}


-(void)question1:(Question*)question {
    question.question = @"Welches Wappen gehört zum Bundesland Berlin?";
    Answer *answer = [question answerInstance];
    answer.number = 1;
    [question setQuestionType:ANSWER_TYPE_SINGLE_CHOICE];
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.style = @"column;keep-height";
    NSString *filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"berlinWappen01"];
    [LayTestDataHelper addFileAsMediaToAnswerItem:answerItem file:filePath type:@"png"];
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.style = @"column;keep-height";
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"berlinWappen02"];
    answerItem.text = @"Dies ist ein Text in einem Button. Dies ist ein Text in einem Button. Dies ist ein Text in einem Button. Dies ist ein Text in einem Button. Dies ist ein Text in einem Button. Dies ist ein Text in einem Button. Dies ist ein Text in einem Button. Dies ist ein Text in einem Button. Dies ist ein Text in einem Button.";
    [LayTestDataHelper addFileAsMediaToAnswerItem:answerItem file:filePath type:@"png"];
    [answer addAnswerItem:answerItem];
    
    
    answerItem = [answer answerItemInstance];
    answerItem.style = @"column;keep-height";
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"berlinWappen03"];
    [LayTestDataHelper addFileAsMediaToAnswerItem:answerItem file:filePath type:@"png"];
    NSString* info = @"Info";
    Explanation *explanation = [self->catalogRef explanationInstance];
    [explanation addShortExplanationText:info];
    [answerItem setExplanation:explanation];
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.style = @"column;keep-height";
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"berlinWappen04"];
    [LayTestDataHelper addFileAsMediaToAnswerItem:answerItem file:filePath type:@"png"];
    answerItem.correct = [NSNumber numberWithBool:YES];
    info = @"Das Wappen des Landes und der Stadt Berlin zeigen den Berliner Bären. Der Bär war nicht von Anbeginn das Symbol der Stadt. Über mehrere Jahrhunderte teilte sich der Bär die Siegel- und Wappenbilder mit dem brandenburgischen und preußischen Adler. Warum sich die Berliner für den Bären als Wappentier entschieden, lässt sich aufgrund fehlender Unterlagen nicht eindeutig klären. Die Gestaltung der Siegel- und Wappenbilder wurde zum Teil durch politische und geschichtliche Ereignisse beeinflusst. Das Wappen in seiner heutigen Form ist seit 1954 gültig. Die Bezirke der Stadt führen neben dem Landeswappen eigene Bezirkswappen, die sie zur Darstellung der Bezirke verwenden können.";
    explanation = [self->catalogRef explanationInstance];
    [explanation addShortExplanationText:info];
    [answerItem setExplanation:explanation];
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

-(void)question2:(Question*)question {
    question.question = @"Welches ist das Wappen der Bundesrepublik Deutschland?";
    Answer *answer = [question answerInstance];
    answer.number = 1;
    [question setQuestionType:ANSWER_TYPE_SINGLE_CHOICE];
    AnswerItem *answerItem = [answer answerItemInstance];
    NSString *filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"deutschlandWappen01"];
    [LayTestDataHelper addFileAsMediaToAnswerItem:answerItem file:filePath type:@"png"];
    answerItem.text = @"Das ist das Wappen der Bundesrepublik.";
    answerItem.correct = YES;
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"deutschlandWappen02"];
    [LayTestDataHelper addFileAsMediaToAnswerItem:answerItem file:filePath type:@"png"];
    [answer addAnswerItem:answerItem];
    
    
    answerItem = [answer answerItemInstance];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"deutschlandWappen03"];
    [LayTestDataHelper addFileAsMediaToAnswerItem:answerItem file:filePath type:@"png"];
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    //filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"deutschlandWappen04"];
    //[LayTestDataHelper addFileAsMediaToAnswerItem:answerItem file:filePath type:@"png"];
    answerItem.text = @"Das ist das Wappen der Bundesrepublik. Das ist das Wappen der Bundesrepublik.";
    answerItem.style = @"keep-height";
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

-(void)question3:(Question*)question {
    question.question = @"Die folgende Aussage ist korrekt? Alle auf den Bildern dargestellten Personen waren einmal Bundeskanzler der Bundesrepublik Deutschland.";
    Answer *answer = [question answerInstance];
    answer.number = 1;
    [question setQuestionType:ANSWER_TYPE_MULTIPLE_CHOICE];
    NSString *filePath = nil;
    
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"Willy_Brandt"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpg" linkedWith:nil];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"Ludwig_Erhard"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpg" linkedWith:nil];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"otto"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpg" linkedWith:nil];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"Konrad_Adenauer"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpg" linkedWith:nil];
    
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"Ja";
    answerItem.correct = NO;
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"Nein";
    answerItem.correct = YES;
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

-(void)question4:(Question*)question {
    question.question = @"Was zeigen diese Bilder?";
    Answer *answer = [question answerInstance];
    answer.number = 1;
    [question setQuestionType:ANSWER_TYPE_ASSIGN];
    
    NSString *filePath = nil;
    
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"den Bundestagssitz in Berlin";
    answerItem.correct = [NSNumber numberWithBool:YES];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"bundestag"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpeg" linkedWith:answerItem];
    NSString* info = @"Info";
    Explanation *explanation = [self->catalogRef explanationInstance];
    [explanation addShortExplanationText:info];
    [answerItem setExplanation:explanation];
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"das Bundesverfassungsgericht in Karlsruhe";
    answerItem.correct = [NSNumber numberWithBool:YES];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"bundesverfassungsgericht"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpeg" linkedWith:answerItem];
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"das Bundesratsgebäude in Berlin";
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"das Bundeskanzleramt in Berlin";
    answerItem.correct = [NSNumber numberWithBool:YES];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"kanzleramt"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpeg" linkedWith:answerItem];
    info = @"Info";
    explanation = [self->catalogRef explanationInstance];
    [explanation addShortExplanationText:info];
    [answerItem setExplanation:explanation];
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

/*-(void)question5:(Question*)question {
    question.question = @"Die folgende Aussage ist korrekt? Alle auf den Bildern dargestellten Personen waren einmal Bundeskanzler der Bundesrepublik Deutschland.";
    Answer *answer = [question answerInstance];
    answer.number = 1;
    answer.type = ANSWER_TYPE_MULTIPLE_CHOICE;
    NSString *filePath = nil;
    
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"Willy_Brandt"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpg" linkedWith:nil];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"Ludwig_Erhard"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpg" linkedWith:nil];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"otto"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpg" linkedWith:nil];
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"Konrad_Adenauer"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpg" linkedWith:nil];
    
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"Ja";
    answerItem.correct = NO;
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"Nein";
    answerItem.correct = YES;
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}*/

-(void) fill:(Question*)question withData:(NSString*) data {
    NSArray* fields = [data componentsSeparatedByString:@"<;;>"];
    question.question = [self retrieveQuestion:fields];
    NSDictionary* answerData = [self retrieveAnswerData:fields];
    if(answerData) {
        Answer *answer = [question answerInstance];
        answer.additionalData = [answerData objectForKey:@"AdditionalData"];
        answer.number = 1; 
        [question setQuestionType:ANSWER_TYPE_MAP];
        NSString *fileName = [answerData objectForKey:@"Filepath"];
        NSString *filePath = [NSString stringWithFormat:@"TestData/ownImages/%@", fileName];
        [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:[answerData objectForKey:@"Extension"]];
        
        NSArray* answerItemsData = [self retrieveAnswerItemData:fields];
        for(NSDictionary* answerItemData in answerItemsData) {
            AnswerItem *answerItem = [answer answerItemInstance];
            answerItem.text = [answerItemData objectForKey:@"Text"];
            answerItem.additionalData = [answerItemData objectForKey:@"AdditionalData"];
            [answer addAnswerItem:answerItem];
        }
        
        [question setAnswer:answer];
    }
}

-(NSString*) retrieveQuestion:(NSArray*)fields {
    for(NSString* s in fields) {
        if([s hasPrefix:@"DataType<:>Question<;>"]) {
            NSArray* fields = [s componentsSeparatedByString:@"<;>"];
            return [fields objectAtIndex:1];
        }
    }
    return nil;
}

-(NSDictionary*) retrieveAnswerData:(NSArray*)fields {
    for(NSString* s in fields) {
        if([s hasPrefix:@"DataType<:>Answer<;>"]) {
            return [self splitData:s];
        }
    }
    return nil;
}

-(NSArray*) retrieveAnswerItemData:(NSArray*)fields {
    NSMutableArray* result = [NSMutableArray new];
    for(NSString* s in fields) {
        if([s hasPrefix:@"DataType<:>AnswerItem<;>"]) {
            [result addObject:[self splitData:s]];
        }
    }
    return result;
}

-(NSDictionary*) splitData:(NSString*)data {
    NSMutableDictionary* result = [NSMutableDictionary new];
    NSArray* fields = [data componentsSeparatedByString:@"<;>"];
    for(NSString* s in fields) {
        NSArray* d = [s componentsSeparatedByString:@"<:>"];
        [result setObject:[d objectAtIndex:1] forKey:[d objectAtIndex:0]];
    }
    return result;
}

@end
