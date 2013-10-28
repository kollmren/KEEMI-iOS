//
//  LayVcImport.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 13.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayVcCatalogTopics.h"
#import "LayStyleGuide.h"
#import "LayVcNavigationBar.h"
#import "LayImage.h"
#import "LayFrame.h"
#import "LayButton.h"
#import "LayCatalogManager.h"
#import "LayMediaData.h"
#import "LayVBoxLayout.h"
#import "LayError.h"
#import "LayVcQuestion.h"
#import "LayAppNotifications.h"

#import "MWLogging.h"

#import "Topic+Utilities.h"
#import "Catalog+Utilities.h"

static NSInteger TAG_SUMMARY = 101;
static const CGFloat V_SPACE = 0.0f;

@interface LayVcCatalogTopics () {
    NSArray *listOfTopics;
    UIScrollView *catalogTopicView;
    LayVcNavigationBar *navBarViewController;
    StartWithSelectedTopicMode mode;
}

@end

static Class g_classObj = nil;

@implementation LayVcCatalogTopics

+(void) initialize {
    g_classObj = [LayVcCatalogTopics class];
}

-(id)initWithTopicList:(NSArray*)listOfTopics_ andMode:(StartWithSelectedTopicMode)mode_ {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->listOfTopics = listOfTopics_;
        self->mode = mode_;
        [self registerEvents];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithTopicList:nil andMode:START_TOPIC_MODE_QUERY];
}

-(void)dealloc {
    MWLogDebug(g_classObj, @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
}

- (void)loadView
{
    const CGRect screenFrame = [[UIScreen mainScreen] bounds];
    const CGFloat heightOfNavigation = self.navigationController.navigationBar.frame.size.height;
    const CGRect viewFrame = CGRectMake(0.0f, 0.0f, screenFrame.size.width, screenFrame.size.height - heightOfNavigation);
    self->catalogTopicView = [[UIScrollView alloc]initWithFrame:viewFrame];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->catalogTopicView.backgroundColor = [styleGuide getColor:BackgroundColor];
    //
    [self setView:self->catalogTopicView];
    [self setupNavigation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addSummaryButton];
    [self addTopicButtons];
    [self layoutView];
    [self updateNavigationBar];
}

-(void)updateSummary {
    NSUInteger numberOfAllItems = 0;
    NSUInteger numberOfSelectdItems = 0;
    if(self->mode == START_TOPIC_MODE_QUERY) {
        numberOfAllItems = [self numberOfAllQuestions];
        numberOfSelectdItems = [self numberOfSelectedQuestions];
    } else if(self->mode == START_TOPIC_MODE_EXPLANATION) {
        numberOfAllItems = [self numberOfAllExplanations];
        numberOfSelectdItems = [self numberOfSelectedExplanations];
    } else {
        MWLogError([LayVcCatalogTopics class], @"Unknown mode:%u", self->mode);
    }
    
    NSString *text = NSLocalizedString(@"QuestionSessionTopicNumberSelectedQuestions", nil);
    if(self->mode == START_TOPIC_MODE_EXPLANATION) {
        text = NSLocalizedString(@"QuestionSessionTopicNumberSelectedExplanations", nil);
    }
    NSString *textShown = [NSString stringWithFormat:@"%@:\n%u / %u", text, numberOfSelectdItems, numberOfAllItems];
    UILabel *summaryLabel = (UILabel*)[self->catalogTopicView viewWithTag:TAG_SUMMARY];
    if(summaryLabel) {
        summaryLabel.text = textShown;
        [summaryLabel sizeToFit];
        [LayFrame setWidthWith:self.view.frame.size.width toView:summaryLabel];
    }
}

-(void)addSummaryButton {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGRect viewFrame = self.view.frame;
    const CGSize summarySize = CGSizeMake(viewFrame.size.width, [styleGuide maxHeightOfAnswerButton]);
    const CGRect summaryFrame = CGRectMake(0.0f, 0.0f, summarySize.width, summarySize.height);
    UILabel *summaryLabel = [[UILabel alloc]initWithFrame:summaryFrame];
    summaryLabel.backgroundColor = [UIColor clearColor];
    summaryLabel.textAlignment = NSTextAlignmentCenter;
    summaryLabel.tag = TAG_SUMMARY;
    summaryLabel.font = [styleGuide getFont:NormalPreferredFont];
    summaryLabel.textColor = [styleGuide getColor:TextColor];
    summaryLabel.numberOfLines = [styleGuide numberOfLines];
    [self->catalogTopicView addSubview:summaryLabel];
    [self updateSummary];
}

-(NSUInteger)numberOfSelectedQuestions {
    NSUInteger numberOfSelectedQuestions = 0;
    for (Topic* topic in self->listOfTopics) {
        if([topic topicIsSelected]) {
            numberOfSelectedQuestions += [topic numberOfQuestions];
        }
    }
    return numberOfSelectedQuestions;
}

-(NSUInteger)numberOfAllQuestions {
    NSUInteger numberOfAllQuestions = 0;
    for (Topic* topic in self->listOfTopics) {
            numberOfAllQuestions += [topic numberOfQuestions];
    }
    return numberOfAllQuestions;
}

-(NSUInteger)numberOfSelectedExplanations {
    NSUInteger numberOfSelectedExplanations = 0;
    for (Topic* topic in self->listOfTopics) {
        if([topic topicIsSelected]) {
            numberOfSelectedExplanations += [topic numberOfExplanations];
        }
    }
    return numberOfSelectedExplanations;
}

-(NSUInteger)numberOfAllExplanations {
    NSUInteger numberOfAllExplanations = 0;
    for (Topic* topic in self->listOfTopics) {
        numberOfAllExplanations += [topic numberOfExplanations];
    }
    return numberOfAllExplanations;
}

-(void)addTopicButtons {
    NSUInteger index = 0;
    for (Topic* topic in self->listOfTopics) {
        if(self->mode == START_TOPIC_MODE_EXPLANATION) {
            if([topic hasExplanations]) {
                [self addTopicButton:topic withTag:index];
                ++index;
            }
        } else if(self->mode == START_TOPIC_MODE_QUERY) {
            if([topic hasQuestions]) {
                [self addTopicButton:topic withTag:index];
                ++index;
            }
        }
    }
}

-(void)addTopicButton:(Topic*)topic withTag:(NSUInteger)tag {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGRect viewFrame = self.view.frame;
    const CGSize buttonSize = CGSizeMake(viewFrame.size.width, [styleGuide maxHeightOfAnswerButton]);
    const CGRect buttonFrame = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
    LayButton *button = nil;
    if([topic hasMedia]) {
        LayMediaData *mediaData = [LayMediaData byMediaObject:[topic media]];
        button = [[LayButton alloc]initWithFrame:buttonFrame label:topic.title mediaData:mediaData font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
    } else {
        button = [[LayButton alloc]initWithFrame:buttonFrame label:topic.title font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
    }
    
    button.isSelectable = YES;
    button.topBottomLayer = YES;
    button.tag = tag;
    [button addTarget:self action:@selector(topicButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    NSString *numberOfItems =[NSString stringWithFormat:@"%u", [topic numberOfQuestions]];
    if(self->mode == START_TOPIC_MODE_EXPLANATION) {
        numberOfItems = [NSString stringWithFormat:@"%u", [topic numberOfExplanations]];
    }
    [button addAddionalInfo:numberOfItems asBubble:YES];
    if([topic topicIsSelected]) {
        button.selected = YES;
    }
    
    if([topic isDefaultTopic] && [topic numberOfQuestions]>0) {
        button.label = NSLocalizedString(@"QuestionSessionDefaultTopicTitle", nil);
    }
    
    [button fitToHeight];
    
    if(topic.text) {
        button.addionalDetailInfoText = topic.text;
    }
    
    [self->catalogTopicView addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupNavigation {
    // Setup the navigation controller
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navBarViewController.delegate = self;
    self->navBarViewController.cancelButtonInNavigationBar = YES;
    if(self->mode == START_TOPIC_MODE_QUERY) {
        self->navBarViewController.queryButtonInNavigationBar = YES;
    } else if(self->mode == START_TOPIC_MODE_EXPLANATION) {
        self->navBarViewController.learnButtonInNavigationBar = YES;
    }
    
    NSString *title = NSLocalizedString(@"QuestionSessionSelectTopicsTitle", nil);
    [self->navBarViewController showTitle:title atPosition:TITLE_CENTER];
    [self->navBarViewController showButtonsInNavigationBar];
}

-(void)layoutView {
    CGFloat space = V_SPACE;
    CGFloat currentOffsetY = 30.0f;
    for (UIView *subview in [self->catalogTopicView subviews]) {
        if(!subview.hidden) {
            CGRect subViewFrame = subview.frame;
            // y-Pos
            subViewFrame.origin.y = currentOffsetY;
            subview.frame = subViewFrame;
            currentOffsetY += subViewFrame.size.height + space;
            if(subview.tag == TAG_SUMMARY) {
                currentOffsetY += 40.0f;
            }
        }
    }
    CGSize newSize = CGSizeMake(self.view.frame.size.width, currentOffsetY);
    [self->catalogTopicView setContentSize:newSize];
}

//
// Action handlers
//
-(void)topicButtonTouched:(UIButton*)button {
    if(button) {
        NSUInteger index = button.tag;
        Topic *topic = [self->listOfTopics objectAtIndex:index];
        if(button.selected) {
            [topic setTopicAsSelected];
        } else {
            [topic setTopicAsNotSelected];
        }
    }
    
    [self updateNavigationBar];
    
    [self updateSummary];
}

-(void)updateNavigationBar {
    if(self->mode == START_TOPIC_MODE_EXPLANATION) {
        if([self numberOfSelectedExplanations]==0) {
            self->navBarViewController.learnButtonInNavigationBar = NO;
            [self->navBarViewController showButtonsInNavigationBar];
        } else {
            if(!self->navBarViewController.learnButtonInNavigationBar) {
                self->navBarViewController.learnButtonInNavigationBar = YES;
                [self->navBarViewController showButtonsInNavigationBar];
            }
        }
    } else if(self->mode == START_TOPIC_MODE_QUERY) {
        if([self numberOfSelectedQuestions]==0) {
            self->navBarViewController.queryButtonInNavigationBar = NO;
            [self->navBarViewController showButtonsInNavigationBar];
        } else {
            if(!self->navBarViewController.queryButtonInNavigationBar) {
                self->navBarViewController.queryButtonInNavigationBar = YES;
                [self->navBarViewController showButtonsInNavigationBar];
            }
        }
    }

}

-(void)handleWantToImportCatalogNotification {
    if(self.navigationController.topViewController == self) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

//
// LayVcNavigationBarDelegate
//
-(void)cancelPressed {
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    [catalog discardStateOfNewSelectedTopics];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)queryPressed {
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    [catalog saveWhichTopicsTheUserSelected];
    [LayCatalogManager instance].currentCatalogShouldBeQueriedDirectly = YES;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)learnPressed {
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    [catalog saveWhichTopicsTheUserSelected];
    [LayCatalogManager instance].currentCatalogShouldBeLearnedDirectly = YES;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
