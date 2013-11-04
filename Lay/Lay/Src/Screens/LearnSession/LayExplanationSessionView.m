//
//  LayExplanationView.m
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayExplanationSessionView.h"
#import "LayMiniIconBar.h"
#import "LayVBoxLayout.h"
#import "LayVBoxView.h"
#import "LayIconButton.h"
#import "LayImage.h"
#import "LayStyleGuide.h"
#import "LayCatalogManager.h"
#import "LayInfoDialog.h"
#import "LayHintView.h"
#import "LayAppNotifications.h"
#import "LayImageRibbon.h"
#import "LayFrame.h"
#import "LayMediaData.h"
#import "LayVcQuestion.h"
#import "LayVcResource.h"
#import "LayVcNotes.h"
#import "LayVcNavigation.h"
#import "LayExplanationView.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Explanation+Utilities.h"

#import "MWLogging.h"

static const CGFloat g_heightOfStatusProgressBar = 20.0f;
static const CGFloat g_heightOfToolbar = 44.0f;
static const NSInteger HEIGTH_FILLED_RIBBON = 190.0f;
static const NSInteger TAG_IMAGE_RIBBON = 1001;
static const CGFloat V_SPACE_TITLE = 15.0f;
static BOOL showUtilitiesToggle = YES;

@interface LayExplanationSessionView() {
    UILabel* statusProgressBar;
    LayMiniIconBar *miniIconBar;
    UIScrollView *explanationView;
    UIButton *previousButton;
    UIButton *nextButton;
    LayVcQuestion *vcQuestion;
    LayVcResource *vcResource;
    LayVcNotes *vcNotes;
}
@end


@implementation LayExplanationSessionView

@synthesize explanationViewDelegate, explanationDatasource, toolbar;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self.backgroundColor = [styleGuide getColor:BackgroundColor];
        [self initExplanationView];
        [self registerEvents];
    }
    return self;
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
}

-(void)dealloc {
    MWLogDebug([LayExplanationSessionView class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    self->vcQuestion = nil;
    self->vcResource = nil;
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    catalogMgr.selectedQuestions = nil;
}

-(void)viewCanAppear {
    [self showNextExplanation];
}

-(void)viewWillAppear {
    self->vcResource = nil;
    self->vcNotes = nil;
    self->vcQuestion = nil;
    if(!showUtilitiesToggle) {
        [self showUtilities];
    }
}

-(void)initExplanationView {
    const CGFloat widthOfView = self.frame.size.width;
    const CGFloat heightOfView = self.frame.size.height;   
    // Status-Progress-Bar --------
    const CGFloat yPosHeader = 0.0f;
    const CGRect statusBarRect = CGRectMake(0.0f, yPosHeader, widthOfView, g_heightOfStatusProgressBar);
    self->statusProgressBar = [[UILabel alloc]initWithFrame:statusBarRect];
    [self setupStatusProgressBar:self->statusProgressBar];
    [self addSubview:self->statusProgressBar];
    // MiniIconBar
    self->miniIconBar = [[LayMiniIconBar alloc]initWithWidth:widthOfView];
    self->miniIconBar.showQuestionIcon = YES;
    self->miniIconBar.showFavouriteIcon = NO;
    //self->miniIconBar.showNotesIcon = NO;
    [self addSubview:self->miniIconBar];
    // Toolbars --------
    const CGFloat yPosToolbar = heightOfView - g_heightOfToolbar;
    const CGRect toolbarRect = CGRectMake(0.0f, yPosToolbar, widthOfView, g_heightOfToolbar);
    self->toolbar = [[UIToolbar alloc]initWithFrame:toolbarRect];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->toolbar.barTintColor = [styleGuide getColor:ToolBarBackground];
    self->toolbar.translucent = YES;
    [self setupToolbar:toolbar];
    [self addSubview:toolbar];
    //
    const CGRect viewFrame = CGRectMake(0.0f, g_heightOfStatusProgressBar, widthOfView, heightOfView- g_heightOfStatusProgressBar - g_heightOfToolbar);
    self->explanationView = [[UIScrollView alloc]initWithFrame:viewFrame];
    [self addSubview:explanationView];
}

-(void)setupToolbar:(UIToolbar*)toolbar_ {
    NSArray* buttonItems = [self navigationButtons];
    [toolbar_ setItems:buttonItems animated:YES];
}

-(NSArray*)navigationButtons {
    self->previousButton = [LayIconButton buttonWithId:LAY_BUTTON_PREVIOUS];
    [previousButton addTarget:self action:@selector(showPreviousExplanation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *previousButtonItem = [[UIBarButtonItem alloc]initWithCustomView:previousButton];
    
    self->nextButton = [LayIconButton buttonWithId:LAY_BUTTON_NEXT];
    [nextButton addTarget:self action:@selector(showNextExplanation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc]initWithCustomView:nextButton];
    
    UIButton *cancelButton = [LayIconButton buttonWithId:LAY_BUTTON_CANCEL];
    [cancelButton addTarget:self action:@selector(closeExplanationView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    
    UIButton *utilitiesButton = [LayIconButton buttonWithId:LAY_BUTTON_TOOLS];
    [utilitiesButton addTarget:self action:@selector(showUtilities) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *utilitiesButtonItem = [[UIBarButtonItem alloc]initWithCustomView:utilitiesButton];
    
    UIBarButtonItem *stretchButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *toolbarButtonList = [NSArray arrayWithObjects:utilitiesButtonItem,stretchButtonItem, cancelButtonItem,  previousButtonItem, nextButtonItem, nil];
    
    return toolbarButtonList;
}

-(NSArray*)utilitiesButtons {
    NSMutableArray *buttonItemList = [NSMutableArray arrayWithCapacity:5];
    UIButton *utilitiesButton = [LayIconButton buttonWithId:LAY_BUTTON_TOOLS];
    [utilitiesButton addTarget:self action:@selector(showUtilities) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *utilitiesButtonItem = [[UIBarButtonItem alloc]initWithCustomView:utilitiesButton];
    UIBarButtonItem *stretchButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttonItemList addObject:utilitiesButtonItem];
    [buttonItemList addObject:stretchButtonItem];
    
    /*UIButton *favouriteButton = [LayIconButton buttonWithId:LAY_BUTTON_FAVOURITES];
    [favouriteButton addTarget:self action:@selector(markExplanationAsFavourite) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *favouriteButtonItem = [[UIBarButtonItem alloc]initWithCustomView:favouriteButton];
    [buttonItemList addObject:favouriteButtonItem];*/
    
    if([self->currentExplanation hasRelatedQuestions]) {
        UIButton *queryButton = [LayIconButton buttonWithId:LAY_BUTTON_QUESTION];
        [queryButton addTarget:self action:@selector(startQuerySession) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *queryButtonItem  = [[UIBarButtonItem alloc]initWithCustomView:queryButton];
        [buttonItemList addObject:queryButtonItem];
    }
    
    UIButton *resourceButton = nil;
    if([self->currentExplanation hasLinkedResources]) {
        resourceButton = [LayIconButton buttonWithId:LAY_BUTTON_RESOURCES_SELECTED];
    } else {
        resourceButton = [LayIconButton buttonWithId:LAY_BUTTON_RESOURCES];
    }
    [resourceButton addTarget:self action:@selector(showResources) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *resourceButtonItem  = [[UIBarButtonItem alloc]initWithCustomView:resourceButton];
    [buttonItemList addObject:resourceButtonItem];
    
    UIButton *noteButton = nil;
    if([self->currentExplanation hasLinkedNotes]) {
        noteButton = [LayIconButton buttonWithId:LAY_BUTTON_NOTES_SELECTED];
    } else {
        noteButton = [LayIconButton buttonWithId:LAY_BUTTON_NOTES];
    }
    [noteButton addTarget:self action:@selector(showNotes) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *noteButtonItem = [[UIBarButtonItem alloc]initWithCustomView:noteButton];
    [buttonItemList addObject:noteButtonItem];

    return buttonItemList;
}

-(void)setupStatusProgressBar:(UILabel*)statusProgressBar_ {
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    statusProgressBar_.backgroundColor = [style getColor:ButtonBorderColor];
    statusProgressBar_.textAlignment = NSTextAlignmentCenter;
    statusProgressBar_.textColor = [UIColor darkGrayColor];
}

-(void)updateStatusProgressBarAmount:(NSUInteger)wholeNumberOfQuestions_ :(NSUInteger)currentQuestionNumber_ {
    static NSString *textFormat = @"%u / %u";
    NSString *text = [NSString stringWithFormat:textFormat,currentQuestionNumber_,wholeNumberOfQuestions_ ];
    self->statusProgressBar.text = text;
}

-(void)showExplanation:(Explanation*)explanation {
    for (UIView* subview in [self->explanationView subviews]) {
        [subview removeFromSuperview];
    }
    [self->explanationView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat vSpace = 10.0f;
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat widthOfExplanationView = self->explanationView.frame.size.width;
    const CGFloat widthOfSubviews = widthOfExplanationView-2*hSpace;
    const CGRect explanationViewRect = CGRectMake(hSpace, vSpace, widthOfSubviews, 0.0f);
    LayExplanationView *view = [[LayExplanationView alloc]initWithFrame:explanationViewRect andExplanation:explanation];
    [self->explanationView addSubview:view];
    self->explanationView.contentSize = CGSizeMake(widthOfExplanationView, view.frame.size.height);
    [self showMiniIconsForExplanation];
    
    NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_EXPLANATION_PRESENTED object:self];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

-(void)showMiniIconsForExplanation {
    /*if([self->currentExplanation isFavourite]) {
        [self->miniIconBar show:YES miniIcon:MINI_FAVOURITE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_FAVOURITE];
    }*/
    
    if([self->currentExplanation hasLinkedResources]) {
        [self->miniIconBar show:YES miniIcon:MINI_RESOURCE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_RESOURCE];
    }
    
    if([self->currentExplanation hasRelatedQuestions]) {
        [self->miniIconBar show:YES miniIcon:MINI_QUERY];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_QUERY];
    }
    
    if([self->currentExplanation hasLinkedNotes]) {
        [self->miniIconBar show:YES miniIcon:MINI_NOTE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_NOTE];
    }
}

-(BOOL)stopForwardNavigation {
    BOOL stop = NO;
    const NSUInteger numberOfCurrentExplanation = [self->explanationDatasource currentExplanationCounterValue];
    const NSUInteger numberOfTotalExplanations = [self.explanationDatasource numberOfExplanations];
    if(numberOfCurrentExplanation == numberOfTotalExplanations) {
        stop = YES;
    }
    return stop;
}

-(BOOL)stopBackwardsNavigation {
    BOOL stop = NO;
    const NSUInteger numberOfCurrentExplanation = [self->explanationDatasource currentExplanationCounterValue];
    const NSUInteger numberOfFirstExplanations = 1;
    if(numberOfCurrentExplanation == numberOfFirstExplanations) {
        stop = YES;
    }
    return stop;
}

-(void)updateNavigation {
    if([self stopForwardNavigation]) {
        self->nextButton.enabled = NO;
        self->nextButton.hidden = YES;
    } else {
        self->nextButton.enabled = YES;
        self->nextButton.hidden = NO;
    }
    
    if([self stopBackwardsNavigation]) {
        self->previousButton.enabled = NO;
        self->previousButton.hidden = YES;
    } else {
        self->previousButton.enabled = YES;
        self->previousButton.hidden = NO;
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

// 
// Action handlers
//

-(void)showNextExplanation {
    if(self.explanationDatasource) {
        currentExplanation = [self.explanationDatasource nextExplanation];
        if(currentExplanation) {
            [self showExplanation:currentExplanation];
            [self updateStatusProgressBarAmount:[self.explanationDatasource numberOfExplanations] : [self.explanationDatasource currentExplanationCounterValue]];
        }
    } else {
        MWLogWarning([LayExplanationSessionView class], @"Datasource to get explanations is nil!");
    }
    [self updateNavigation];
}

-(void)showPreviousExplanation {
    if(self.explanationDatasource) {
        currentExplanation = [self.explanationDatasource previousExplanation];
        if(currentExplanation) {
            [self showExplanation:currentExplanation];
            [self updateStatusProgressBarAmount:[self.explanationDatasource numberOfExplanations] : [self.explanationDatasource currentExplanationCounterValue]];
        }
    } else {
        MWLogWarning([LayExplanationSessionView class], @"Datasource to get explanations is nil!");
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

-(void)startQuerySession {
    NSArray *relatedQuestions = [self->currentExplanation relatedQuestionList];
    if(relatedQuestions) {
        if([relatedQuestions count]>0) {
            self->vcQuestion = [LayVcQuestion new];
            LayCatalogManager* catalogMgr = [LayCatalogManager instance];
            catalogMgr.selectedQuestions = relatedQuestions;
            UINavigationController *navController = [[UINavigationController alloc]
                                                     initWithRootViewController:vcQuestion];
            [navController setNavigationBarHidden:YES animated:NO];
            [navController setModalPresentationStyle:UIModalPresentationFormSheet];
            [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            UIViewController *viewController = [self viewController];
            if(viewController) {
                [viewController presentViewController:navController animated:YES completion:nil];
            } else {
                MWLogError( [LayExplanationSessionView class], @"Could not get a link to the viewcontroller!");
            }
        } else {
            MWLogError( [LayExplanationSessionView class], @"Number of related questions is 0!");
        }
    }
}

-(void)showResources {
    self->vcResource = [[LayVcResource alloc]initWithExplanation:self->currentExplanation];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:self->vcResource];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    UIViewController *viewController = [self viewController];
    if(viewController) {
        [viewController presentViewController:navController animated:YES completion:nil];
    } else {
        MWLogError( [LayExplanationSessionView class], @"Could not get a link to the viewcontroller!");
    }
}

-(void)showNotes {
    self->vcNotes = [[LayVcNotes alloc]initWithExplanation:self->currentExplanation];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:self->vcNotes];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    UIViewController *viewController = [self viewController];
    if(viewController) {
        [viewController presentViewController:navController animated:YES completion:nil];
    } else {
        MWLogError( [LayExplanationSessionView class], @"Could not get a link to the viewcontroller!");
    }
}

-(void)markExplanationAsFavourite {
    if([self->currentExplanation isFavourite]) {
        [self->currentExplanation unmarkExplanationAsFavourite];
        [self->miniIconBar show:NO miniIcon:MINI_FAVOURITE];
    } else {
        [self->currentExplanation markExplanationAsFavourite];
        [self->miniIconBar show:YES miniIcon:MINI_FAVOURITE];
    }
}


-(void)closeExplanationView {
    if(self.explanationViewDelegate) {
        MWLogInfo([LayExplanationSessionView class], @"Finish learn-session.");
        [self.explanationViewDelegate cancel];
    } else {
        MWLogWarning([LayExplanationSessionView class], @"Delegate is nil!");
    }
}

-(void)handlePreferredFontSizeChanges {
    [self showExplanation:self->currentExplanation];
}

@end



