//
//  LayQuestionMapView.m
//  Lay
//
//  Created by Rene Kollmorgen on 07.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayQuestionBubbleView.h"
#import "LayIconButton.h"
#import "LayButton.h"
#import "LayFrame.h"
#import "LayInfoDialog.h"

#import "LayMinimizeAnimator.h"
#import "Question+Utilities.h"

#import "LayStyleGuide.h"

static const NSInteger g_numberOfLines = 5;
static const CGFloat g_fontSizeOfQuestionText = 18.0f;
static const CGFloat g_verticalBorder = 6.0f;
static const CGFloat g_horizontalBorder = 8.0f;

@interface LayQuestionBubbleView() {
    UIScrollView* questionArea;
    UILabel* questionLabel;
    UIButton* minimizeButton;
    
    UIView* minimizeArea;
    UIButton* maximizeButton;
    
    CGFloat maxHeight;
    CGRect initFrame;
    CGRect initialQuestionLabelRect;
}
@end

@implementation LayQuestionBubbleView


@synthesize question;

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self->maxHeight = [UIScreen mainScreen].bounds.size.height * 0.50f;
        initFrame = frame;
        [self setupQuestionArea];
        [self setupMinimizeArea];
    }
    return self;
}

-(void) setupQuestionArea {
    questionArea = [[UIScrollView alloc] initWithFrame:initFrame];
    questionArea.clipsToBounds = TRUE;
    [self addSubview:questionArea];
    
    CGFloat labelHeight = self.frame.size.height - 2 * g_verticalBorder;
    CGFloat labelWidth = self.frame.size.width - 2 * g_horizontalBorder;
    self->initialQuestionLabelRect = CGRectMake(g_horizontalBorder, g_verticalBorder, labelWidth, labelHeight);
    questionLabel = [[UILabel alloc]initWithFrame:self->initialQuestionLabelRect];
    questionLabel.backgroundColor = [UIColor clearColor];
    questionLabel.textAlignment = NSTextAlignmentLeft;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    questionLabel.font = [styleGuide getFont:QuestionFont];
    questionLabel.numberOfLines = [styleGuide numberOfLines];
    questionLabel.textColor = [styleGuide getColor:TextColor];
    [questionArea addSubview:questionLabel];
    
    minimizeButton = [LayIconButton buttonWithId:LAY_BUTTON_ZOOM_OUT];
    [questionArea addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(minimizeQuestion)]];
    [minimizeButton addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(minimizeQuestion)]];
    [self addSubview:minimizeButton];
    
    [[LayStyleGuide instanceOf:nil] makeRoundedBorder:questionArea withBackgroundColor:WhiteTransparentBackground];
}

-(void) setupMinimizeArea {
    minimizeArea = [[UIView alloc] init];
    minimizeArea.alpha = 0.7f;
    [self addSubview:minimizeArea];
    
    maximizeButton = [LayIconButton buttonWithId:LAY_BUTTON_QUESTION];
    [minimizeArea addSubview:maximizeButton];
    [maximizeButton addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(maximizeQuestion)]];
    minimizeArea.backgroundColor = [[LayStyleGuide instanceOf:nil] getColor:ClearColor];
    [[LayStyleGuide instanceOf:nil] makeRoundedBorder:minimizeArea withBackgroundColor:WhiteTransparentBackground];
}

static const NSUInteger TAG_QUESTION_TITLE = 1004;
static const NSUInteger TAG_QUESTION_INTRO = 1005;
-(CGFloat)addQuestonTitleAndIntro:(Question*)question_ {
    UIView *view = [self viewWithTag:TAG_QUESTION_TITLE];
    if(view) {
        [view removeFromSuperview];
        view = nil;
    }
    
    view = [self viewWithTag:TAG_QUESTION_INTRO];
    if(view) {
        [view removeFromSuperview];
        view = nil;
    }
    
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    CGFloat bottomPositionOfTitle = 0.0f;
    if(question_.title) {
        UIFont *smallFont = [styleGuide getFont:TitlePreferredFont];
        UIColor *textColor = [styleGuide getColor:TextColor];
        const CGFloat indent = 10.0f;
        const CGFloat titleContainerWidth = self->questionArea.frame.size.width - 2 * g_horizontalBorder;
        const CGRect titleContainerFrame = CGRectMake(g_horizontalBorder, g_horizontalBorder, titleContainerWidth, 0.0f);
        UIView *titleContainer = [[UIView alloc]initWithFrame:titleContainerFrame];
        titleContainer.tag = TAG_QUESTION_TITLE;
        //
        const CGFloat titleWith = titleContainerWidth - 2 * g_horizontalBorder - 2 * indent;
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(indent, indent, titleWith, 0.0f)];
        title.textColor = textColor;
        title.backgroundColor = [UIColor clearColor];
        title.font = smallFont;
        title.text = [NSString stringWithFormat:@"%@", question.title];
        title.numberOfLines = [styleGuide numberOfLines];
        [title sizeToFit];
        const CGFloat heightTitleContainer = title.frame.size.height + 2 * indent;
        [LayFrame setHeightWith:heightTitleContainer toView:titleContainer animated:NO];
        [titleContainer addSubview:title];
        //
        [styleGuide makeRoundedBorder:titleContainer withBackgroundColor:GrayTransparentBackground andBorderColor:ClearColor];
        bottomPositionOfTitle = heightTitleContainer + titleContainer.frame.origin.y + g_verticalBorder;
        [questionArea insertSubview:titleContainer belowSubview:self->questionLabel];
    }
    
    Introduction *intro = question_.introRef;
    if(intro) {
        const CGFloat introWidth = self.frame.size.width;
        const CGRect introFrame = CGRectMake(0.0f, 0.0f, introWidth, 0.0f);
        UIFont *introFont = [styleGuide getFont:NormalPreferredFont];
        UIColor *clearColor = [styleGuide getColor:ClearColor];
        NSString *introText = NSLocalizedString(@"QuestionIntroTitle", nil);
        LayButton *introButton = [[LayButton alloc]initWithFrame:introFrame label:introText font:introFont andColor:clearColor];
        introButton.tag = TAG_QUESTION_INTRO;
        [introButton fitToContent];
        [introButton addTarget:self action:@selector(showIntroduction) forControlEvents:UIControlEventTouchUpInside];
        [LayFrame setYPos:bottomPositionOfTitle toView:introButton];
        [questionArea insertSubview:introButton belowSubview:self->questionLabel];
        bottomPositionOfTitle += introButton.frame.size.height + g_verticalBorder;
    }
    
    return bottomPositionOfTitle;
}

-(void)showIntroduction {
    Introduction *intro = self.question.introRef;
    if(intro) {
        LayInfoDialog *infoDialog = [[LayInfoDialog alloc]initWithWindow:self.window];
        [infoDialog showIntroduction:intro];
    }
}

-(void) maximizeQuestion {
    [LayFrame setSizeWith:questionArea.frame.size toView:self];
    questionArea.hidden = NO;
    minimizeButton.hidden = NO;
    minimizeArea.hidden = YES;
}

-(void) minimizeQuestion {
    [LayFrame setSizeWith:minimizeArea.frame.size toView:self];
    questionArea.hidden = YES;
    minimizeButton.hidden = YES;
    minimizeArea.hidden = NO;
}

-(void) setQuestion:(Question *)question_ {
    question = question_;
    [self->questionArea scrollRectToVisible:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f) animated:NO];
    
    self->questionLabel.frame = self->initialQuestionLabelRect;
    CGFloat bottomPositionOfTitle = [self addQuestonTitleAndIntro:question_];
    CGFloat yPosQuestion = g_verticalBorder;
    if( bottomPositionOfTitle > 0.0f ) {
        yPosQuestion = bottomPositionOfTitle +  g_verticalBorder;
    }
    [LayFrame setYPos:yPosQuestion toView:self->questionLabel];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    questionLabel.font = [styleGuide getFont:QuestionFont];
    questionLabel.text = self.question.question;
    questionLabel.textColor = [UIColor darkGrayColor];
    [questionLabel sizeToFit];
    CGFloat labelWithBorderHeight = self->questionLabel.frame.size.height + 2 * g_verticalBorder;
    
    CGRect frame = initFrame;
    self.frame = frame;
    frame.origin = CGPointMake(0,0);
    questionArea.frame = frame;
    CGFloat newViewHeight = bottomPositionOfTitle + labelWithBorderHeight + self->minimizeButton.frame.size.height + g_verticalBorder;
    if(newViewHeight > self->maxHeight) {
        questionArea.contentSize = CGSizeMake(questionArea.frame.size.width, newViewHeight);
        [LayFrame setHeightWith:self->maxHeight toView:questionArea animated:NO];
        [LayFrame setHeightWith:self->maxHeight toView:self animated:NO];
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        [styleGuide makeRoundedBorder:self->minimizeButton withBackgroundColor:WhiteTransparentBackground andBorderColor:ClearColor];
    } else {
        questionArea.contentSize = CGSizeMake(questionArea.frame.size.width, newViewHeight);
        [LayFrame setHeightWith:newViewHeight toView:questionArea animated:NO];
        [LayFrame setHeightWith:newViewHeight toView:self animated:NO];
        self->minimizeButton.backgroundColor = [UIColor clearColor];
    }
    
    CGRect frameMinimizeButton = self->minimizeButton.frame;
    frameMinimizeButton.origin = CGPointMake(initFrame.size.width - g_horizontalBorder - frameMinimizeButton.size.width, self.frame.size.height - frameMinimizeButton.size.height - g_verticalBorder);
    self->minimizeButton.frame = frameMinimizeButton;
    
    minimizeArea.frame = maximizeButton.frame;
    [self maximizeQuestion];
}

@end
