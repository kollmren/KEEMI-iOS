//
//  LayAnswerViewMultipleChoice.m
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerViewChoice.h"
#import "LayVBoxLayout.h"
#import "LayAnswerButton.h"
#import "LayButton.h"
#import "LayImageRibbon.h"
#import "LayAnswerViewDelegate.h"
#import "LayInfoDialog.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayImage.h"

#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Explanation+Utilities.h"
#import "Media+Utilities.h"
#import "AnswerMedia.h"

#import "MWLogging.h"

@interface LayAnswerViewChoice() {
    Answer* answer;
    LayImageRibbon *imageRibbon;
    BOOL userSetAnswer;
    BOOL evaluated;
    __weak id<LayAnswerViewDelegate> answerViewDelegate;
}
@end

@implementation LayAnswerViewChoice

@synthesize mode, showMarkIndicatorInButtons, showMediaList, showAnswerItemsOrdered;

static const CGFloat VERTICAL_SPACE = 0.0f;
static const CGFloat BORDER_MEDIA_BUTTON = 10.0f;
static const NSInteger NUMBER_MEDIA_BUTTONS_IN_ROW = 2;
static const NSInteger HEIGTH_FILLED_RIBBON = 190.0f;
static const NSInteger TAG_IMAGE_RIBBON = 1001;
static const NSInteger TAG_FOR_EXPLANATION_BUTTON = 2001;
static const NSInteger TAG_LEFT_COLUMN_BUTTON_CONTAINER = 100;
static const NSInteger TAG_RIGHT_COLUMN_BUTTON_CONTAINER = 140;

-(id)initWithFrame:(CGRect)frame {
    CGRect frame_ = frame;
    self = [super initWithFrame:frame_];
    if (self) {
        self->evaluated = NO;
        self.showMediaList = YES;
        self.showAnswerItemsOrdered = NO;
        self.showMarkIndicatorInButtons = YES;
        self.mode = LAY_ANSWER_VIEW_MULTIPLE_CHOICE;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGSize ribbonEntrySize = [styleGuide maxRibbonEntrySize];
        self->imageRibbon = [[LayImageRibbon alloc]initWithFrame:frame entrySize:ribbonEntrySize andOrientation:HORIZONTAL];
        self->imageRibbon.tag = TAG_IMAGE_RIBBON;
        self->imageRibbon.pageMode = YES;
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayAnswerViewChoice class], @"dealloc");
}

-(CGFloat)bottomOfMediaListView {
    CGFloat bottomImageRibbon = self->imageRibbon.frame.size.height + self.frame.origin.y;
    return bottomImageRibbon;
}

-(void)resetView {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    self->answer = nil;
    self->evaluated = NO;
    [self->imageRibbon removeAllEntries];
}

-(void)addButtonsForAnswer:(Answer*)answer_ {
    LayAnswerStyleType answerStyle = [answer styleType];
    if(answerStyle == StyleColumn) {
        [self addButtonsForAnswerItemsColumnSytle:answer_];
    } else {
        [self addButtonsForAnswerItemsRowStyle:answer_];
    }
}

-(NSArray*)answerItemListFromAnswer:(Answer*)answer_ {
    NSArray *answerItemList = [answer_ answerItemListSessionOrderPreserved];
    return answerItemList;
}

-(void)addButtonsForAnswerItemsRowStyle:(Answer*)answer_ {
    NSArray *answerItemList = [self answerItemListFromAnswer:answer_];
    for (AnswerItem* answerItem in answerItemList) {
        LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
        const CGFloat hSpace = 0.0f;//[style getHorizontalScreenSpace];
        CGFloat widthOfButton = self.frame.size.width - 2 * hSpace;
        // button gets whole row
        const CGRect buttonRect = CGRectMake(hSpace, 0.0f, widthOfButton, [style maxHeightOfAnswerButton]);
        LayAnswerButton *answerButton = [[LayAnswerButton alloc]initWithFrame:buttonRect and:answerItem];
        if(!self.showMarkIndicatorInButtons ) {
            answerButton.showMarkIndicator = NO;
            answerButton.showCorrectnessIconIfEvaluated = NO;
        }
        answerButton.answerButtonDelegate = self;
        [self addSubview:answerButton];
        if([answerItem.setByUser boolValue]) [answerButton mark];
    }
}

-(void)addButtonsForAnswerItemsColumnSytle:(Answer*)answer_ {
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = 0.0f;//[style getHorizontalScreenSpace];
    CGFloat widthOfButton = self.frame.size.width - 2 * hSpace;
    // button gets one column
    widthOfButton = (widthOfButton / 2) - hSpace;
    const CGRect buttonRect = CGRectMake(0.0f, 0.0f, widthOfButton, [style maxHeightOfAnswerButton]);
    // column button containers
    CGRect containerFrameLeft = CGRectMake(hSpace, 0.0f, widthOfButton, 0.0f);
    UIView* buttonContainerLeftColumn = [[UIView alloc]initWithFrame:containerFrameLeft];
    buttonContainerLeftColumn.tag = TAG_LEFT_COLUMN_BUTTON_CONTAINER;
    CGRect containerFrameRight = CGRectMake(widthOfButton+3*hSpace, 0.0f, widthOfButton, 0.0f);
    UIView* buttonContainerRightColumn = [[UIView alloc]initWithFrame:containerFrameRight];
    buttonContainerRightColumn.tag = TAG_RIGHT_COLUMN_BUTTON_CONTAINER;
    BOOL leftRight = YES;
    NSArray *answerItemList = [self answerItemListFromAnswer:answer_];
    for (AnswerItem* answerItem in answerItemList) {
        LayAnswerButton *answerButton = [[LayAnswerButton alloc]initWithFrame:buttonRect and:answerItem];
        if(!self.showMarkIndicatorInButtons ) {
            answerButton.showMarkIndicator = NO;
            answerButton.showCorrectnessIconIfEvaluated = NO;
        }
        if([answerItem.setByUser boolValue]) [answerButton mark];
        answerButton.answerButtonDelegate = self;
        if(leftRight) {
            answerButton.buttonStyle = StyleColumnLeft;
            [buttonContainerLeftColumn addSubview:answerButton];
        } else {
            answerButton.buttonStyle = StyleColumnRight;
            [buttonContainerRightColumn addSubview:answerButton];
        }
        leftRight = !leftRight;
    }
    [self addSubview:buttonContainerLeftColumn];
    [self addSubview:buttonContainerRightColumn];
}

-(void)addButtonWithExplanationFor:(Answer*)answer_ {
    if([answer_ hasExplanation]) {
        LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
        const CGFloat hSpace = 0.0f;//[style getHorizontalScreenSpace];
        CGFloat widthOfButton = self.frame.size.width - 2 * hSpace;
        const CGRect buttonRect = CGRectMake(hSpace, 0.0f, widthOfButton, [style maxHeightOfAnswerButton]);
        NSString *label = NSLocalizedString(@"QuestionSessionAnswerExplanation", nil);
        UIImage *iconImage = [LayImage imageWithId:LAY_IMAGE_INFO_HINT];
        LayMediaData *mediaData = [LayMediaData byUIImage:iconImage];
        LayButton *additionalInfoButton = [[LayButton alloc]initWithFrame:buttonRect label:label mediaData:mediaData font:[style getFont:NormalPreferredFont] andColor:[style getColor:ClearColor]];
        additionalInfoButton.tag = TAG_FOR_EXPLANATION_BUTTON;
        additionalInfoButton.showMediaWithBorder = NO;
        [additionalInfoButton fitToHeight];
        additionalInfoButton.topBottomLayer = YES;
        [additionalInfoButton addTarget:self action:@selector(showAddtionalInfoToAnswer) forControlEvents:UIControlEventTouchUpInside];
        NSArray *subviews = [self subviews];
        if([subviews count]>0) {
            UIView *firstView = [subviews objectAtIndex:0];
            if(firstView.tag == TAG_IMAGE_RIBBON) {
                [self insertSubview:additionalInfoButton aboveSubview:firstView];
            } else {
                 [self insertSubview:additionalInfoButton belowSubview:firstView];
            }
            
        } else {
            MWLogError([LayAnswerViewChoice class], @"Internal! AnswerView does not contain any subviews!");
        }
        
    }
}

-(UIView*)descendantViewsOf:(UIView*)ancestor withTag:(NSInteger)tag {
    UIView* view = [ancestor viewWithTag:tag];
    if(nil==view) {
        for (UIView *subview in ancestor.subviews) {
            view = [subview viewWithTag:tag];
            if(nil==view) [self descendantViewsOf:subview withTag:tag];
            else break;
        }
    }
    return view;
}

-(void)descendantViewsOfType:(UIView*)ancestor :(Class)class :(NSMutableArray*)descendantViewList {
    for (UIView *subview in ancestor.subviews) {
        if([subview isKindOfClass:class]) {
            [descendantViewList addObject:subview];
        } else {
            [self descendantViewsOfType:subview : class : descendantViewList ];
        }
    }
}

-(CGFloat)layoutViewColumnStyle:(CGFloat)space {
    CGFloat currentOffsetY = 0.0f;
    CGFloat containerHeight = 0.0f;
    CGFloat heightOfLastSubview = 0.0f;
    UIView* leftButtonContainer = [self viewWithTag:TAG_LEFT_COLUMN_BUTTON_CONTAINER];
    for (UIView *subview in [leftButtonContainer subviews]) {
        CGRect subViewFrame = subview.frame;
        subViewFrame.origin.y = currentOffsetY;
        subview.frame = subViewFrame;
        heightOfLastSubview = subViewFrame.size.height;
        currentOffsetY +=  heightOfLastSubview + space;
    }
    
    containerHeight = currentOffsetY;
    [LayFrame setHeightWith:containerHeight toView:leftButtonContainer animated:NO];
    
    heightOfLastSubview = 0.0f;
    currentOffsetY = 0.0f;
    UIView* rightButtonContainer = [self viewWithTag:TAG_RIGHT_COLUMN_BUTTON_CONTAINER];
    for (UIView *subview in [rightButtonContainer subviews]) {
        CGRect subViewFrame = subview.frame;
        subViewFrame.origin.y = currentOffsetY;
        subview.frame = subViewFrame;
        heightOfLastSubview = subViewFrame.size.height;
        currentOffsetY +=  heightOfLastSubview + space;
    }
    
    //currentOffsetY = currentOffsetY - heightOfLastSubview - space;
    [LayFrame setHeightWith:currentOffsetY toView:rightButtonContainer animated:NO];
    
    if(currentOffsetY > containerHeight) {
        containerHeight = currentOffsetY;
    }
    
    // layout the answer-view
    currentOffsetY = 0.0f;
    UIView *ribbon = [self viewWithTag:TAG_IMAGE_RIBBON];
    if(ribbon && !ribbon.hidden) {
        [LayFrame setYPos:currentOffsetY toView:ribbon];
        currentOffsetY = ribbon.frame.size.height + 10.0f;
    }
    
    UIView *explanation = [self viewWithTag:TAG_FOR_EXPLANATION_BUTTON];
    if(explanation) {
        [LayFrame setYPos:currentOffsetY toView:explanation];
        currentOffsetY += explanation.frame.size.height + space;
    }
    
    [LayFrame setYPos:currentOffsetY toView:leftButtonContainer];
    [LayFrame setYPos:currentOffsetY toView:rightButtonContainer];
    containerHeight += currentOffsetY;
    
    [LayFrame setHeightWith:containerHeight toView:self animated:NO];
    return containerHeight;
}

-(CGFloat)layoutViewRowStyle:(CGFloat)space {
    CGFloat currentOffsetY = 0.0f;
    for (UIView *subview in self.subviews) {
        if(!subview.hidden) {
            CGRect subViewFrame = subview.frame;
            subViewFrame.origin.y = currentOffsetY;
            subview.frame = subViewFrame;
            currentOffsetY += subViewFrame.size.height;
            if(subview.tag == TAG_IMAGE_RIBBON) {
                currentOffsetY += 10.0f;
            }
        }
    }
    [LayFrame setHeightWith:currentOffsetY toView:self animated:NO];
    return currentOffsetY;
}

-(CGFloat)layoutView:(CGFloat)space {
    CGFloat height = 0.0f;
    LayAnswerStyleType answerStyle = [answer styleType];
    if(answerStyle == StyleColumn) {
        [self layoutViewColumnStyle:space];
    } else {
       [self layoutViewRowStyle:space];
    }
    return height;
}

-(BOOL) hasUserSelectedAButton {
    BOOL selectedAnButton = NO;
    NSArray *answerItemList = [self->answer answerItemListOrderedByNumber];
    for (AnswerItem* item in answerItemList) {
        if([item.setByUser boolValue]) {
            selectedAnButton = YES;
            break;
        }
    }
    return selectedAnButton;
}

-(void)showAnswerMedia:(Answer*)answer_ {
    if(!self.showMediaList) return;
    [self->imageRibbon removeFromSuperview];
    NSArray *answerMediaList = [answer_ mediaList];
    if(answerMediaList && [answerMediaList count]>0) {
        self->imageRibbon.frame = CGRectMake(0.0, 0.0, self.frame.size.width, HEIGTH_FILLED_RIBBON);
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGSize ribbonEntrySize = [styleGuide maxRibbonEntrySize];
        self->imageRibbon.entrySize = ribbonEntrySize;
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

-(BOOL)answerItemCorrect:(AnswerItem*)answerItem {
    BOOL correct = [answerItem.correct boolValue];
    return correct;
}

-(void) handleUserAnswerChoice:(LayAnswerButton*)answerButton wasSelected:(BOOL)wasSelected {
    if(self.mode==LAY_ANSWER_VIEW_SINGLE_CHOICE) {
        static const NSUInteger MAX_NUMBER_OF_CHOICES = 8;
        NSMutableArray *allButtonsInView = [NSMutableArray arrayWithCapacity:MAX_NUMBER_OF_CHOICES];
        [self descendantViewsOfType:self: [LayAnswerButton class] : allButtonsInView];
        for (LayAnswerButton* button in allButtonsInView) {
            if(button!=answerButton) {
                [button unmark];
            }
        }
    }
}

-(void) handleUserInfoChoice:(LayAnswerButton*)answerButton {
    AnswerItem *answerItem = answerButton.answerItem;
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

-(void)scrollToButton:(LayAnswerButton*)layAnswerButton {
    const CGFloat xPos = layAnswerButton.frame.origin.x;
    const CGFloat yPos = layAnswerButton.frame.origin.y;
    CGPoint posOfButton = CGPointMake(xPos, yPos);
    LayAnswerStyleType styleType = [self->answer styleType];
    if(styleType == StyleColumn) {
        posOfButton = [layAnswerButton convertPoint:posOfButton toView:self];
    } 
    
    if(self->answerViewDelegate) {
        [self->answerViewDelegate scrollToPoint:posOfButton showingHeight:layAnswerButton.frame.size.height];
    }
    
}

-(NSArray*)answerButtonListColumnStyle {
    NSMutableArray *answerButtonList = [NSMutableArray arrayWithCapacity:10];
    UIView *containerLeft = [self viewWithTag:TAG_LEFT_COLUMN_BUTTON_CONTAINER];
    if(containerLeft) {
        for (UIView* subview in [containerLeft subviews]) {
            if([subview isKindOfClass:[LayAnswerButton class]]) {
                [answerButtonList addObject:subview];
            }
        }
    } else {
        MWLogError([LayAnswerViewChoice class], @"Answer has style:column but no column layout!");
    }
    
    UIView *containerRight = [self viewWithTag:TAG_RIGHT_COLUMN_BUTTON_CONTAINER];
    NSInteger numberOfLeftButtonJumps = [answerButtonList count] - 1;
    NSInteger index = 1;
    if(containerRight) {
        for (UIView* subview in [containerRight subviews]) {
            if([subview isKindOfClass:[LayAnswerButton class]]) {
                [answerButtonList insertObject:subview atIndex:index];
                if(numberOfLeftButtonJumps > 0) {
                    index += 2;
                    --numberOfLeftButtonJumps;
                } else {
                    ++index;
                }
            }
        }
    } else {
        MWLogWarning([LayAnswerViewChoice class], @"Answer has style:column but no column(right) layout!");
    }
    
    return answerButtonList;
}

-(NSArray*)answerButtonListRowStyle {
    NSMutableArray *answerButtonList = [NSMutableArray arrayWithCapacity:10];
    for (UIView* subview in [self subviews]) {
        if([subview isKindOfClass:[LayAnswerButton class]]) {
            [answerButtonList addObject:subview];
        }
    }    return answerButtonList;
}

//
// LayAnswerView
//
-(id<LayAnswerView>)initAnswerView {
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
}

-(CGSize)showAnswer:(Answer *)answer_ andSize:(CGSize)viewSize userCanSetAnswer:(BOOL)userCanSetAnswer{
    [self resetView];
    self->answer = answer_;
    self.frame = CGRectMake(0.0, 0.0, viewSize.width, viewSize.height);
    [self showAnswerMedia:answer_];
    [self addButtonsForAnswer:answer_];
    [self layoutView:VERTICAL_SPACE];
    return self.frame.size;
}

-(void)showSolution {
    if(self->evaluated) return;
    self->evaluated = YES;
    if([self->answer hasExplanation]) {
        [self addButtonWithExplanationFor:self->answer];
        [self resized];
    }
    
    NSArray *answerButtonList = nil;
    LayAnswerStyleType answerStyle = [self->answer styleType];
    if(answerStyle == StyleColumn) {
        answerButtonList = [self answerButtonListColumnStyle];
    } else {
        answerButtonList = [self answerButtonListRowStyle];
    }
    BOOL scrolled = NO;
    for (LayAnswerButton *answerButton in answerButtonList) {
        [answerButton showCorrectness];
        AnswerItem *answerItem = answerButton.answerItem;
        if(!scrolled && [answerItem.correct boolValue]) {
            [self scrollToButton:answerButton];
            scrolled = YES;
        }
    }
}

-(BOOL)isUserAnswerCorrect {
    BOOL corretAnswer = YES;
    NSArray *answerItemList = [self->answer answerItemListOrderedByNumber];
    for (AnswerItem* answerItem in answerItemList) {
        if((![answerItem.setByUser boolValue] && [self answerItemCorrect:answerItem]) ||
           ([answerItem.setByUser boolValue] && ![self answerItemCorrect:answerItem])) {
            corretAnswer = NO;
        }
    }
    return corretAnswer;
}

-(UIView*)answerView {
    return self;
}

-(BOOL)userSetAnswer {
    BOOL userSetAnAnswer = NO;
    userSetAnAnswer = [self hasUserSelectedAButton];
    return userSetAnAnswer;
}

-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate {
    self->answerViewDelegate = delegate;
}

-(void)showMarkIndicator:(BOOL)yesNo {
    self.showMarkIndicatorInButtons = yesNo;
}


//
// LayAnswerButtonDelegate
//
-(void)tapped:(LayAnswerButton*)answerButton wasSelected:(BOOL)wasSelected {
    if(self->evaluated) {
        [self handleUserInfoChoice:answerButton];
    } else {
        [self handleUserAnswerChoice:answerButton wasSelected:wasSelected];
    }
}

-(void) resized {
    [self layoutView:VERTICAL_SPACE ];
    if(self->answerViewDelegate) {
        [self->answerViewDelegate resizedToSize:self.frame.size];
    }
}

//
// LayImageRibbonDelegate
//
-(void)scrolledToPage:(NSInteger)page {
    
}

-(void)entryTapped:(NSInteger)identifier {
    
}
@end

