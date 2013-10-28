//
//  LayTests.m
//  LayTests
//
//  Created by Rene on 29.10.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayAnswerViewManagerImplTests.h"
#import "LayAnswerViewManagerImpl.h"
#import "LayAnswerView.h"
#import "LayAnswerType.h"

#import "MWLogging.h"


@interface AnswerView1 : UIView<LayAnswerView>
@end

@interface AnswerView2 : UIView<LayAnswerView>
@end

@interface AnswerView3 : UIView
@end

@interface AnswerView4 : NSObject<LayAnswerView>
@end



@implementation LayAnswerViewManagerImplTests

static Class _classObj = nil;

+(void)setUp {
    _classObj = [LayAnswerViewManagerImplTests class];
}

+(void)tearDown {
    
}

-(void)testRegisterAnswerViewWithCorrectClasses {
    MWLogNameOfTest(_classObj);
    BOOL registered = [LayAnswerViewManagerImpl registerAnswerView:[AnswerView1 class] forTypeOfAnswer:ANSWER_TYPE_MULTIPLE_CHOICE];
    STAssertTrue(registered, nil);
    registered = [LayAnswerViewManagerImpl registerAnswerView:[AnswerView2 class] forTypeOfAnswer:ANSWER_TYPE_ASSIGN];
    STAssertTrue(registered, nil);
    registered = [LayAnswerViewManagerImpl registerAnswerView:[AnswerView1 class] forTypeOfAnswer:ANSWER_TYPE_MULTIPLE_CHOICE];
    STAssertTrue(registered, nil);
}

-(void)testRegisterAnswerViewWithIncorrectClasses {
    MWLogNameOfTest(_classObj);
    BOOL registered = [LayAnswerViewManagerImpl registerAnswerView:[AnswerView3 class] forTypeOfAnswer:ANSWER_TYPE_MULTIPLE_CHOICE];
    STAssertFalse(registered, nil);
    registered = [LayAnswerViewManagerImpl registerAnswerView:[AnswerView4 class] forTypeOfAnswer:ANSWER_TYPE_ASSIGN];
    STAssertFalse(registered, nil);
}

@end

//
// Testdata
//
@implementation AnswerView1

-(id<LayAnswerView>)initAnswerView {
    return nil;
}

-(UIView*)answerView {
    return nil;
}

-(CGSize)showAnswer:(Answer*)answer andSize:(CGSize)viewSize userCanSetAnswer:(BOOL)userCanSetAnswer {
    return CGSizeMake(0.0, 0.0);
}

-(void)showSolution {
    
}

-(BOOL)userSetAnswer {
    return YES;
}

-(BOOL)isUserAnswerCorrect {
    return YES;
}

-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate {
    
}

@end

//
//
@implementation AnswerView2

-(id<LayAnswerView>)initAnswerView {
    return nil;
}

-(UIView*)answerView {
    return nil;
}

-(CGSize)showAnswer:(Answer*)answer andSize:(CGSize)viewSize userCanSetAnswer:(BOOL)userCanSetAnswer {
    return CGSizeMake(0.0, 0.0);
}

-(void)showSolution {
    
}

-(BOOL)userSetAnswer {
    return YES;
}

-(BOOL)isUserAnswerCorrect {
    return YES;
}

-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate {
    
}

@end

//
//
@implementation AnswerView3 : UIView

-(id<LayAnswerView>)initAnswerView {
    return nil;
}

-(UIView*)answerView {
    return nil;
}

-(CGSize)showAnswer:(Answer*)answer andSize:(CGSize)viewSize userCanSetAnswer:(BOOL)userCanSetAnswer {
    return CGSizeMake(0.0, 0.0);
}


@end

//
//
@implementation AnswerView4 


@end
