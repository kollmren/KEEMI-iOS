//
//  LayAnswerItemView.m
//  Lay
//
//  Created by Rene Kollmorgen on 25.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerItemViewMinimized.h"
#import "LayAnswerItemView.h"
#import "LayIconButton.h"
#import "LayImage.h"
#import "LayStyleGuide.h"
#import "LayVBoxLayout.h"
#import "LayFrame.h"

#import "Answer+Utilities.h"

#import "MWLogging.h"

static const CGFloat DEFAULT_SPACE = 5.0f;
//
// LayAnswerItemView
//
@interface LayAnswerItemViewMinimized() {
    CGPoint minimizedPos;
    UIButton *answerChoicesButton;
    LayAnswerItemView *answerItemView;
    UIView *minimizeArea;
}
@end

@implementation LayAnswerItemViewMinimized


-(id)initWithMinimizedPosition:(CGPoint)minimizedPos_ width:(CGFloat)width andAnswer:(Answer*)answer_ {
    self = [super initWithFrame:CGRectMake(minimizedPos_.x, minimizedPos_.y, 0.0f, 0.0f)];
    if(self) {
        self->minimizedPos = minimizedPos_;
        CGPoint answerItemViewPosition = CGPointMake(0.0f, 0.0f);
        self->answerItemView = [[LayAnswerItemView alloc]initWithPosition:answerItemViewPosition width:width andAnswer:answer_];
        self->answerItemView.showMinimizeButton = YES;
        self->answerItemView.itemViewDelegate = self;
        [self addSubview:self->answerItemView];
        [self setupMinimizeArea];
        [self maximize];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayAnswerItemViewMinimized class], @"dealloc");
}


-(void)showSolution {
    [self maximize];
    [self->answerItemView showSolution];
}

-(void) setupMinimizeArea {
    minimizeArea = [[UIView alloc] init];
    minimizeArea.alpha = 0.7f;
    self->answerChoicesButton = [LayIconButton buttonWithId:LAY_BUTTON_LIST];
    [self->answerChoicesButton addTarget:self action:@selector(maximize) forControlEvents:UIControlEventTouchUpInside];
    [[LayStyleGuide instanceOf:nil] makeRoundedBorder:self->answerChoicesButton withBackgroundColor:WhiteTransparentBackground];
    [LayFrame setSizeWith:self->answerChoicesButton.frame.size toView:minimizeArea];
    [minimizeArea addSubview:self->answerChoicesButton];
    [self addSubview:minimizeArea];
}

// Button - Action - Handlers
-(void) maximize {
    // adjust the height
    [self adjustPositionOfView];
    [self->minimizeArea setHidden:YES];
    [self->answerItemView setHidden:NO];
}

-(void) minimize {
    [LayFrame setYPos:self->minimizedPos.y toView:self];
    [LayFrame setSizeWith:self->minimizeArea.frame.size toView:self];
    [self->minimizeArea setHidden:NO];
    [self->answerItemView setHidden:YES];
}

-(void) adjustPositionOfView {
    CGFloat newHeight = self->answerItemView.frame.size.height;
    CGFloat newYPos = (self->minimizedPos.y + self->minimizeArea.frame.size.height) - newHeight;
    CGSize newViewSize = CGSizeMake(self->answerItemView.frame.size.width, newHeight);
    // adjust the frame of the view
    [LayFrame setSizeWith:newViewSize toView:self];
    [LayFrame setYPos:newYPos toView:self];
}

//
// LayAnswerItemViewDelegate
//
-(void)minimizedButtonTapped {
    [self minimize];
}
// Is called when the button changed its size e.g. when the info-icon is shown.
-(void) resized {
    [self adjustPositionOfView];
}

-(void)tapped:(LayAnswerButton*)answerButtonn wasSelected:(BOOL)wasSelected {
    
}

-(void) swipedTo:(LayAnswerButton*)currentAnswerButton {
    
}

@end;

