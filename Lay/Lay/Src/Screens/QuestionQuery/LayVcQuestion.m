//
//  LayVcQuestion.m
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayVcQuestion.h"
#import "LayIconButton.h"
#import "LayQuestionView.h"
#import "LayAnswerViewManagerImpl.h"
#import "LayQuestionQuerySessionManager.h"
#import "LayQuestionQuerySession.h"
#import "LayAppNotifications.h"
#import "LayCatalogManager.h"
#import "Catalog+Utilities.h"
#import "Answer+Utilities.h"
#import "LayInfoDialog.h"

#import "MWLogging.h"

@interface LayVcQuestion () {
    @private
    NSInteger index;
    NSArray *questionList;
    LayQuestionQuerySession* questionQuerySession;
}
@end

@implementation LayVcQuestion

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self->questionList = nil;
    self->index = 0;
    [[self navigationController] setNavigationBarHidden:YES];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    return self;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)dealloc {
    MWLogDebug([LayVcQuestion class], @"dealloc");
    LayQuestionView *questionView = (LayQuestionView*)self.view;
    questionView.questionDatasource = nil;
    questionView.questionDelegate = nil;
    [[LayAnswerViewManagerImpl instance] freeAllAnswerViewObjects];
}

- (void)loadView
{
    const CGFloat heightOfStatusbar = [[UIApplication sharedApplication]statusBarFrame].size.height;
    CGRect questionViewFrame = [[UIScreen mainScreen] bounds];
    questionViewFrame.size.height = questionViewFrame.size.height - heightOfStatusbar;
    LayQuestionView *questionView = [[LayQuestionView alloc] initWithFrame:questionViewFrame];
    [self setView:questionView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set delegates
    [self setupQuestionQuerySession];
    LayQuestionView *questionView = (LayQuestionView*)self.view;
	questionView.questionDelegate = self;
    questionView.questionDatasource = self->questionQuerySession;
    questionView.answerViewManager = [LayAnswerViewManagerImpl instance];
    //
    [questionView viewCanAppear];
}

-(void)viewWillAppear:(BOOL)animated {
    LayQuestionView *questionView = (LayQuestionView*)self.view;
    [questionView showMiniIconsForQuestion];
    [questionView viewWillAppear];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)stopQuestionSessionToImportCatalog {
    NSString *title = NSLocalizedString(@"QuestionSessionCancelToImportCatalogTitle", nil);
    NSString *cancelSession = NSLocalizedString(@"QuestionSessionCancelToImportCatalogCancelSession", nil);
    NSString *continueSession = NSLocalizedString(@"QuestionSessionCancelToImportCatalogContinueSession", nil);
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:cancelSession destructiveButtonTitle:nil otherButtonTitles:continueSession, nil];
    if(self.view) {
        LayQuestionView *questionView = (LayQuestionView*)self.view;
        [actionSheet showFromToolbar:questionView.toolbar];
    } else {
        MWLogError([LayVcQuestion class], @"Should stop session but view is not setup yet!");
    }
    
}

//
// UIActionSheetDelegate
//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.cancelButtonIndex == buttonIndex) {
        [self cancel];
    } else if(actionSheet.firstOtherButtonIndex == buttonIndex) {
        // user dont want to import the catalog
        LayCatalogManager *catalogManager = [LayCatalogManager instance];
        catalogManager.pendingCatalogToImport = NO;
    }
}

-(BOOL) showStatistic {
    int correct = self->questionQuerySession.numberOfCorrectAnsweredQuestions;
    int wrong = self->questionQuerySession.numberOfWrongAnsweredQuestions;
    int skipped = self->questionQuerySession.numberOfSkippedQuestions;
    if(correct>0 || wrong>0) {
        NSString *labelCorrect = NSLocalizedString(@"QuestionSessionAnswerCorrect", nil);
        NSString *labelWrong = NSLocalizedString(@"QuestionSessionAnswerWrong", nil);
        NSString *labelSkipped = NSLocalizedString(@"QuestionSessionAnswerSkipped", nil);
        NSArray* info = [[NSArray alloc] initWithObjects:
                         [NSString stringWithFormat:@"%@: %d", labelCorrect, correct],
                         [NSString stringWithFormat:@"%@: %d", labelWrong,wrong],
                         [NSString stringWithFormat:@"%@: %d", labelSkipped,skipped], nil];
        NSString *titleStatistic = NSLocalizedString(@"QuestionSessionAnswerStatistic", nil);
        LayInfoDialog *infoDlg = [[LayInfoDialog alloc]initWithWindow:self.view.window];
        [infoDlg showStatistic:info withTitle:titleStatistic caller:self selector:@selector(infoFinished)];
        return true;
    } else {
        return false;
    }
}

-(void)setupQuestionQuerySession {
    LayQuestionQuerySessionManager *sessionManager = [LayQuestionQuerySessionManager instance];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog* catalogToQuery = [catalogManager currentSelectedCatalog];
    Question* currentSelectedQuestion = [catalogManager currentSelectedQuestion];
    NSArray* selectedQuestionList = [catalogManager selectedQuestions];
    if(currentSelectedQuestion) {
         self->questionQuerySession = [sessionManager queryQuestionSessionWith:catalogToQuery question:currentSelectedQuestion andOrder:QUESTION_ORDER_BY_NUMBER];
    } else if(selectedQuestionList) {
        self->questionQuerySession = [sessionManager queryQuestionSessionWith:catalogToQuery andQuestionList:selectedQuestionList];
    } else {
        BOOL considerTopicSelection = NO;
        if(catalogManager.currentCatalogShouldBeQueriedDirectly) {
            considerTopicSelection = YES;
        }
        self->questionQuerySession = [sessionManager queryQuestionSessionWith:catalogToQuery andOrder:QUESTION_ORDER_RANDOM_LEITNER considerTopicSelection:considerTopicSelection];
    }
}

- (void)infoFinished {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

//
// LayQuestionViewDelegate
//
-(void)cancel {
    [self->questionQuerySession finish];
    BOOL statisticDialogShown = [self showStatistic];
    if(!statisticDialogShown) {
        LayCatalogManager *catalogManager = [LayCatalogManager instance];
        catalogManager.currentCatalogIsUsedInQuestionSession = NO;
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
