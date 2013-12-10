//
//  LayStatusProgressBar.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 27.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayStatusProgressBar.h"
#import "LayStyleGuide.h"

@interface LayStatusProgressBar() {
    UILabel *label;
    CALayer *incorrectLayer;
    CALayer *correctLayer;
}
@end

@implementation LayStatusProgressBar

@synthesize numberCurrent, numberCurrentCorrectAnswers, numberCurrentIncorrectAnswers, numberTotal, counterGroupedQuestion;

-(id)initWithFrame:(CGRect)frame numberTotal:(NSUInteger)total andNumberCurrent:(NSUInteger)current {
    self = [super initWithFrame:frame];
    if (self) {
        numberTotal = total;
        numberCurrent = current;
        LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
        self.backgroundColor = [style getColor:ButtonBorderColor];
        const CGRect labelFrame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        self->label = [[UILabel alloc]initWithFrame:labelFrame];
        self->label.backgroundColor = [UIColor clearColor];
        self->label.textAlignment = NSTextAlignmentCenter;
        self->label.textColor = [UIColor darkGrayColor];
        //self->label.font = [UIFont boldSystemFontOfSize:frame.size.height];
        self->label.layer.zPosition = 100.0f;
        [self setNumberCurrent:numberCurrent];
        [self addSubview:self->label];
        //
        self->incorrectLayer = [CALayer new];
        self->incorrectLayer.bounds = CGRectMake(0.0f, 0.0f, 0.0f, self.frame.size.height);
        self->incorrectLayer.backgroundColor = [style getColor:AnswerWrong].CGColor;
        self->incorrectLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
        self->correctLayer = [CALayer new];
        self->correctLayer.bounds = CGRectMake(0.0f, 0.0f, 0.0f, self.frame.size.height);
        self->correctLayer.backgroundColor = [style getColor:AnswerCorrect].CGColor;
        self->correctLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
        [self.layer addSublayer:self->correctLayer];
        [self.layer addSublayer:self->incorrectLayer];
        
    }
    return self;
}

-(void)setNumberCurrent:(NSUInteger)numberCurrent_ {
    numberCurrent = numberCurrent_;
    NSString *textFormat = nil;
    NSString *text = nil;
    if(self.counterGroupedQuestion > 0) {
        textFormat = @"%u ( %u ) / %u";
        text = [NSString stringWithFormat:textFormat,self.numberCurrent, self.counterGroupedQuestion ,self.numberTotal ];
    } else {
        textFormat = @"%u / %u";
        text = [NSString stringWithFormat:textFormat,self.numberCurrent,self.numberTotal ];
    }
    
    self->label.text = text;
}

-(void)setNumberCurrentCorrectAnswers:(NSUInteger)numberCurrentCorrectAnswers_ {
    numberCurrentCorrectAnswers = numberCurrentCorrectAnswers_;
    [self updateLayers];
}

-(void)setNumberCurrentIncorrectAnswers:(NSUInteger)numberCurrentIncorrectAnswers_ {
    numberCurrentIncorrectAnswers = numberCurrentIncorrectAnswers_;
    [self updateLayers];
}

-(void)updateLayers {
    const CGFloat height = self.frame.size.height;
    const CGFloat width = self.frame.size.width;
    const CGFloat ratioAnsweredQuestions = (CGFloat)self.numberCurrent / (CGFloat)self.numberTotal;
    const CGFloat widthAnsweredQuestionsPart = ratioAnsweredQuestions * width;
    const CGFloat ratioAnsweredQuestionsCorrect = (CGFloat)self.numberCurrentCorrectAnswers  / (CGFloat)self.numberCurrent;
    const CGFloat ratioAnsweredQuestionsIncorrect = (CGFloat)self.numberCurrentIncorrectAnswers / (CGFloat)self.numberCurrent;
    const CGFloat widthAnsweredQuestionsCorrectPart = ratioAnsweredQuestionsCorrect * widthAnsweredQuestionsPart;
    const CGFloat widthAnsweredQuestionsIncorrectPart = ratioAnsweredQuestionsIncorrect * widthAnsweredQuestionsPart;
    self->correctLayer.bounds = CGRectMake(0.0f, 0.0f, widthAnsweredQuestionsCorrectPart, height);
    
    self->incorrectLayer.position = CGPointMake(widthAnsweredQuestionsCorrectPart, 0.0f);
    self->incorrectLayer.bounds = CGRectMake(0.0f, 0.0f, widthAnsweredQuestionsIncorrectPart, height);
}

@end
