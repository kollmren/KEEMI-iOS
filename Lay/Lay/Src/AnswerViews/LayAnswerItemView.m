//
//  LayAnswerItemView.m
//  Lay
//
//  Created by Rene Kollmorgen on 25.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerItemView.h"

#import "LayIconButton.h"
#import "LayImage.h"
#import "LayStyleGuide.h"
#import "LayAnswerButton.h"
#import "LayInfoIconView.h"
#import "LayVBoxLayout.h"
#import "LayFrame.h"
#import "LayInfoDialog.h"
#import "LayAnswerType.h"

#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Media+Utilities.h"
#import "Explanation+Utilities.h"

#import "MWLogging.h"

static const CGFloat DEFAULT_SPACE = 5.0f;
static const CGFloat INDENT_INFO_ICON = 15.0f;
static const CGFloat H_BUTTON_SPACE = 20.0f;
static const NSInteger TAG_MINIMIZE_BUITTON = 100;


//
// LayAnswerItemScrollView
//
@interface LayAnswerItemScrollView : UIScrollView

@end


//
// LayAnswerItemView
//
@interface LayAnswerItemView() {
    UILabel* title;
    LayAnswerItemScrollView *answerButtonList;
    LayInfoIconView *infoIconView;
    UIImageView *checkIcon;
    UIImageView *markIcon;
    UIImageView *wrongIcon;
    UIButton *minimizeButton;
    UIView* buttonContainer;
    //
    Answer *answer;
    NSArray* answerItems;
    NSUInteger indexOfCurrentAnswerItem;
    //
    UITapGestureRecognizer *singleTap;
    BOOL evaluated;
    //
    LayAnswerTypeIdentifier questionType;
}
@end

@implementation LayAnswerItemView

@synthesize space, itemViewDelegate, showMinimizeButton, withBackground;

-(id)initWithPosition:(CGPoint)position width:(CGFloat)width andAnswer:(Answer*)answer_ {
    CGRect frameRect = CGRectMake(position.x, position.y, width, 0.0f);
    self = [super initWithFrame:frameRect];
    if(self) {
        self.frame = frameRect;
        self->questionType = [answer_.questionRef questionType];
        self.itemViewSolutionDelegate = self;
        self->evaluated = NO;
        self.withBackground = YES;
        self.space = DEFAULT_SPACE;
        [self setupAnswerItemViewWithWidth:width];
        self.showMinimizeButton = NO;
        [self setAnswer:answer_];
    }
    return self;
}

-(AnswerItem*)currentVisibleAnswerItem {
    AnswerItem *answerItem = [self->answerItems objectAtIndex:self->indexOfCurrentAnswerItem];
    return answerItem;
}

-(void)dealloc {
    MWLogDebug([LayAnswerItemView class], @"dealloc");
}

-(void)setSpace:(CGFloat)space_ {
    space = space_;
    [self layoutVertically];
}

-(void)setWithBackground:(BOOL)withBackground_ {
    withBackground = withBackground_;
    if(withBackground) {
        [[LayStyleGuide instanceOf:nil] makeRoundedBorder:self withBackgroundColor:WhiteTransparentBackground];
    } else {
        [[LayStyleGuide instanceOf:nil] makeRoundedBorder:self withBackgroundColor:NoColor];
        self.backgroundColor = [UIColor clearColor];
    }
}

-(void)showSolution {
    self->evaluated = YES;
    [self orderAnswerItemListCorrectAnswersAtFirst];
    [self addAnswerButtons];
    [self bringSubviewToFront:self->minimizeButton];
}

-(void)showButtonWith:(AnswerItem*)answerItem {
    self->indexOfCurrentAnswerItem = 0;
    for (AnswerItem *currentAnswerItem in self->answerItems) {
        if(currentAnswerItem==answerItem) {
            break;
        } else {
            self->indexOfCurrentAnswerItem++;
        }
    }
    // TODO scroll to ...
    //[self showAnswerItem:answerItem];
}

-(void)setShowMinimizeButton:(BOOL)showMinimizeButton_ {
    showMinimizeButton = showMinimizeButton_;
    if(showMinimizeButton) {
        [self addMinimizeButton];
    } else {
        [self->minimizeButton removeFromSuperview];
    }
}

-(void) layoutVertically {
    // adjust the height
    CGFloat newHeight = [LayVBoxLayout layoutSubviewsOfView:self withSpace:self.space andBorder:0.0f ignore:TAG_MINIMIZE_BUITTON];
    CGSize newViewSize = CGSizeMake(self.frame.size.width, newHeight);
    [LayFrame setSizeWith:newViewSize toView:self];
    [self adjustPositionOfMinimizeButton];
    if(self.itemViewDelegate) {
        [self.itemViewDelegate resized];
    }
}


-(void)setAnswer:(Answer *)answer_ {
    answer = answer_;
    self->answerItems = [answer_ answerItemListSessionOrderPreserved];
    [self addAnswerButtons];
}

-(void)addMinimizeButton {
    // Setup buttons shown on the bottom
    self->minimizeButton = [LayIconButton buttonWithId:LAY_BUTTON_ZOOM_OUT];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    [styleGuide makeRoundedBorder:self->minimizeButton withBackgroundColor:WhiteTransparentBackground andBorderColor:ClearColor];
    self->minimizeButton.tag = TAG_MINIMIZE_BUITTON;
    [self->minimizeButton addTarget:self action:@selector(minimize) forControlEvents:UIControlEventTouchUpInside];
    [self adjustPositionOfMinimizeButton];
    [self addSubview:self->minimizeButton];
}

-(void)adjustPositionOfMinimizeButton {
    const CGFloat xPosMinimizeButton = self.frame.size.width - self->minimizeButton.frame.size.width - self.space;
    [LayFrame setXPos:xPosMinimizeButton toView:self->minimizeButton];
    [self->minimizeButton setHidden:NO];
    CGFloat yPos = self.frame.size.height - self->minimizeButton.frame.size.height - self.space;
    [LayFrame setYPos:yPos toView:self->minimizeButton];
}

-(void) setupAnswerItemViewWithWidth:(CGFloat)width {
    // Title
    self->title = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, width, 0.0f)];
    self->title.font = [[LayStyleGuide instanceOf:nil] getFont:TitlePreferredFont];
    self->title.textAlignment = NSTextAlignmentCenter;
    self->title.backgroundColor = [UIColor clearColor];
    [self addSubview:self->title];
    
    CGSize iconSize = [[LayStyleGuide instanceOf:nil] iconButtonSize];
    CGRect iconFrame = CGRectMake(0.0f, 0.0f, iconSize.width, iconSize.height);
    self->checkIcon = [[UIImageView alloc]initWithFrame:iconFrame];
    UIImage *icon = [LayImage imageWithId:LAY_IMAGE_DONE];
    self->checkIcon.contentMode = UIViewContentModeScaleAspectFit;
    self->checkIcon.image = icon;
    [self->checkIcon setHidden:YES];
    const CGFloat xPosCheckButton = width/2 - iconSize.width/2; // H-center checkButton
    [LayFrame setXPos:xPosCheckButton toView:self->checkIcon];
    //
    self->wrongIcon = [[UIImageView alloc]initWithFrame:iconFrame];
    self->wrongIcon.contentMode = UIViewContentModeScaleAspectFit;
    icon = [LayImage imageWithId:LAY_IMAGE_WRONG];
    self->wrongIcon.image = icon;
    [self->wrongIcon setHidden:YES];
    [LayFrame setXPos:xPosCheckButton toView:self->wrongIcon];
    //
    self->markIcon = [[UIImageView alloc]initWithFrame:iconFrame];
    self->markIcon.contentMode = UIViewContentModeScaleAspectFit;
    icon = [LayImage imageWithId:LAY_IMAGE_FLAG];
    self->markIcon.image = icon;
    [self->markIcon setHidden:YES];
    [LayFrame setXPos:xPosCheckButton toView:self->markIcon];
    
    self->infoIconView = [LayInfoIconView icon];
    [LayFrame setXPos:INDENT_INFO_ICON toView:self->infoIconView];
    [self->infoIconView setHidden:YES];
    
    self->buttonContainer = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, width, iconSize.height)];
    [self->buttonContainer addSubview:self->checkIcon];
    [self->buttonContainer addSubview:self->wrongIcon];
    [self->buttonContainer addSubview:self->markIcon];
    [self->buttonContainer addSubview:self->infoIconView];
    [self addSubview:self->buttonContainer];
}

-(void)arrangeIconsIfEvaluated:(BOOL)answerSetByUser answerHasExplanation:(BOOL)answerHasExplanation {
    const CGFloat width = self->buttonContainer.frame.size.width;
    const CGFloat height = self->buttonContainer.frame.size.height;
    CGSize iconSize = [[LayStyleGuide instanceOf:nil] iconButtonSize];
    if(answerSetByUser && !answerHasExplanation) {
        CGFloat xPosCheckButton = (width - 2 * iconSize.width - H_BUTTON_SPACE) / 2.0f;
        [LayFrame setXPos:xPosCheckButton toView:self->markIcon];
        xPosCheckButton += iconSize.width + H_BUTTON_SPACE;
        [LayFrame setXPos:xPosCheckButton toView:self->checkIcon];
        [LayFrame setXPos:xPosCheckButton toView:self->wrongIcon];
    } else if(answerSetByUser && answerHasExplanation) {
        CGFloat xPosCheckButton = (width - 3 * iconSize.width - 2 *H_BUTTON_SPACE) / 2.0f;
        [LayFrame setXPos:xPosCheckButton toView:self->infoIconView];
        xPosCheckButton += iconSize.width + H_BUTTON_SPACE;
        [LayFrame setXPos:xPosCheckButton toView:self->markIcon];
        xPosCheckButton += iconSize.width + H_BUTTON_SPACE;
        [LayFrame setXPos:xPosCheckButton toView:self->checkIcon];
        [LayFrame setXPos:xPosCheckButton toView:self->wrongIcon];
    } else if(answerHasExplanation) {
        CGFloat xPosCheckButton = (width - 2 * iconSize.width - H_BUTTON_SPACE) / 2.0f;
        [LayFrame setXPos:xPosCheckButton toView:self->infoIconView];
        xPosCheckButton += iconSize.width + H_BUTTON_SPACE;
        [LayFrame setXPos:xPosCheckButton toView:self->checkIcon];
        [LayFrame setXPos:xPosCheckButton toView:self->wrongIcon];
    } else {
        self->checkIcon.center = CGPointMake(width/2.0f, height/2.0f);
        self->wrongIcon.center = CGPointMake(width/2.0f, height/2.0f);
        self->markIcon.center = CGPointMake(width/2.0f, height/2.0f);
    }
}

-(void)addAnswerButtons {
    if(self->answerButtonList) {
        [self->answerButtonList removeFromSuperview];
        self->answerButtonList = nil;
        [self removeGestureRecognizer:self->singleTap];
    }
    self->indexOfCurrentAnswerItem = 0;
    CGFloat height = [[LayStyleGuide instanceOf:nil] maxHeightOfAnswerButton];
    const CGRect buttonFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, height);
    const NSUInteger numberOfPages = [self->answerItems count];
    self->answerButtonList = [[LayAnswerItemScrollView alloc]initWithFrame:buttonFrame];
    self->answerButtonList.backgroundColor = [UIColor clearColor];
    // a page is the width of the scroll view
    self->answerButtonList.pagingEnabled = YES;
    self->answerButtonList.contentSize = CGSizeMake(self.frame.size.width * numberOfPages, height);
    self->answerButtonList.showsHorizontalScrollIndicator = NO;
    self->answerButtonList.showsVerticalScrollIndicator = NO;
    self->answerButtonList.scrollsToTop = NO;
    self->answerButtonList.delegate = self;
    [self insertSubview:self->answerButtonList aboveSubview:self->title];
    NSUInteger page = 0;
    CGFloat heighestButton = 0.0f;
    for (AnswerItem *answerItem in self->answerItems) {
        CGRect frame = buttonFrame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        LayAnswerButton* answerButton = [self addButtonForAnswerItem:answerItem withFrame:frame];
        if(answerButton.frame.size.height > heighestButton) {
            heighestButton = answerButton.frame.size.height;
        }
        if(0==page) {
            // Show state indicators for the first visible button
            [self showStateIndicatorsForButton:answerButton];
        }
        page++;
    }
    self->answerButtonList.contentSize = CGSizeMake(self->answerButtonList.contentSize.width, heighestButton);
    [LayFrame setHeightWith:heighestButton toView:self->answerButtonList animated:NO];
    [self updateTitle];
    [self layoutVertically];
    // Overlay the scroll that the use can scroll the whole view.
    const CGFloat overlayHeight = self->buttonContainer.frame.size.height + 10.0f;
    [LayFrame setHeightWith:heighestButton + overlayHeight toView:self->answerButtonList animated:NO];
    [self bringSubviewToFront:self->answerButtonList];
    
    self->singleTap = [[UITapGestureRecognizer alloc]
                       initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:self->singleTap];
}

-(LayAnswerButton*)addButtonForAnswerItem:(AnswerItem*)answerItem withFrame:(CGRect)frame {
    LayAnswerButton *answerButton = [[LayAnswerButton alloc]initWithFrame:frame and:answerItem];
    answerButton.answerButtonDelegate = self;
    answerButton.showBorder = NO;
    answerButton.showInfoIconIfEvaluated = NO;
    answerButton.showCorrectnessIconIfEvaluated = NO;
    answerButton.showMarkIndicator = NO;
    answerButton.showIfHighlighted = NO;
    [self->answerButtonList addSubview:answerButton];
    // TODO:
    /*if(self.itemViewDelegate) {
        [self.itemViewDelegate swipedTo:answerButton];
    }*/
    
    return answerButton;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    LayAnswerButton *answerButton = [[self->answerButtonList subviews]objectAtIndex:self->indexOfCurrentAnswerItem];
    [answerButton doTap];
}

-(void)showStateIndicatorsForButton:(LayAnswerButton*)answerButton {
    [self showMarkIndicators:[answerButton.answerItem.setByUser boolValue]];
    if(self->evaluated) {
        AnswerItem* answerItem = answerButton.answerItem;
        BOOL answerHasExplanation = [answerItem hasExplanation];
        [self arrangeIconsIfEvaluated:[answerButton.answerItem.setByUser boolValue] answerHasExplanation:answerHasExplanation];
        [self showCorrectIndicators:answerButton];
    }
}

-(void)updateTitle {
    const NSUInteger numberOfAvailableItems = [self->answerItems count];
    NSString *titleText = [NSString stringWithFormat:@"%u / %u",self->indexOfCurrentAnswerItem + 1,numberOfAvailableItems];
    self->title.text = titleText;
    [self->title sizeToFit];
    [LayFrame setWidthWith:self.frame.size.width toView:self->title];
}

-(void)showCorrectIndicators:(LayAnswerButton*)answerButton_ {
    [self->checkIcon setHidden:YES];
    [self->wrongIcon setHidden:YES];
    [answerButton_ showCorrectness];
    AnswerItem* answerItem = answerButton_.answerItem;
    if([answerItem hasExplanation]) {
        [self->infoIconView setHidden:NO];
    } else {
        [self->infoIconView setHidden:YES];
    }
    if([answerItem.setByUser boolValue] && [self answerItemCorrect:answerItem]) {
        self.layer.borderWidth = [[LayStyleGuide instanceOf:nil] getBorderWidth:SelectedButtonBorder];
        self.layer.borderColor = [[LayStyleGuide instanceOf:nil] getColor:AnswerCorrect].CGColor;
        [self->checkIcon setHidden:NO];
    } else if([answerItem.setByUser boolValue] && ![self answerItemCorrect:answerItem]) {
        self.layer.borderWidth = [[LayStyleGuide instanceOf:nil] getBorderWidth:SelectedButtonBorder];
        self.layer.borderColor = [[LayStyleGuide instanceOf:nil] getColor:AnswerWrong].CGColor;
        [self->wrongIcon setHidden:NO];
    } else if([self answerItemCorrect:answerItem]) {
        [self->checkIcon setHidden:NO];
        self.layer.borderWidth = [[LayStyleGuide instanceOf:nil] getBorderWidth:SelectedButtonBorder];
        self.layer.borderColor = [[LayStyleGuide instanceOf:nil] getColor:AnswerCorrect].CGColor;
    } else {
        self.layer.borderWidth = [[LayStyleGuide instanceOf:nil] getBorderWidth:NormalBorder];
        self.layer.borderColor = [[LayStyleGuide instanceOf:nil]getColor:ButtonBorderColor].CGColor;
    }
}

-(void) orderAnswerItemListCorrectAnswersAtFirst {
    NSMutableArray *newAnswerItemOrder = [NSMutableArray arrayWithCapacity:[self->answerItems count]];
    for (AnswerItem* answerItem in self->answerItems) {
        if([self answerItemCorrect:answerItem] && [answerItem.setByUser boolValue]) {
            [newAnswerItemOrder addObject:answerItem];
        }
    }
    for (AnswerItem* answerItem in self->answerItems) {
        if([self answerItemCorrect:answerItem] && ![answerItem.setByUser boolValue]) {
            [newAnswerItemOrder addObject:answerItem];
        }
    }
    
    for (AnswerItem* answerItem in self->answerItems) {
        if(![self answerItemCorrect:answerItem]&& [answerItem.setByUser boolValue]) {
            [newAnswerItemOrder addObject:answerItem];
        }
    }
    
    for (AnswerItem* answerItem in self->answerItems) {
        BOOL addAnswerItem = YES;
        for(AnswerItem* orderedAnswerItem in newAnswerItemOrder ) {
            if(answerItem == orderedAnswerItem) {
                addAnswerItem = NO;
                break;
            }
        }
        if(addAnswerItem) {
            [newAnswerItemOrder addObject:answerItem];
        }
    }
    self->answerItems = newAnswerItemOrder;
}

-(BOOL)answerItemCorrect:(AnswerItem*)answerItem {
    BOOL isCorrect = NO;
    if(self.itemViewSolutionDelegate) {
        isCorrect = [self.itemViewSolutionDelegate isAnswerItemCorrect:answerItem];
    }
    return isCorrect;
}

-(void) handleUserInfoChoice:(LayAnswerButton*)answerButton_ {
    AnswerItem *answerItem = answerButton_.answerItem;
    if([answerItem hasExplanation]) {
        Explanation *explanation = [answerItem explanation];
        [self showExplanation:explanation];
    }
}

-(void) showAddtionalInfoToAnswer {
    if([self->answer hasExplanation]) {
        Explanation *explanation = [self->answer explanation];
        [self showExplanation:explanation];
    }
}

-(void)showExplanation:(Explanation*)explanation {
    LayInfoDialog *infoDlg = [[LayInfoDialog alloc]initWithWindow:self.window];
    [infoDlg showShortExplanation:explanation];
}

-(void) handleUserTap:(LayAnswerButton*)answerButton_ :(BOOL)wasSelected {
    AnswerItem *answerItem = answerButton_.answerItem;
    if(wasSelected) {
        answerItem.setByUser = [NSNumber numberWithBool:NO];
        [self showMarkIndicators:NO];
    } else {
        answerItem.setByUser = [NSNumber numberWithBool:YES];
        [self showMarkIndicators:YES];

    }
}

-(void)showMarkIndicators:(BOOL)show {
    if(show) {
        [self->markIcon setHidden:NO];
        self.layer.borderWidth = [[LayStyleGuide instanceOf:nil] getBorderWidth:SelectedButtonBorder];
        self.layer.borderColor = [[LayStyleGuide instanceOf:nil] getColor:ButtonSelectedColor].CGColor;
    } else {
        [self->markIcon setHidden:YES];
        self.layer.borderWidth = [[LayStyleGuide instanceOf:nil] getBorderWidth:NormalBorder];
        self.layer.borderColor = [[LayStyleGuide instanceOf:nil] getColor:ButtonBorderColor].CGColor;
    }
}

// Button handler
-(void) minimize {
    if(self.itemViewDelegate) {
        [self.itemViewDelegate minimizedButtonTapped];
    }
}

//
// LayAnswerButtonDelegate
//
-(void)tapped:(LayAnswerButton*)answerButton_ wasSelected:(BOOL)wasSelected {
    
    if(!self->evaluated && self->questionType == ANSWER_TYPE_SINGLE_CHOICE_LARGE_MEDIA) {
        for(LayAnswerButton *answerButton in [self->answerButtonList subviews]) {
            if(answerButton_ != answerButton ) {
                [answerButton unmark];
            }
        }
    }
    
    if(self->evaluated) {
        [self handleUserInfoChoice:answerButton_];
    } else {
        [self handleUserTap:answerButton_ :wasSelected];
    }
    
    if(self.itemViewDelegate) {
        [self.itemViewDelegate tapped:answerButton_ wasSelected:wasSelected];
    }
}

-(void) resized {
    
}

//
// LayAnswerItemViewSolutionDelegate
//
-(BOOL) isAnswerItemCorrect:(AnswerItem *)answerItem {
    return [answerItem.correct boolValue];
}


//
// UIScrollViewDelegate
//
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self->answerButtonList.frame.size.width;
    self->indexOfCurrentAnswerItem = floor((self->answerButtonList.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self updateTitle];
    NSArray *answerButtonViewList = [self->answerButtonList subviews];
    if(self->indexOfCurrentAnswerItem  < [answerButtonViewList count]) {
        LayAnswerButton* answerButton = (LayAnswerButton*)[answerButtonViewList objectAtIndex:self->indexOfCurrentAnswerItem];
        if(answerButton) {
            [self showStateIndicatorsForButton:answerButton];
        }
    }
}

@end


//
// LayAnswerItemScrollView
//
@implementation LayAnswerItemScrollView

/*-(BOOL)touchesShouldBegin:(NSSet*)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    if([view isKindOfClass:[LayAnswerButton class]]) {
        LayAnswerButton *answerButton = (LayAnswerButton*)view;
        [answerButton mark];
    } else {
        MWLogError([LayAnswerItemScrollView class], @"There are subviews of an unknown type!");
    }
    return NO;
}*/

@end


