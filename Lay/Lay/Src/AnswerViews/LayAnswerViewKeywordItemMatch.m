//
//  LayAnswerViewCard.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 05.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerViewKeywordItemMatch.h"
#import "LayAnswerButton.h"
#import "LayButton.h"
#import "LayFrame.h"
#import "LayVBoxLayout.h"
#import "LayStyleGuide.h"
#import "LayAnswerViewChoice.h"
#import "LayImageRibbon.h"
#import "LayAppNotifications.h"
#import "LayImage.h"
#import "LayTextField.h"
#import "LayHintView.h"

#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"

#import "MWLogging.h"

static const NSInteger HEIGTH_EMPTY_RIBBON = 15.0f;
static const NSInteger HEIGTH_FILLED_RIBBON = 190.0f;
static const CGSize SIZE_EMPTY_RIBBON_ENTRY = {0.0, 0.0};
static const NSInteger TAG_ANSWER_CONTAINER = 12345;
static const NSInteger TAG_TEXT_FIELD_ANSWER = 1234678;
static const NSInteger TAG_TEXT_LAY_FIELD_ANSWER = 12346789;
static const NSInteger TAG_CHECK_ANSWER_BUTTON = 12347;
static const NSInteger TAG_THE_OTHER_BUTTON = 12348;
static const NSInteger TAG_BACKGROUND = 12349;
static const NSInteger TAG_BUTTON_CONTAINER = 123491;
static const NSInteger TAG_ANSWER_CHOICE_VIEW = 123492;
//
static const CGFloat ANSWER_CONTAINER_SPACE_ABOVE = 15.0f;

//
// LayAnswerViewWordResponse
//
@interface LayAnswerViewKeywordItemMatch() {
    Answer* answer;
    LayImageRibbon *imageRibbon;
    // remember the layouted position in the answerView, the position is used to reconnect the
    // container(TextField and buttons) from the window to the anserView 
    CGFloat answerContainerYPos;
    BOOL userTriedAnswering;
}

@end

//
// LayAnswerViewWordResponse
//
@implementation LayAnswerViewKeywordItemMatch

@synthesize answerViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self->imageRibbon = nil;
        self->userTriedAnswering = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayAnswerViewKeywordItemMatch class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)showAnswer:(Answer*)answer_ {
    UIView *answerContainerView = [self viewWithTag:TAG_ANSWER_CONTAINER];
    if(answerContainerView) {
       [answerContainerView removeFromSuperview]; 
    }
    //
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hBorderWidth = [styleGuide getHorizontalScreenSpace];
    const CGFloat containerWidth = self.frame.size.width;
    const CGRect containerFrame = CGRectMake(0.0f, 0.0f, containerWidth, self.frame.size.height);
    UIView *answerContainer = [[UIView alloc]initWithFrame:containerFrame];
    answerContainer.backgroundColor = [styleGuide getColor:BackgroundColor];
    answerContainer.tag = TAG_ANSWER_CONTAINER;
    
    if(!answer_.questionRef.isChecked) {
        // Label
        const CGRect titleRect = CGRectMake(hBorderWidth, 0.0f, containerWidth - 2* hBorderWidth, 0.0f);
        UILabel *title = [[UILabel alloc]initWithFrame:titleRect];
        title.font = [styleGuide getFont:NormalPreferredFont];
        title.backgroundColor = [UIColor clearColor];
        title.textAlignment = NSTextAlignmentLeft;
        title.text = NSLocalizedString(@"CatalogQuestionAnswerItemTitle", nil);
        [title sizeToFit];
        [answerContainer addSubview:title];
        // TextField
        LayTextField *layTextField = [[LayTextField alloc]initWithPosition:CGPointZero andWidth:containerWidth];
        layTextField.tag = TAG_TEXT_LAY_FIELD_ANSWER;
        layTextField->textField.tag = TAG_TEXT_FIELD_ANSWER;
        layTextField->textField.delegate = self;
        [layTextField->textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [answerContainer addSubview:layTextField];
        layTextField->textField.layer.borderColor = [styleGuide getColor:ButtonBorderColor].CGColor;
        // Buttons
        const CGFloat buttonHeight = [styleGuide getDefaultButtonHeight];
        const CGRect buttonContainerRect = CGRectMake(hBorderWidth, 0.0f, containerWidth - 2 * hBorderWidth, buttonHeight);
        UIView *buttonContainer = [[UIView alloc]initWithFrame:buttonContainerRect];
        buttonContainer.hidden = YES;
        buttonContainer.tag = TAG_BUTTON_CONTAINER;
        UIFont *font = [styleGuide getFont:NormalPreferredFont];
        NSString *buttonLabelCheckAnswer = NSLocalizedString(@"QuestionSessionCheckAnswer", nil);
        LayButton *buttonCheckAnswer = [[LayButton alloc]initWithFrame:buttonContainerRect label:buttonLabelCheckAnswer font:font andColor:[styleGuide getColor:WhiteTransparentBackground]];
        buttonCheckAnswer.tag = TAG_CHECK_ANSWER_BUTTON;
        buttonCheckAnswer.enabled = NO;
        [buttonCheckAnswer addTarget:self action:@selector(checkTextInput) forControlEvents:UIControlEventTouchUpInside];
        [buttonCheckAnswer fitToContent];
        NSString *buttonCancelLabel = NSLocalizedString(@"Finished", nil);
        LayButton *buttonCancel = [[LayButton alloc]initWithFrame:buttonContainerRect label:buttonCancelLabel font:font andColor:[styleGuide getColor:WhiteTransparentBackground]];
        buttonCancel.tag = TAG_THE_OTHER_BUTTON;
        [buttonCancel addTarget:self action:@selector(cancelTextInput) forControlEvents:UIControlEventTouchUpInside];
        [buttonCancel fitToContent];
        [buttonContainer addSubview:buttonCheckAnswer];
        [buttonContainer addSubview:buttonCancel];
        [self layoutButtonContainer:buttonContainer];
        [answerContainer addSubview:buttonContainer];
        
    }
    //
    LayAnswerViewChoice *choiceView = [[LayAnswerViewChoice alloc]initAnswerView];
    choiceView.tag = TAG_ANSWER_CHOICE_VIEW;
    choiceView.showMediaList = NO;
    choiceView.showAnswerItemsKnownByUserOnly = YES;
    [choiceView showMarkIndicator:YES];
    [self insertSubview:choiceView aboveSubview:answerContainer];
    //
    [self layoutContainer:answerContainer withStartYPos:0.0f];
    [self addSubview:answerContainer];
    [self layoutView];
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

-(void)layoutView {
    const CGFloat vSpace = 0.0f;
    CGFloat currentYPos = 0.0f;
    for (UIView* subView in [self subviews]) {
        if(!subView.hidden) {
            
            if(subView.tag == TAG_ANSWER_CONTAINER) {
                currentYPos += 15.0f;
                self->answerContainerYPos = currentYPos;
            }
            
            [LayFrame setYPos:currentYPos toView:subView];
            currentYPos += subView.frame.size.height + vSpace;
        }
    }
    [LayFrame setHeightWith:currentYPos toView:self animated:NO];
}

-(void)layoutContainer:(UIView*)container withStartYPos:(CGFloat)startYPos {
    const CGFloat vSpace = 10.0f;
    CGFloat currentYPos = startYPos;
    for (UIView* subView in [container subviews]) {
        if(!subView.hidden) {
            [LayFrame setYPos:currentYPos toView:subView];
            currentYPos += subView.frame.size.height + vSpace;
        }
    }
    [LayFrame setHeightWith:currentYPos toView:container animated:NO];
}

-(void)layoutButtonContainer:(UIView*)buttonContainer {
    const CGFloat hSpace = 20.0f;
    CGFloat currentXPos = 0.0f;
    for (UIView* subView in [buttonContainer subviews]) {
        [LayFrame setXPos:currentXPos toView:subView];
        currentXPos += subView.frame.size.width + hSpace;
    }
}

-(void)resetView {
    self->answerContainerYPos = 0.0f;
    UIView *choiceView = [self viewWithTag:TAG_ANSWER_CHOICE_VIEW];
    if(choiceView) {
        [choiceView removeFromSuperview];
        choiceView = nil;
    }
    self->userTriedAnswering = NO;
}

-(void)closeTextInputDialog {
    UIView *answerContainer = [self.window viewWithTag:TAG_ANSWER_CONTAINER];
    UIView *backgound = [self.window viewWithTag:TAG_BACKGROUND];
    if(answerContainer) {
        UIView *buttonContainer = [self.window viewWithTag:TAG_BUTTON_CONTAINER];
        buttonContainer.hidden = YES;
        [self layoutAnswerContainerNonInputMode:answerContainer];
        [LayFrame setYPos:0.0f toView:answerContainer];
        [answerContainer removeFromSuperview];
        [LayFrame setYPos:self->answerContainerYPos toView:answerContainer];
        [self addSubview:answerContainer];
        [backgound removeFromSuperview];
    }
}

-(void)removeTextInputDialog {
    UIView *answerContainer = [self.window viewWithTag:TAG_ANSWER_CONTAINER];
    [answerContainer removeFromSuperview];
    UIView *backgound = [self.window viewWithTag:TAG_BACKGROUND];
    [backgound removeFromSuperview];
}

-(void)layoutAnswerContainerInputMode:(UIView*)answerContainer {
    // add a little space above the conainer
    [LayFrame setHeightWith:answerContainer.frame.size.height + ANSWER_CONTAINER_SPACE_ABOVE toView:answerContainer animated:NO];
    [self layoutContainer:answerContainer withStartYPos:ANSWER_CONTAINER_SPACE_ABOVE];
}

-(void)layoutAnswerContainerNonInputMode:(UIView*)answerContainer {
    // add a little space above the conainer
    [LayFrame setHeightWith:answerContainer.frame.size.height - ANSWER_CONTAINER_SPACE_ABOVE toView:answerContainer animated:NO];
    [self layoutContainer:answerContainer withStartYPos:0.0f];
}

-(BOOL)answerCorrect {
    BOOL answerCorrect = YES;
    for (AnswerItem *answerItem in [self->answer answerItemListSessionOrderPreserved]) {
        if([answerItem.sessionKnownByUser boolValue] == NO) {
            answerCorrect = NO;
        }
    }
    return answerCorrect;
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
    [LayFrame setSizeWith:viewSize toView:self];
    [self showAnswerMedia:answer_];
    [self showAnswer:answer_];
    const CGFloat vSpace = 10.0f;
    CGFloat neededHeight = [LayVBoxLayout layoutSubviewsOfView:self withSpace:vSpace];
    [LayFrame setHeightWith:neededHeight toView:self animated:NO];
    CGSize newSize = CGSizeMake(viewSize.width, neededHeight);
    return newSize;
}

-(void)showSolution {
    [self removeTextInputDialog];
    const CGSize viewSize = self.frame.size;
    const CGFloat vSpace = 10.0f;
    CGSize sizeForChoiceView = CGSizeMake(viewSize.width, viewSize.height-vSpace);
    LayAnswerViewChoice *choiceView = (LayAnswerViewChoice*)[self viewWithTag:TAG_ANSWER_CHOICE_VIEW];
    choiceView.showAnswerItemsKnownByUserOnly = NO;
    [choiceView showAnswer:self->answer andSize:sizeForChoiceView userCanSetAnswer:YES];
    [choiceView showSolution];
    [self layoutView];
    if(self.answerViewDelegate ) {
        [self.answerViewDelegate resizedToSize:self.frame.size];
    }

}

-(BOOL)userSetAnswer {
    // userTriedAnswering is set if the user checks his given input, if no matches occurre we must
    // mark at least one item as set by user as the session handling indicates a given anser be this flag.
    if( self->userTriedAnswering ) {
        self->answer.sessionAnswer = @"";
    }
    return self->userTriedAnswering;
}

-(BOOL)isUserAnswerCorrect {
    return [self answerCorrect];
}

-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate {
    self.answerViewDelegate = delegate;
}

//
// Action handlers
//
-(void)cancelTextInput {
    [self closeTextInputDialog];
    [self layoutView];
    if(self.answerViewDelegate ) {
        [self.answerViewDelegate resizedToSize:self.frame.size];
    }
}

-(void)checkTextInput {
    self->userTriedAnswering = YES;
    UITextField *answerTextField = (UITextField*)[self.window viewWithTag:TAG_TEXT_FIELD_ANSWER];
    NSString *textFromTextField = answerTextField.text;
    NSString *textToCheck = [textFromTextField stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *textToCheckLowerCase = [textToCheck lowercaseString];
    Question *question = self->answer.questionRef;
    NSUInteger numberOfKnownItems = 0;
    BOOL answerMatched = NO;
    NSString *currentMatchedAnswer = nil;
    NSArray *answerItemList = [self->answer answerItemListSessionOrderPreserved];
    if( [question questionType] == ANSWER_TYPE_KEY_WORD_ITEM_MATCH ) {
        // The order of the items is ignored
        for (AnswerItem *answerItem in answerItemList) {
            BOOL itemAlreadyShown = [answerItem.sessionKnownByUser boolValue];
            if( itemAlreadyShown ) {
                numberOfKnownItems++;
                continue;
            }
            
            NSArray *keywordList = [answerItem keyWordListLowerCase];
            for (NSString *keyword in keywordList) {
                if( [keyword isEqualToString:textToCheckLowerCase] ) {
                    answerItem.sessionKnownByUser = [NSNumber numberWithBool:YES];
                    answerItem.setByUser = [NSNumber numberWithBool:YES];
                    const CGSize viewSize = self.frame.size;
                    const CGFloat vSpace = 10.0f;
                    CGSize sizeForChoiceView = CGSizeMake(viewSize.width, viewSize.height-vSpace);
                    LayAnswerViewChoice *choiceView = (LayAnswerViewChoice*)[self viewWithTag:TAG_ANSWER_CHOICE_VIEW];
                    [choiceView showAnswer:self->answer andSize:sizeForChoiceView userCanSetAnswer:YES];
                    [choiceView showSolution];
                    numberOfKnownItems++;
                    answerMatched = YES;
                    currentMatchedAnswer = answerItem.text;
                    break;
                }
            }
        }
    } else if( [question questionType] == ANSWER_TYPE_KEY_WORD_ITEM_MATCH_ORDERED ) {
        // get the next item to find
        AnswerItem *answerItemToMatchNext = nil;
        for (AnswerItem *answerItem in answerItemList) {
            BOOL itemAlreadyShown = [answerItem.sessionKnownByUser boolValue];
            if( !itemAlreadyShown ) {
                answerItemToMatchNext = answerItem;
                break;
            } else {
                numberOfKnownItems++;
            }
        }
        
        if( answerItemToMatchNext ) {
            NSArray *keywordList = [answerItemToMatchNext keyWordListLowerCase];
            for (NSString *keyword in keywordList) {
                if( [keyword isEqualToString:textToCheckLowerCase] ) {
                    answerItemToMatchNext.sessionKnownByUser = [NSNumber numberWithBool:YES];
                    answerItemToMatchNext.setByUser = [NSNumber numberWithBool:YES];
                    const CGSize viewSize = self.frame.size;
                    const CGFloat vSpace = 10.0f;
                    CGSize sizeForChoiceView = CGSizeMake(viewSize.width, viewSize.height-vSpace);
                    LayAnswerViewChoice *choiceView = (LayAnswerViewChoice*)[self viewWithTag:TAG_ANSWER_CHOICE_VIEW];
                    [choiceView showAnswer:self->answer andSize:sizeForChoiceView userCanSetAnswer:YES];
                    [choiceView showSolution];
                    numberOfKnownItems++;
                    answerMatched = YES;
                    currentMatchedAnswer = answerItemToMatchNext.text;
                    break;
                }
            }
        } else {
            MWLogError([LayAnswerViewKeywordItemMatch class], @"No item found to test next match!");
        }
        
    } else {
        MWLogError([LayAnswerViewKeywordItemMatch class], @"Invalid type of question for view!");
    }
    

    if( answerMatched ) {
        static const NSUInteger MAX_LENGTH_OF_ANSWER_TO_SHOW = 40;
        NSUInteger lengthOfCurrentAnswer = [currentMatchedAnswer length];
        NSString *textToShow = nil;
        if( MAX_LENGTH_OF_ANSWER_TO_SHOW < lengthOfCurrentAnswer ) {
            textToShow = [currentMatchedAnswer substringToIndex:MAX_LENGTH_OF_ANSWER_TO_SHOW-1];
            if( textToShow && [textToShow length] == 0 ) {
                textToShow = NSLocalizedString(@"QuestionItemMatch", nil);
            } else {
                textToShow = [NSString stringWithFormat:@"%@...", textToShow];
            }
        } else {
            textToShow = currentMatchedAnswer;
        }
        [self showMatchHintWithText:textToShow andState:YES];
        answerTextField.text = @"";
    } else {
        NSString *message = NSLocalizedString(@"QuestionItemNoMatch", nil);
        [self showMatchHintWithText:message andState:NO];
    }
    
    if( numberOfKnownItems == [answerItemList count] ) {
        [self removeTextInputDialog];
    }
    
    [self layoutView];
    if(self.answerViewDelegate ) {
        [self.answerViewDelegate resizedToSize:self.frame.size];
    }
    
    /*
    self->answer.sessionAnswer = textToCheck;
    //
    answerTextField.enabled = NO;
    answerTextField.layer.borderColor = [UIColor clearColor].CGColor;
    UIView *buttonContainer = [self viewWithTag:TAG_BUTTON_CONTAINER];
    buttonContainer.hidden = YES;
    UIView *answerContainer = [self viewWithTag:TAG_ANSWER_CONTAINER];
    //
    [self layoutContainer:answerContainer withStartYPos:0.0f];
    if(self.answerViewDelegate) {
        [self.answerViewDelegate evaluate];
    }
     */
}

-(void)showMatchHintWithText:(NSString*)text andState:(BOOL)wrongOrCorrect {
    // Hint
    UIView *backgound = [self.window viewWithTag:TAG_BACKGROUND];
    const CGFloat width = backgound.frame.size.width;
    UIView *parentViewToPresentHint = backgound;
    LayHintView *hintView = [[LayHintView alloc]initWithWidth:width view:parentViewToPresentHint target:nil andAction:nil];
    hintView.duration = 1.5f;
    if(wrongOrCorrect) {
        [hintView showHint:text withBorderColor:AnswerCorrect];
    } else {
        [hintView showHint:text withBorderColor:AnswerWrong];
    }
}

- (void)textFieldChanged:(UITextField *)textField {
    UITextField *answerTextField = (UITextField*)[self.window viewWithTag:TAG_TEXT_FIELD_ANSWER];
    LayButton *checkButton = (LayButton*)[self.window viewWithTag:TAG_CHECK_ANSWER_BUTTON];
    if([answerTextField.text length] > 0) {
        checkButton.enabled = YES;
    } else {
        checkButton.enabled = NO;
    }
}

//
// UITextFieldDelegate methods
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if([textField.text length] > 0) {
        [self checkTextInput];
    } else {
        [self closeTextInputDialog];
    }
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}

//
// keyboard events
//
- (void)keyboardWillShow:(NSNotification *)notification
{
    UIView *buttonContainer = [self viewWithTag:TAG_BUTTON_CONTAINER];
    buttonContainer.hidden = NO;
    UIView *answerContainer = [self viewWithTag:TAG_ANSWER_CONTAINER];
    [self layoutAnswerContainerInputMode:answerContainer];
    if(answerContainer) {
        UIWindow *window = self.window;
        UIView *backgoundView = [[UIView alloc]initWithFrame:window.frame];
        backgoundView.tag = TAG_BACKGROUND;
        backgoundView.backgroundColor = [[LayStyleGuide instanceOf:nil] getColor:InfoBackgroundColor];
        const CGPoint containerPosInWindow = [self convertPoint:answerContainer.center toView:window];
        [window addSubview:backgoundView];
        [window addSubview:answerContainer];
        answerContainer.center = containerPosInWindow;
        //
        const CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat overlapVSpace = answerContainer.frame.origin.y + answerContainer.frame.size.height - keyboardFrame.origin.y;
        if(overlapVSpace > 0.0f) {
            CALayer *dialogLayer = answerContainer.layer;
            const CGFloat newYPosDialog = dialogLayer.position.y - overlapVSpace;
            [UIView animateWithDuration:0.3 animations:^{
                dialogLayer.position = CGPointMake(dialogLayer.position.x, newYPosDialog);
            }];
        } else {
            CALayer *dialogLayer = answerContainer.layer;
            const CGFloat newYPosDialog = keyboardFrame.origin.y - (dialogLayer.bounds.size.height / 2.0f);
            [UIView animateWithDuration:0.3 animations:^{
                dialogLayer.position = CGPointMake(dialogLayer.position.x, newYPosDialog);
            }];
        }
    } else {
        MWLogWarning([LayAnswerViewKeywordItemMatch class], @"Could not find conainer for answer!");
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
}

@end

