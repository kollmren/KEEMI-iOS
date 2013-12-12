//
//  LayAnswerViewCard.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 05.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerViewCard.h"
#import "LayAnswerButton.h"
#import "LayButton.h"
#import "LayFrame.h"
#import "LayVBoxLayout.h"
#import "LayStyleGuide.h"
#import "LayAnswerViewChoice.h"
#import "LayImageRibbon.h"
#import "LayAppNotifications.h"

#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"


static const NSUInteger TAG_WAS_RIGHT_BUTTON = 103;
static const NSInteger HEIGTH_EMPTY_RIBBON = 15.0f;
static const NSInteger HEIGTH_FILLED_RIBBON = 190.0f;
static const CGSize SIZE_EMPTY_RIBBON_ENTRY = {0.0, 0.0};

@interface LayAnswerViewCard() {
    Answer* answer;
    LayButton *showAnswerButton;
    LayButton *wasRightButton;
    UIView *answerContainer;
    LayAnswerViewChoice *choiceView;
    LayImageRibbon *imageRibbon;
    BOOL userSetAnswer;
    BOOL correctAnsweredByUser;
}

@end

//
// LayAnswerViewCard
//
@implementation LayAnswerViewCard

@synthesize answerViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self->answerContainer = nil;
        self->userSetAnswer = NO;
        self->correctAnsweredByUser = NO;
        self->imageRibbon = nil;
    }
    return self;
}

-(void)addShowAnswerButton {
    if(self->showAnswerButton) {
        [self->showAnswerButton removeFromSuperview];
        self->showAnswerButton = nil;
    }
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGSize buttonSize = CGSizeMake(self.frame.size.width, [styleGuide getDefaultButtonHeight]);
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGRect buttonFrame = CGRectMake(hSpace, 0.0f, buttonSize.width, buttonSize.height);
    NSString *text = NSLocalizedString(@"QuestionSessionCardShowAnswer", nil);
    self->showAnswerButton = [[LayButton alloc]initWithFrame:buttonFrame label:text font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
    [self->showAnswerButton fitToContent];
    [self->showAnswerButton addTarget:self action:@selector(showAnswer) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self->showAnswerButton];
}

-(void)addMarkAllYouKnowHintToView:(UIView*)view {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGSize buttonSize = CGSizeMake(self.frame.size.width, [styleGuide getDefaultButtonHeight]);
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGRect buttonFrame = CGRectMake(hSpace, 0.0f, buttonSize.width, buttonSize.height);
    NSString *wasRightLabel =NSLocalizedString(@"QuestionSessionCardUserWasRight", nil);
    self->wasRightButton = [[LayButton alloc]initWithFrame:buttonFrame label:wasRightLabel font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
    self->wasRightButton.enabled = NO;
    self->wasRightButton.tag = TAG_WAS_RIGHT_BUTTON;
    [self->wasRightButton fitToContent];
    [self->wasRightButton addTarget:self action:@selector(userWasRight) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self->wasRightButton];
}

-(void)showAnswerMedia:(Answer*)answer_ {
    if(self->imageRibbon) {
        [self->imageRibbon removeFromSuperview];
        self->imageRibbon = nil;
    }
    NSArray *answerMediaList = [answer_ mediaList];
    if(answerMediaList && [answerMediaList count]>0) {
        self->imageRibbon = [[LayImageRibbon alloc]initWithFrame:self.frame entrySize:SIZE_EMPTY_RIBBON_ENTRY andOrientation:HORIZONTAL];
        self->imageRibbon.pageMode = YES;
        self->imageRibbon.frame = CGRectMake(0.0, 0.0, self.frame.size.width, HEIGTH_FILLED_RIBBON);
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self->imageRibbon.entrySize = [styleGuide maxRibbonEntrySize];
        for (Media* answerMedia in answerMediaList) {
            LayMediaData *mediaData = [LayMediaData byMediaObject:answerMedia];
            [self->imageRibbon addEntry:mediaData withIdentifier:0];
        }
        if([self->imageRibbon numberOfEntries]>0) {
            [self->imageRibbon layoutRibbon];
        }
        [self->imageRibbon fitHeightOfRibbonToEntryContent];
        [self addSubview:self->imageRibbon];
    }
}


-(void)setupChoiceView {
    const CGSize viewSize = self.frame.size;
    CGSize sizeForChoiceView = CGSizeMake(viewSize.width, viewSize.height-vSpace);
    self->choiceView = [[LayAnswerViewChoice alloc]initAnswerView];
    self->choiceView.showMediaList = NO;
    [self->choiceView showMarkIndicator:YES];
    [self->choiceView showAnswer:self->answer andSize:sizeForChoiceView userCanSetAnswer:YES];
}

static const CGFloat vSpace = 5.0f;
-(void)showAnswer {
    if(!self->answerContainer) {
        const CGFloat width = self.frame.size.width;
        CGFloat yPosContainer = 0.0f;
        if(self->imageRibbon) {
            yPosContainer = self->imageRibbon.frame.size.height + self->imageRibbon.frame.origin.y + vSpace;
        }
        const CGRect answerConatinerInitFrame = CGRectMake(0.0f, yPosContainer, width, 0.0f);
        self->answerContainer = [[UIView alloc]initWithFrame:answerConatinerInitFrame];
        self->answerContainer.clipsToBounds = YES;
        [self addMarkAllYouKnowHintToView:self->answerContainer];
        [self->answerContainer addSubview:choiceView];
        [self addSubview:self->answerContainer];
    }
    
    [self showAnswerAnimated];
}

-(void)showAnswerAnimated {
    
    self->showAnswerButton.label = NSLocalizedString(@"QuestionSessionCardHideAnswer", nil);
    [self->showAnswerButton fitToContent];
    [self->showAnswerButton removeTarget:self action:@selector(showAnswer) forControlEvents:UIControlEventTouchUpInside];
    [self->showAnswerButton addTarget:self action:@selector(hideAnswer) forControlEvents:UIControlEventTouchUpInside];
    
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat yPosContainer = self->answerContainer.frame.origin.y;
    const CGFloat width = self.frame.size.width;
    const CGFloat newHeightContainer = [self layoutView:self->answerContainer withSpace:vSpace];
    const CGSize newViewSize = CGSizeMake(width, newHeightContainer + vSpace + self->showAnswerButton.frame.size.height + yPosContainer);
    [LayFrame setHeightWith:newViewSize.height toView:self animated:NO];
    if(self.answerViewDelegate) {
        [self.answerViewDelegate resizedToSize:newViewSize];
    }
    const CGFloat newYPosButton = yPosContainer + newHeightContainer + vSpace + self->showAnswerButton.frame.size.height/2.0f;
    const CGPoint newPosButton = CGPointMake(hSpace+(self->showAnswerButton.frame.size.width/2.0f), newYPosButton);
    
    CALayer *answerContainerLayer = self->answerContainer.layer;
    answerContainerLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
    answerContainerLayer.position = CGPointMake(0.0f, yPosContainer);
    CALayer *showAnswerButtonLayer = self->showAnswerButton.layer;
    [UIView animateWithDuration:0.3 animations:^{
        answerContainerLayer.bounds = CGRectMake(0.0f, 0.0f, width, newHeightContainer);
        showAnswerButtonLayer.position = newPosButton;
    } completion:^(BOOL finished) {
        
    }];

}

-(CGFloat)layoutView:(UIView*)view withSpace:(CGFloat)space {
    CGFloat currentOffsetY = 0.0f;
    for (UIView *subview in [view subviews]) {
        if(!subview.hidden) {
            CGRect subViewFrame = subview.frame;
            // y-Pos
            if(subview.tag == TAG_WAS_RIGHT_BUTTON) {
                currentOffsetY += 5.0f;
            }
            subViewFrame.origin.y = currentOffsetY;
            subview.frame = subViewFrame;
            currentOffsetY += subview.frame.size.height + space;
        }
    }
    return currentOffsetY;
}

-(void)hideAnswer {
    self->showAnswerButton.label = NSLocalizedString(@"QuestionSessionCardShowAnswer", nil);
    [self->showAnswerButton fitToContent];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat vSpace = 10.0f;
    CGFloat yPosContainer = 0.0f;
    if(self->imageRibbon) {
        yPosContainer = self->imageRibbon.frame.size.height + self->imageRibbon.frame.origin.y + vSpace;
    }
    CALayer *answerContainerLayer = self->answerContainer.layer;
    CALayer *showAnswerButtonLayer = self->showAnswerButton.layer;
    [UIView animateWithDuration:0.3 animations:^{
        answerContainerLayer.bounds = CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.0f);
        showAnswerButtonLayer.position = CGPointMake(hSpace+(self->showAnswerButton.frame.size.width/2.0f), yPosContainer + showAnswerButtonLayer.bounds.size.height/2.0f);
    } completion:^(BOOL finished) {
        [self->showAnswerButton removeTarget:self action:@selector(hideAnswer) forControlEvents:UIControlEventTouchUpInside];
        [self->showAnswerButton addTarget:self action:@selector(showAnswer) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    if(self.answerViewDelegate) {
        [self.answerViewDelegate scrollToTop];
    }
}

-(void) userWasRight {
    self->userSetAnswer = YES;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat vSpace = 15.0f;
    const CGFloat vSpaceContainerShowAnswerButton = 2*vSpace;
    const CGFloat newHeightContainer = self->answerContainer.frame.size.height - self->wasRightButton.frame.size.height - vSpace;
    const CGFloat width = self.frame.size.width;
    const CGSize newViewSize = CGSizeMake(width, self->answerContainer.frame.origin.y + newHeightContainer + vSpaceContainerShowAnswerButton + self->showAnswerButton.frame.size.height);
    [LayFrame setHeightWith:newViewSize.height toView:self animated:NO];
    if(self.answerViewDelegate) {
        [self.answerViewDelegate resizedToSize:newViewSize];
    }
    //[LayFrame setHeightWith:newHeightAnswerContainer toView:self->answerContainer animated:NO];
    const CGFloat newYPosButton = self->answerContainer.frame.origin.y + newHeightContainer + vSpaceContainerShowAnswerButton
    + self->showAnswerButton.frame.size.height/2.0f;
    [self->showAnswerButton removeTarget:self action:@selector(showAnswer) forControlEvents:UIControlEventTouchUpInside];
    [self->showAnswerButton addTarget:self action:@selector(hideAnswer) forControlEvents:UIControlEventTouchUpInside];
    const CGPoint newPosButton = CGPointMake(hSpace+(self->showAnswerButton.frame.size.width/2.0f), newYPosButton);
    
    CALayer *answerContainerLayer = self->answerContainer.layer;
    answerContainerLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
    CALayer *showAnswerButtonLayer = self->showAnswerButton.layer;
    [UIView animateWithDuration:0.3 animations:^{
        answerContainerLayer.bounds = CGRectMake(0.0f, 0.0f, width, newHeightContainer);
        showAnswerButtonLayer.position = newPosButton;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)resetView {
    [self->answerContainer removeFromSuperview];
    self->answerContainer = nil;
    self->userSetAnswer = NO;
    self->correctAnsweredByUser = NO;
    self->wasRightButton.hidden = NO;
}

//
// LayAnswerView
//
-(id<LayAnswerView>)initAnswerView {
     return [self initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
}

-(UIView*)answerView {
    return self;
}

-(CGSize)showAnswer:(Answer*)answer_ andSize:(CGSize)viewSize userCanSetAnswer:(BOOL)userCanSetAnswer {
    [self resetView];
    self->answer = answer_;
    self->userSetAnswer = NO;
    [LayFrame setSizeWith:viewSize toView:self];
    [self setupChoiceView];
    [self showAnswerMedia:answer_];
    [self addShowAnswerButton];
    const CGFloat vSpace = 10.0f;
    CGFloat neededHeight = [LayVBoxLayout layoutSubviewsOfView:self withSpace:vSpace];
    [LayFrame setHeightWith:neededHeight toView:self animated:NO];
    CGSize newSize = CGSizeMake(viewSize.width, neededHeight);
    
    return newSize;
}

-(void)showSolution {
    self->wasRightButton.hidden = YES;
    [self->choiceView showSolution];
    [self showAnswer];
}

-(BOOL)userSetAnswer {
    return [self->choiceView userSetAnswer];
}

-(BOOL)isUserAnswerCorrect {
    return [self->choiceView isUserAnswerCorrect];
}

-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate {
    self.answerViewDelegate = delegate;
}

@end
