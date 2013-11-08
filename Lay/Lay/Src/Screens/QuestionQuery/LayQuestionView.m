//
//  LayQuestionView.m
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayQuestionView.h"
#import "LayMiniIconBar.h"
#import "LayVBoxLayout.h"
#import "LayVBoxView.h"
#import "LayIconButton.h"
#import "LayImage.h"
#import "LayFrame.h"
#import "LayAnswerView.h"
#import "LayQuestionBubbleView.h"
#import "LayConfigurationManager.h"
#import "LayStyleGuide.h"
#import "LayCatalogManager.h"
#import "LayInfoDialog.h"
#import "LayHintView.h"
#import "LayAppNotifications.h"
#import "LayStatusProgressBar.h"
#import "LayVcResource.h"
#import "LayVcNotes.h"
#import "LayVcNavigation.h"
#import "LayUserDefaults.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Answer+Utilities.h"

#import "MWLogging.h"


@interface QuestionLabel : UILabel<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface TitleLabel : UIView<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface AnswerView : UIView<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface LayUIScrollView : UIScrollView
@end

@interface LayQuestionView() {
    UIScrollView *questionAnswerViewArea;
    LayMiniIconBar *miniIconBar;
    QuestionLabel *questionLabel;
    LayQuestionBubbleView *questionBubbleView;
    AnswerView *answerViewArea;    
    LayStatusProgressBar* statusProgressBar;
    NSTimer* catalogCoverFadeOutTimer;
    NSObject<LayAnswerView> *currentAnswerView;
    CGFloat horizontalBorderOfView;
    
    NSUInteger numberCorrectAnswerdQuestions;
    NSUInteger numberIncorrectAnswerdQuestions;
    
    LayVcResource *vcResource;
    LayVcNotes *vcNotes;
    
    BOOL userBoughtProVersion;
    
    BOOL IN_LARGE_SCREEN_MODE;
}
@end


@implementation LayQuestionView

static const CGFloat g_fontSizeOfQuestionText = 18.0f;
static const CGFloat v_space = 15.0f;
static const CGFloat g_heightOfStatusProgressBar = 20.0f;
static CGFloat g_heightOfStatusBar;
static const CGFloat g_heightOfToolbar = 44.0f;
static BOOL showUtilitiesToggle = YES;

@synthesize questionDelegate, questionDatasource, answerViewManager,
toolbar, nextButton, previousButton, checkButton, utilitiesButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self->numberCorrectAnswerdQuestions = 0;
        self->numberIncorrectAnswerdQuestions = 0;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        horizontalBorderOfView = [styleGuide getHorizontalScreenSpace];
        g_heightOfStatusBar = 0.0f;//[[UIApplication sharedApplication] statusBarFrame].size.height;
        [LayCatalogManager instance].currentCatalogIsUsedInQuestionSession = YES;
        self->IN_LARGE_SCREEN_MODE = YES;
        self->currentAnswerView = nil;
        self.backgroundColor = [styleGuide getColor:BackgroundColor];
        [self initQuestionView];
        [self registerEvents];
        //
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *appSettings = [standardUserDefaults dictionaryRepresentation];
        self->userBoughtProVersion = [appSettings objectForKey:(NSString*)userDidBuyProVersion]==nil?NO:YES;
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayQuestionView class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    self->vcResource = nil;
}

-(void)viewCanAppear {
    [self showNextQuestion];
}

-(void)viewWillAppear {
    self->vcResource = nil;
    self->vcNotes = nil;
    if(!showUtilitiesToggle) {
        [self showUtilities];
    }
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
}

-(void)initQuestionView {
    const CGFloat widthOfView = self.frame.size.width;
    const CGFloat heightOfView = self.frame.size.height;
    // Status-Progress-Bar --------
    const CGRect statusBarRect = CGRectMake(0.0f, g_heightOfStatusBar, widthOfView, g_heightOfStatusProgressBar);
    self->statusProgressBar = [[LayStatusProgressBar alloc]initWithFrame:statusBarRect numberTotal:0 andNumberCurrent:0];
    [self addSubview:self->statusProgressBar];
    self->miniIconBar = [[LayMiniIconBar alloc]initWithWidth:widthOfView];
    [LayFrame setYPos:g_heightOfStatusBar toView:self->miniIconBar];
    [self addSubview:self->miniIconBar];
    // Toolbars --------
    const CGFloat yPosToolbar = heightOfView - g_heightOfToolbar + g_heightOfStatusBar;
    const CGRect toolbarRect = CGRectMake(0.0f, yPosToolbar, widthOfView, g_heightOfToolbar);
    self->toolbar = [[UIToolbar alloc]initWithFrame:toolbarRect];
    [self setupToolbar:toolbar];
    [self addSubview:toolbar];
    //
    // Question - Answer - View --------
    // !! The dimensions of the following views are ajusted depending on the content to show.
    // See: setupAnswerViewForLargeScreen and setupAnswerViewStandardScreen
    CGRect frameQuestionAnswerViewArea = [self frameOfQuestionAnswerView];
    self->questionAnswerViewArea.frame = frameQuestionAnswerViewArea;
    self->questionAnswerViewArea = [[UIScrollView alloc]initWithFrame:frameQuestionAnswerViewArea];
    // Label which shows the question
    self->questionLabel = [[QuestionLabel alloc]init];
    [self setQuestionLabelProperties:self->questionLabel];
    // Answer-view-area
    self->answerViewArea = [[AnswerView alloc]init];
    //self->answerViewArea.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.4];
    
    CGFloat questionMapViewWidth = widthOfView - 2 * horizontalBorderOfView;
    self->questionBubbleView = [[LayQuestionBubbleView alloc]initWithFrame:CGRectMake(horizontalBorderOfView, v_space, questionMapViewWidth, 10.0f)];
    //self->questionMapView.layer.zPosition = 100; //render always on top of all sibling-views
}

-(void)setupAnswerViewForLargeScreen {
    [self->questionLabel removeFromSuperview]; // remove from questionAnswerView-Area
    [self->answerViewArea removeFromSuperview];
    [self->questionAnswerViewArea removeFromSuperview];
    // The answerView gets the area of the question too.
    self->answerViewArea.frame = [self frameOfQuestionAnswerView];
    self->IN_LARGE_SCREEN_MODE = YES;
}

-(void)setupAnswerViewStandardScreen {
    if(self->IN_LARGE_SCREEN_MODE) {
        // setup the question-label
        self->questionLabel.spaceAbove = v_space;
        self->questionLabel.border = horizontalBorderOfView;
        [self->questionAnswerViewArea addSubview:self->questionLabel];
        // setup answer-view-area
        [self->questionBubbleView removeFromSuperview];
        [self->answerViewArea removeFromSuperview]; // Remove from self
        self->answerViewArea.spaceAbove = v_space + 10;
        self->answerViewArea.frame = [self frameOfQuestionAnswerView];
        self->answerViewArea.border = 0.0f;
        [self->questionAnswerViewArea addSubview:self->answerViewArea];
        [self addSubview:self->questionAnswerViewArea];
        self->IN_LARGE_SCREEN_MODE = NO;
    }
    // Set the vertical position and the width of the subviews
    [LayVBoxLayout layoutVBoxSubviewsInView:self->questionAnswerViewArea];
}

-(CGRect)frameOfQuestionAnswerView {
    const CGFloat widthOfView = self.frame.size.width;
    const CGFloat heightOfView = self.frame.size.height;
    const CGFloat heightOfQuestionAnswerView = heightOfView - g_heightOfStatusProgressBar - g_heightOfToolbar - g_heightOfStatusBar;
    const CGRect questionAnswerViewRect =
            CGRectMake(0.0f, g_heightOfStatusProgressBar + g_heightOfStatusBar, widthOfView, heightOfQuestionAnswerView);
    return questionAnswerViewRect;
}

-(void)setQuestionLabelProperties:(UILabel*)label {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    label.backgroundColor = [UIColor clearColor];
    label.font = [styleGuide getFont:NormalPreferredFont];
    label.textColor = [styleGuide getColor:TextColor];
    label.numberOfLines = [styleGuide numberOfLines];
}

-(void)setupToolbar:(UIToolbar*)toolbar_ {
    NSArray* buttonItems = [self navigationButtons];
    [toolbar_ setItems:buttonItems animated:YES];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    toolbar_.barTintColor = [styleGuide getColor:ToolBarBackground];
    toolbar_.translucent = YES;
}

-(NSArray*)navigationButtons {
    self.previousButton = [LayIconButton buttonWithId:LAY_BUTTON_PREVIOUS];
    [self.previousButton addTarget:self action:@selector(showPreviousQuestion) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *previousButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.previousButton];
    
    self.nextButton = [LayIconButton buttonWithId:LAY_BUTTON_NEXT];
    [self.nextButton addTarget:self action:@selector(showNextQuestion) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.nextButton];
   
    self.checkButton = [LayIconButton buttonWithId:LAY_BUTTON_DONE];
    [self.checkButton addTarget:self action:@selector(checkAnswer) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.checkButton];
    
    UIButton *cancelButton = [LayIconButton buttonWithId:LAY_BUTTON_CANCEL];
    [cancelButton addTarget:self action:@selector(closeQuestionView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    
    self.utilitiesButton = [LayIconButton buttonWithId:LAY_BUTTON_TOOLS];
    [utilitiesButton addTarget:self action:@selector(showUtilities) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *utilitiesButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.utilitiesButton];
    
    UIBarButtonItem *stretchButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *toolbarButtonList = [NSArray arrayWithObjects:utilitiesButtonItem,stretchButtonItem, cancelButtonItem,  previousButtonItem, nextButtonItem, doneButtonItem, nil];
    
    [self updateNavigation];
    
    return toolbarButtonList;
}

-(NSArray*)utilitiesButtons {
    NSMutableArray *buttonItemList = [NSMutableArray arrayWithCapacity:5];
    UIButton *utilitiesButtonInUtilityMode = [LayIconButton buttonWithId:LAY_BUTTON_TOOLS];
    [utilitiesButtonInUtilityMode addTarget:self action:@selector(showUtilities) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *utilitiesButtonItem = [[UIBarButtonItem alloc]initWithCustomView:utilitiesButtonInUtilityMode];
    UIBarButtonItem *stretchButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttonItemList addObject:utilitiesButtonItem];
    [buttonItemList addObject:stretchButtonItem];
    
    if(self->userBoughtProVersion) {
        UIButton *favouriteButton = [LayIconButton buttonWithId:LAY_BUTTON_FAVOURITES];
        UIImage *favouriteSelected = [LayImage imageWithId:LAY_IMAGE_FAVOURITES_SELECTED];
        [favouriteButton addTarget:self action:@selector(markQuestionAsFavourite:) forControlEvents:UIControlEventTouchUpInside];
        [favouriteButton setImage:favouriteSelected forState:UIControlStateSelected];
        if([self->currentQuestion isFavourite]) {
            favouriteButton.selected = YES;
        } else {
            favouriteButton.selected = NO;
        }
        UIBarButtonItem *favouriteButtonItem = [[UIBarButtonItem alloc]initWithCustomView:favouriteButton];
        [buttonItemList addObject:favouriteButtonItem];
    }
    
    if(self->userBoughtProVersion || [self->currentQuestion hasLinkedResources]) {
        UIButton *resourceButton = [LayIconButton buttonWithId:LAY_BUTTON_RESOURCES];
        UIImage *resourceSelected = [LayImage imageWithId:LAY_IMAGE_RESOURCES_SELECTED];
        [resourceButton addTarget:self action:@selector(showResources) forControlEvents:UIControlEventTouchUpInside];
        [resourceButton setImage:resourceSelected forState:UIControlStateSelected];
        if([self->currentQuestion hasLinkedResources]) {
            resourceButton.selected = YES;
        } else {
            resourceButton.selected = NO;
        }
        UIBarButtonItem *resourceButtonItem  = [[UIBarButtonItem alloc]initWithCustomView:resourceButton];
        [buttonItemList addObject:resourceButtonItem];
    }
    
    if(self->userBoughtProVersion) {
        UIButton *noteButton = nil;
        if([self->currentQuestion hasLinkedNotes]) {
            noteButton = [LayIconButton buttonWithId:LAY_BUTTON_NOTES_SELECTED];
        } else {
            noteButton = [LayIconButton buttonWithId:LAY_BUTTON_NOTES];
        }
        [noteButton addTarget:self action:@selector(showNotes) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *noteButtonItem = [[UIBarButtonItem alloc]initWithCustomView:noteButton];
        [buttonItemList addObject:noteButtonItem];
    }
    
    return buttonItemList;
}

-(void)updateStatusProgressBarAmount:(NSUInteger)wholeNumberOfQuestions_ :(NSUInteger)currentQuestionNumber_ {
    self->statusProgressBar.numberTotal = wholeNumberOfQuestions_;
    self->statusProgressBar.numberCurrent = currentQuestionNumber_;
    self->statusProgressBar.numberCurrentCorrectAnswers = self->numberCorrectAnswerdQuestions;
    self->statusProgressBar.numberCurrentIncorrectAnswers = self->numberIncorrectAnswerdQuestions;
}

-(void)showQuestion:(Question*)question {
    LayAnswerTypeIdentifier answerTypeIdentifier = [question questionType];
    if(self.answerViewManager) {
        // Remove answer view from self->answerView
        if(self->currentAnswerView) {
            [[self->currentAnswerView answerView] removeFromSuperview];
        }
        self->currentAnswerView = [self.answerViewManager viewForAnswerType:answerTypeIdentifier];
    } else {
        MWLogError([LayQuestionView class], @"No AnswerViewManager set!");
    }
    
    if(self->currentAnswerView) {
        [self->currentAnswerView setDelegate:self];
        if(answerTypeIdentifier==ANSWER_TYPE_SINGLE_CHOICE_LARGE_MEDIA || answerTypeIdentifier==ANSWER_TYPE_MULTIPLE_CHOICE_LARGE_MEDIA) {
            MWLogInfo([LayQuestionView class], @"Show question in large area.");
            // answer-views of type MAP are always presented in large-screen-mode
            [self showQuestionAndAnswerInLargeScreen:question : self->currentAnswerView : YES];
        } else {
            MWLogInfo([LayQuestionView class], @"Show question in standard area.");
            [self showQuestionAndAnswerInStandardScreen:question : self->currentAnswerView :YES];
        }
        if([question isChecked]) {
            [self->currentAnswerView showSolution];
            // the question is already checked, show such configured labels
            NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_ANSWER_EVALUATED object:self];
            [[NSNotificationCenter defaultCenter] postNotification:note];
        }
        NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_QUESTION_PRESENTED object:self];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    } else {
        Catalog *catalog = [self.questionDatasource catalog];
        //TODO Can an question have more than one answer? Should a answer have an ID?
        MWLogError([LayQuestionView class], @"Get no view for question:%@ in catalog:%@!", question.name, catalog.title);
    }
}

static const NSUInteger TAG_QUESTION_TITLE = 105;
-(BOOL)addQuestionTitle:(Question*)question {
    BOOL titleAdded = NO;
    UIView *titleView = [self->questionAnswerViewArea viewWithTag:TAG_QUESTION_TITLE];
    if(titleView) {
        [titleView removeFromSuperview];
    }
    if(question.title) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        UIFont *smallFont = [styleGuide getFont:TitlePreferredFont];
        UIColor *textColor = [styleGuide getColor:TextColor];
        const CGFloat indent = 10.0f;
        const CGFloat titleContainerWidth = self.frame.size.width;
        const CGRect titleContainerFrame = CGRectMake(0.0f, 0.0f, titleContainerWidth, 0.0f);
        TitleLabel *titleContainer = [[TitleLabel alloc]initWithFrame:titleContainerFrame];
        titleContainer.spaceAbove = v_space;
        titleContainer.border = self->horizontalBorderOfView;
        titleContainer.tag = TAG_QUESTION_TITLE;
        //
        const CGFloat titleWith = titleContainerWidth - 2 * self->horizontalBorderOfView - 2 * indent;
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
        [styleGuide makeRoundedBorder:titleContainer withBackgroundColor:GrayTransparentBackground andBorderColor:ClearColor];
        [self->questionAnswerViewArea insertSubview:titleContainer belowSubview:self->questionLabel];
        titleAdded = YES;
    }
    return titleAdded;
}

-(void)showQuestionAndAnswerInStandardScreen:(Question*)question :(NSObject<LayAnswerView>*)answerView :(BOOL)userCanSetAnswer {
    [self showMiniIconsForQuestion];
    [self setupAnswerViewStandardScreen];
    BOOL titleAdded = [self addQuestionTitle:question];
    if(titleAdded) {
        self->questionLabel.spaceAbove = v_space;
    } else {
        self->questionLabel.spaceAbove = v_space;
    }
    NSString *questionText = question.question;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->questionLabel.font = [styleGuide getFont:NormalPreferredFont];
    self->questionLabel.text = questionText;
    [self->questionLabel sizeToFit]; // This must be called to set the height of the label
    CGSize neededAnswerViewSize = [answerView showAnswer:question.answerRef andSize:self->answerViewArea.frame.size userCanSetAnswer:userCanSetAnswer];
    [self adjustSizeOfAnswerViewArea:neededAnswerViewSize];
    self->questionAnswerViewArea.contentOffset = CGPointMake(0.0f,0.0f);
    [self->answerViewArea addSubview:[answerView answerView]];
}

-(void)adjustSizeOfAnswerViewArea:(CGSize)newSize {
    CGRect answerViewAreaFrame = self->answerViewArea.frame;
    answerViewAreaFrame.size = newSize;
    self->answerViewArea.frame = answerViewAreaFrame;
    // Adjust vertical alignment to the content of the question/answer.
    CGSize sizeWithNewHeight = [self frameOfQuestionAnswerView].size;
    sizeWithNewHeight.height = [LayVBoxLayout layoutVBoxSubviewsInView:self->questionAnswerViewArea];
    [self->questionAnswerViewArea setContentSize:sizeWithNewHeight];
}

-(void)showQuestionAndAnswerInLargeScreen:(Question*)question :(NSObject<LayAnswerView>*)answerView :(BOOL)userCanSetAnswer{
    [self showMiniIconsForQuestion];
    [self setupAnswerViewForLargeScreen];
    self->questionBubbleView.question = question;
    [answerView showAnswer:question.answerRef andSize:self->answerViewArea.frame.size userCanSetAnswer:userCanSetAnswer];
    [self->answerViewArea addSubview:[answerView answerView]];
    [self->answerViewArea addSubview:self->questionBubbleView];
    [self addSubview:self->answerViewArea];
}

-(BOOL)evaluateCurrentQuestion:(BOOL)force {
    BOOL doEvaluate = NO;
    if([self->currentQuestion isChecked]==NO) {
        BOOL userSetAnswer = [self->currentAnswerView userSetAnswer];
        self->currentQuestion.answerRef.sessionGivenByUser = [NSNumber numberWithBool:userSetAnswer];
        if(userSetAnswer || force) {
            LayConfigurationManager* cfgMngr = [LayConfigurationManager instance];
            QuerySessionModes configuredQuerySessionMode = cfgMngr.querySessionMode;
            if(configuredQuerySessionMode==QUERY_SESSION_TRAINING_MODE) {
                doEvaluate = YES;
            }
            //
            BOOL result = [self->currentAnswerView isUserAnswerCorrect];
            self->currentQuestion.answerRef.correctAnsweredByUser = [NSNumber numberWithBool:result];
            if(userSetAnswer) {
                if(result) {
                    self->numberCorrectAnswerdQuestions++;
                } else {
                    self->numberIncorrectAnswerdQuestions++;
                }
                [self updateStatusProgressBarAmount:[self.questionDatasource numberOfQuestions] : [self.questionDatasource currentQuestionCounterValue]];
            }
        }
    }
    
    if(doEvaluate) {
        BOOL userSetAnswer = [self->currentAnswerView userSetAnswer];
        BOOL correctAnswer = [self->currentAnswerView isUserAnswerCorrect];
        const CGFloat width = self->questionAnswerViewArea.frame.size.width;
        UIView *parentViewToPresentHint = nil;
        if(self->IN_LARGE_SCREEN_MODE) {
            parentViewToPresentHint = self->answerViewArea;
        } else {
            parentViewToPresentHint = self->questionAnswerViewArea;
        }
        LayHintView *hintView = [[LayHintView alloc]initWithWidth:width view:parentViewToPresentHint target:nil andAction:nil];
        hintView.duration = 1.0f;
        if(userSetAnswer && correctAnswer) {
            NSString *message = NSLocalizedString(@"QuestionSessionAnswerCorrect", nil);
            [hintView showHint:message withBorderColor:AnswerCorrect];
        } else if(userSetAnswer) {
            NSString *message = NSLocalizedString(@"QuestionSessionAnswerWrong", nil);
            [hintView showHint:message withBorderColor:AnswerWrong];
        }
        
        [self->currentAnswerView showSolution];
        [self->currentQuestion setIsChecked:YES];
        
        NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_ANSWER_EVALUATED object:self];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    }
    return doEvaluate;
}

-(BOOL)stopForwardNavigation {
    BOOL stop = NO;
    const NSUInteger numberOfCurrentQuestion = [self->questionDatasource currentQuestionCounterValue];
    const NSUInteger numberOfTotalQuestions = [self.questionDatasource numberOfQuestions];
    if(numberOfCurrentQuestion == numberOfTotalQuestions) {
        stop = YES;
    }
    return stop;
}

-(BOOL)stopBackwardsNavigation {
    BOOL stop = NO;
    const NSUInteger numberOfCurrentQuestion = [self->questionDatasource currentQuestionCounterValue];
    const NSUInteger numberOfFirstQuestions = 1;
    if(numberOfCurrentQuestion == numberOfFirstQuestions) {
        stop = YES;
    }
    return stop;
}

-(void)updateNavigation {
    if([self stopForwardNavigation]) {
        self.nextButton.enabled = NO;
        self.nextButton.hidden = YES;
        if([self->currentQuestion isChecked]) {
            self.checkButton.hidden = YES;
        }
    } else {
        self.nextButton.enabled = YES;
        self.nextButton.hidden = NO;
    }
    
    if([self stopBackwardsNavigation]) {
        self.previousButton.enabled = NO;
        self.previousButton.hidden = YES;
    } else {
        self.previousButton.enabled = YES;
        self.previousButton.hidden = NO;
    }
    
    if(![self stopForwardNavigation] && ![self stopBackwardsNavigation]) {
        self.checkButton.hidden = NO;
    }
    
    NSArray *utilities = [self utilitiesButtons];
    if([utilities count] == 2/*the utility button and the stretch button in the utility-toolbar-mode*/) {
        self.utilitiesButton.enabled = NO;
        self.utilitiesButton.hidden = YES;
    } else {
        self.utilitiesButton.enabled = YES;
        self.utilitiesButton.hidden = NO;
    }
}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)nextResponder;
        }
    }
    
    return nil;
}

-(void)showMiniIconsForQuestion {
    if([self->currentQuestion isFavourite]) {
        [self->miniIconBar show:YES miniIcon:MINI_FAVOURITE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_FAVOURITE];
    }
    
    if([self->currentQuestion hasLinkedResources]) {
        [self->miniIconBar show:YES miniIcon:MINI_RESOURCE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_RESOURCE];
    }
    
    if([self->currentQuestion hasLinkedNotes]) {
        [self->miniIconBar show:YES miniIcon:MINI_NOTE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_NOTE];
    }
}

//
// Action handlers
//

-(void)showNextQuestion {
    BOOL evaluated = [self evaluateCurrentQuestion:NO];
    if(!evaluated) {
        if(self.questionDatasource) {
            currentQuestion = [self.questionDatasource nextQuestion];
            if(currentQuestion) {
                [self showQuestion:currentQuestion];
                [self updateStatusProgressBarAmount:[self.questionDatasource numberOfQuestions] : [self.questionDatasource currentQuestionCounterValue]];
            }
        } else {
            MWLogWarning([LayQuestionView class], @"Datasource to get questions is nil!");
        }
    }
    
    [self updateNavigation];
}

-(void)checkAnswer {
    // Should be only usable in Training-mode
    BOOL evaluated = [self evaluateCurrentQuestion:YES];
    if(!evaluated) {
        [self showNextQuestion];
    }
    
    [self updateNavigation];
}

-(void)showPreviousQuestion {
    BOOL evaluated = [self evaluateCurrentQuestion:NO];
    if(!evaluated) {
        if(self.questionDatasource) {
            currentQuestion = [self.questionDatasource previousQuestion];
            if(currentQuestion) {
                [self showQuestion:currentQuestion];
                [self updateStatusProgressBarAmount:[self.questionDatasource numberOfQuestions] : [self.questionDatasource currentQuestionCounterValue]];
            }
        } else {
            MWLogWarning([LayQuestionView class], @"Datasource to get questions is nil!");
        }
    }
    
    [self updateNavigation];
}

-(void)showUtilities {
    if(showUtilitiesToggle) {
        NSArray* buttonItems = [self utilitiesButtons];
        [self->toolbar setItems:buttonItems animated:YES];
        showUtilitiesToggle = NO;
    } else {
        NSArray* buttonItems = [self navigationButtons];
        [self->toolbar setItems:buttonItems animated:YES];
        showUtilitiesToggle = YES;
    }
}

-(void)showResources {
    self->vcResource = [[LayVcResource alloc]initWithQuestion:self->currentQuestion];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:self->vcResource];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    UIViewController *viewController = [self viewController];
    if(viewController) {
        [viewController presentViewController:navController animated:YES completion:nil];
    } else {
        MWLogError( [LayQuestionView class], @"Could not get a link to the viewcontroller!");
    }
}

-(void)markQuestionAsFavourite:(UIButton*)sender {
    sender.selected = !sender.selected;
    if([self->currentQuestion isFavourite]) {
        [self->currentQuestion unmarkQuestionAsFavourite];
        [self->miniIconBar show:NO miniIcon:MINI_FAVOURITE];
    } else {
        [self->currentQuestion markQuestionAsFavourite];
        [self->miniIconBar show:YES miniIcon:MINI_FAVOURITE];
    }
    /*if(!showUtilitiesToggle) {
        [self showUtilities];
    }*/
}

-(void)showNotes {
    self->vcNotes = [[LayVcNotes alloc]initWithQuestion:self->currentQuestion];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:self->vcNotes];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    UIViewController *viewController = [self viewController];
    if(viewController) {
        [viewController presentViewController:navController animated:YES completion:nil];
    } else {
        MWLogError( [LayQuestionView class], @"Could not get a link to the viewcontroller!");
    }
}

-(void)closeQuestionView {
    [self evaluateCurrentQuestion:NO];
    if(self.questionDelegate) {
        MWLogInfo([LayQuestionView class], @"Finish question-session.");
        [self.questionDelegate cancel];
    } else {
        MWLogWarning([LayQuestionView class], @"Delegate is nil!");
    }
}

-(void)handlePreferredFontSizeChanges {
    [self showQuestion:self->currentQuestion];
}

//
// LayAnswerViewDelegate
//
-(void)resizedToSize:(CGSize)newAnswerViewSize {
    [self adjustSizeOfAnswerViewArea:newAnswerViewSize];
}

-(void)scrollToPoint:(CGPoint)point_ showingHeight:(CGFloat)height{
    CGPoint point = [self->answerViewArea convertPoint:point_ toView:self->questionAnswerViewArea];
    CGRect rectToShow = CGRectMake(point.x, point.y, 100.0f, height);
    [self->questionAnswerViewArea scrollRectToVisible:rectToShow animated:YES];
}

-(void)scrollToTop {
    [self->questionAnswerViewArea  setContentOffset:CGPointZero animated:YES];
}

-(void)evaluate {
    [self evaluateCurrentQuestion:NO];
}
        
@end


@implementation QuestionLabel
@synthesize spaceAbove, keepWidth, border;
@end

@implementation TitleLabel
@synthesize spaceAbove, keepWidth, border;
@end

@implementation AnswerView
@synthesize spaceAbove, keepWidth, border;
@end


