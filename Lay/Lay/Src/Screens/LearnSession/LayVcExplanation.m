//
//  LayVcExplanation.m
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayVcExplanation.h"
#import "LayIconButton.h"
#import "LayExplanationSessionView.h"
#import "LayExplanationLearnSessionManager.h"
#import "LayExplanationLearnSession.h"
#import "LayAppNotifications.h"
#import "LayCatalogManager.h"
#import "Catalog+Utilities.h"
#import "LayInfoDialog.h"
#import "LayFrame.h"
#import "LayStyleGuide.h"
#import "LayButton.h"

#import "MWLogging.h"

@interface LayVcExplanation () {
    @private
    NSInteger index;
    NSArray *explanationList;
    LayExplanationLearnSession* explanationLearnSession;
    UIView *askOpenRelatedQuestionsDialog;
    NSMutableArray *relatedQuestions;
}
@end

@implementation LayVcExplanation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self->explanationList = nil;
    self->index = 0;
    
    [[self navigationController] setNavigationBarHidden:YES];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        relatedQuestions = nil;
        self->askOpenRelatedQuestionsDialog = nil;
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayVcExplanation class], @"dealloc");
    LayExplanationSessionView *explanationView = (LayExplanationSessionView*)self.view;
    explanationView.explanationDatasource = nil;
    explanationView.explanationViewDelegate = nil;
    relatedQuestions = nil;
    [self closeDialog];
}

- (void)loadView
{
    const CGFloat heightOfStatusbar = [[UIApplication sharedApplication]statusBarFrame].size.height;
    CGRect explanationViewFrame = [[UIScreen mainScreen] bounds];
    explanationViewFrame.size.height = explanationViewFrame.size.height - heightOfStatusbar;
    LayExplanationSessionView *explanationView = [[LayExplanationSessionView alloc] initWithFrame:explanationViewFrame];
    [self setView:explanationView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set delegates
    [self setupExplanationLearnSession];
    LayExplanationSessionView *explanationView = (LayExplanationSessionView*)self.view;
	explanationView.explanationViewDelegate = self;
    explanationView.explanationDatasource = self->explanationLearnSession;
    //
    [explanationView viewCanAppear];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    LayExplanationSessionView *explanationView = (LayExplanationSessionView*)self.view;
    [explanationView showMiniIconsForExplanation];
    [explanationView viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    //LayExplanationView *explanationView = (LayExplanationView*)self.view;
    //explanationView.explanationDatasource = nil;
    //explanationView.explanationViewDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupExplanationLearnSession {
    LayExplanationLearnSessionManager *sessionManager = [LayExplanationLearnSessionManager instance];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog* catalogToLearn = catalogManager.currentSelectedCatalog;
    BOOL considerTopicSelection = NO;
    if(catalogManager.currentCatalogShouldBeLearnedDirectly) {
        considerTopicSelection = YES;
    }
    
    if(catalogManager.selectedExplanations) {
        self->explanationLearnSession = [sessionManager sessionWithListOfExplanations:catalogManager.selectedExplanations];
    } else if( catalogManager.currentSelectedExplanation ) {
        self->explanationLearnSession = [sessionManager sessionWith:catalogToLearn explanation:catalogManager.currentSelectedExplanation andOrder:EXPLANATION_ORDER_BY_NUMBER];
    } else {
        self->explanationLearnSession = [sessionManager sessionWith:catalogToLearn andOrder:EXPLANATION_ORDER_RANDOM considerTopicSelection:considerTopicSelection];
    }
}

- (void)infoFinished {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)showAskRelatedQuestionsDialog:(UIView*)dialog {
    const CGPoint dialogCenter = CGPointMake(0.0f, self.view.window.frame.size.height/2.0f);
    [LayFrame setPos:dialogCenter toView:dialog];
    const CGFloat dialogHeight = [self layoutAskRecallDialog:dialog];
    CALayer *dialogLayer = dialog.layer;
    [UIView animateWithDuration:0.3 animations:^{
        dialogLayer.bounds = CGRectMake(0.0f, 0.0f, dialog.frame.size.width, dialogHeight);
    }];
}

-(UIView*)createAskRelatedQuestionsDialogWithNumberOfExplanations:(NSUInteger)numberExplanations andNumberOfRelatedQuestions:(NSUInteger)numberOfQuestions {
    [self closeDialog];
    
    UIWindow *window = self.view.window;
    const CGFloat width = window.frame.size.width;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIView *backgound = [[UIView alloc] initWithFrame:window.frame];
    backgound.backgroundColor = [[LayStyleGuide instanceOf:nil] getColor:InfoBackgroundColor];
    [window addSubview:backgound];
    self->askOpenRelatedQuestionsDialog = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 0.0f)];
    self->askOpenRelatedQuestionsDialog.backgroundColor = [styleGuide getColor:BackgroundColor];
    self->askOpenRelatedQuestionsDialog.clipsToBounds = TRUE;
    // title
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGRect titleRect = CGRectMake(hSpace, 0.0f, width-2*hSpace, 0.0f);
    UILabel *title = [[UILabel alloc]initWithFrame:titleRect];
    title.font = [styleGuide getFont:NormalPreferredFont];
    title.numberOfLines = [styleGuide numberOfLines];
    title.textColor = [styleGuide getColor:TextColor];
    title.backgroundColor = [UIColor clearColor];
    NSString *titleTextFormat = NSLocalizedString(@"CatalogExplanationAskStartRecallWithRelatedQuestions", nil);
    NSString *titleText = [NSString stringWithFormat:titleTextFormat, numberExplanations];
    title.text = titleText;
    [title sizeToFit];
    [self->askOpenRelatedQuestionsDialog addSubview:title];
    // Buttons
    const CGFloat buttonHeight = [styleGuide getDefaultButtonHeight];
    const CGRect buttonContainerRect = CGRectMake(hSpace, 0.0f, width, buttonHeight);
    UIView *dialogButtonContainer = [[UIView alloc]initWithFrame:buttonContainerRect];
    UIFont *font = [styleGuide getFont:NormalPreferredFont];
    NSString *buttonLabel = NSLocalizedString(@"CatalogRecall", nil);
    LayButton *button = [[LayButton alloc]initWithFrame:buttonContainerRect label:buttonLabel font:font andColor:[styleGuide getColor:WhiteTransparentBackground]];
    button.enabled = YES;
    [button addTarget:self action:@selector(prepareRecallSessionForPresentedExplanations) forControlEvents:UIControlEventTouchUpInside];
    [button fitToContent];
    [dialogButtonContainer addSubview:button];
    buttonLabel = NSLocalizedString(@"Cancel", nil);
    button = [[LayButton alloc]initWithFrame:buttonContainerRect label:buttonLabel font:font andColor:[styleGuide getColor:WhiteTransparentBackground]];
    button.enabled = YES;
    [button addTarget:self action:@selector(closeViewController) forControlEvents:UIControlEventTouchUpInside];
    [button fitToContent];
    [dialogButtonContainer addSubview:button];
    [self layoutDialogButtonContainer:dialogButtonContainer];
    [self->askOpenRelatedQuestionsDialog addSubview:dialogButtonContainer];
    //
    [backgound addSubview:self->askOpenRelatedQuestionsDialog];
    
    return self->askOpenRelatedQuestionsDialog;
}

-(CGFloat)layoutDialogButtonContainer:(UIView*)dialogButtonContainer {
    const CGFloat hSpace = 20.0f;
    CGFloat currentXPos = 0.0f;
    for (UIView* subView in [dialogButtonContainer subviews]) {
        [LayFrame setXPos:currentXPos toView:subView];
        currentXPos += subView.frame.size.width + hSpace;
    }
    return currentXPos;
}

-(CGFloat)layoutAskRecallDialog:(UIView*)dialog {
    const CGFloat vSpace = 10.0f;
    CGFloat currentYPos = 15.0f;
    for (UIView* subView in [dialog subviews]) {
        [LayFrame setYPos:currentYPos toView:subView];
        currentYPos += subView.frame.size.height + vSpace;
    }
    return currentYPos;
}

-(void)closeViewController {
    [self closeDialog];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareRecallSessionForPresentedExplanations {
    if(self->relatedQuestions) {
        LayCatalogManager *catalogManager = [LayCatalogManager instance];
        catalogManager.selectedQuestions = relatedQuestions;
        catalogManager.currentCatalogShouldBeQueriedDirectly = YES;
    }
    [self closeViewController];
}

-(void)closeDialog {
    if(self->askOpenRelatedQuestionsDialog) {
        [self->askOpenRelatedQuestionsDialog.superview removeFromSuperview];
        [self->askOpenRelatedQuestionsDialog removeFromSuperview];
        self->askOpenRelatedQuestionsDialog = nil;
    }
}

//
// LayExplanationViewDelegate
//
-(void)cancel {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    catalogManager.selectedExplanations = nil;
    [self->explanationLearnSession finish];
    
    // Only show the dialog if started from the catalog overview
    if( !(self.presentingViewController.presentingViewController) ) {
        // Check if the read explanations have linked questions, if so ask the user if he want to get ask the questions
        NSDictionary *presentedExplanationsInSession = [self->explanationLearnSession presentedExplanations];
        const NSUInteger numberOfPresentedExplanationsInSession = [presentedExplanationsInSession count];
        if(presentedExplanationsInSession && numberOfPresentedExplanationsInSession > 1) {
            relatedQuestions = [NSMutableArray arrayWithCapacity:20];
            NSArray *presentedExplanationsList = [presentedExplanationsInSession allValues];
            for (Explanation* explanation in presentedExplanationsList) {
                if([explanation hasRelatedQuestions]) {
                    NSArray* relatedQuestionsForExplanation = [explanation relatedQuestionList];
                    [relatedQuestions addObjectsFromArray:relatedQuestionsForExplanation];
                }
            }
            NSUInteger numberOfRelatedQuestions = [relatedQuestions count];
            if(numberOfRelatedQuestions > 1) {
                UIView* askRecallRelatedQuestionsDialog = [self createAskRelatedQuestionsDialogWithNumberOfExplanations:numberOfPresentedExplanationsInSession andNumberOfRelatedQuestions:numberOfRelatedQuestions];
                [self showAskRelatedQuestionsDialog:askRecallRelatedQuestionsDialog];
            } else {
                [self closeViewController];
            }
        } else {
            [self closeViewController];
        }
    } else {
        [self closeViewController];
    }
}

@end
