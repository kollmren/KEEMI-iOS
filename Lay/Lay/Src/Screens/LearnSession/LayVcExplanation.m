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

#import "MWLogging.h"

@interface LayVcExplanation () {
    @private
    NSInteger index;
    NSArray *explanationList;
    LayExplanationLearnSession* explanationLearnSession;
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
        
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayVcExplanation class], @"dealloc");
    LayExplanationSessionView *explanationView = (LayExplanationSessionView*)self.view;
    explanationView.explanationDatasource = nil;
    explanationView.explanationViewDelegate = nil;
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
    } else {
        self->explanationLearnSession = [sessionManager sessionWith:catalogToLearn andOrder:EXPLANATION_ORDERED_BY_NUMBER considerTopicSelection:considerTopicSelection];
    }
}

- (void)infoFinished {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

//
// LayExplanationViewDelegate
//
-(void)cancel {
    [self->explanationLearnSession finish];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    catalogManager.selectedExplanations = nil;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
