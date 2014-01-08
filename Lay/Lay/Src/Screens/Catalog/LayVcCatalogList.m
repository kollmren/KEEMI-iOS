//
//  LayVcCatalogDetail.m
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcCatalogList.h"
#import "LayVcCatalogListHeader.h"
#import "LayVcNavigationBar.h"
#import "LayStyleGuide.h"
#import "LayAbstractCell.h"
#import "LayImage.h"
#import "LayAppNotifications.h"
#import "Catalog+Utilities.h"
#import "Question.h"
#import "LayCatalogManager.h"
#import "LayPublisherLogoView.h"
#import "LayMainDataStore.h"
#import "LaySectionViewMetaInfo.h"
#import "LaySectionMenu.h"
#import "LayTableSectionView.h"
#import "LayConstants.h"
#import "LayVcSearchViewController.h"

#import "LayVcQuestion.h"
#import "LayVcStatisticList.h"
#import "LayVcFavouriteList.h"
#import "LayVcResource.h"
#import "LayVcNotes.h"
#import "LayVcCredits.h"
#import "LayVcExplanation.h"
#import "LayVcCatalogTopics.h"
#import "LayVcExplanationList.h"
#import "LayVcNavigation.h"
#import "LayUserDefaults.h"

#import "Topic+Utilities.h"

#import "MWLogging.h"


@interface LayVcCatalogList () {
    LayVcCatalogListHeader* vcHeader;
    LayVcNavigationBar* navBarViewController;
    LayPublisherLogoView *logoView;
    LayVcQuestion* vcQuestion;
    Class abstractCell;
    //
    NSMutableArray *sectionMetaViewList;
    LaySectionMenu *sectionMenu;
}

@end

static Class g_classObj = nil;

@implementation LayVcCatalogList

@synthesize fetchedResultsController;

- (id)init {
    self = [super initWithNibName:@"LayVcCatalogList" bundle:nil];
    if (self) {
        [LayCatalogManager instance].currentSelectedQuestion = nil;
        [LayCatalogManager instance].selectedQuestions = nil;
        self->abstractCell = [LayAbstractCell class];
        self->vcQuestion = nil;
        [self registerEvents];
    }
    return self;
}

+(void)initialize {
    g_classObj = [LayVcCatalogList class];
}

-(UIView*) retrieveRoot:(UIView*)view {
    if([view superview]==nil) return view;
    else return [self retrieveRoot:[view superview]];
}

-(void)dealloc {
    MWLogDebug([LayVcCatalogList class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self->vcHeader = [[LayVcCatalogListHeader alloc]initWithNibName:nil bundle:nil];
    self.tableView.tableHeaderView = vcHeader.view;
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navBarViewController.backButtonInNavigationBar = YES;
    self->navBarViewController.searchButtonInNavigationBar = YES;
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    UIImage *logoPublisher = [catalog publisherLogo];
    if(logoPublisher) {
        [self->navBarViewController showTitleImage:logoPublisher atPosition:TITLE_CENTER];
        //[self addPublisherLogo:logoPublisher];
    } else {
        [self->navBarViewController showTitle:[catalog publisher]  atPosition:TITLE_CENTER];
    }
    if(catalog.publisherRef)
    [self->navBarViewController showButtonsInNavigationBar];
    //
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    self.tableView.backgroundColor = [style getColor:BackgroundColor];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    [self.tableView registerClass:[LayAbstractCell class] forCellReuseIdentifier:(NSString*)abstractCellIdentifier];
#endif
    
    
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if( !success ) {
        MWLogError(g_classObj, @"Could not load questions! Details:%@", [error description]);
    } else {
        [self setupSectionViewList];
        if([self->sectionMetaViewList count] > 1) {
            // Show the menu only if more than one section exists
            NSString* menuTitle = NSLocalizedString(@"QuestionSessionSelectTopicsTitle", nil);
            self->sectionMenu = [[LaySectionMenu alloc]initWithSectionViewMetaInfoList:self->sectionMetaViewList andTitle:menuTitle];
            self->sectionMenu.menuDelegate = self;
        }
    }
    
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    self->vcQuestion = nil;
    self->navBarViewController.delegate = self;
    self->vcHeader.menu.menuDelegate = self;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    if(catalogManager.pendingCatalogToImport) {
        UINavigationController *navController = self.navigationController;
        [navController popToRootViewControllerAnimated:NO];
    } else if(catalogManager.currentCatalogShouldBeQueriedDirectly) {
        [self startQueryMode:nil];
    } else if(catalogManager.currentCatalogShouldBeLearnedDirectly) {
        [self startLearnMode];
    } else {
        NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_DONT_SHOW_MEDIA_LABELS object:self];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    }
    
    [self->sectionMenu setWindow:self.tableView.window];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appSettings = [standardUserDefaults dictionaryRepresentation];
    BOOL didUserShowCatalogMenu = [appSettings objectForKey:(NSString*)didUserShowCatalogMenuKey]==nil?NO:YES;
    if(!didUserShowCatalogMenu) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self->vcHeader.menu selector:@selector(touch) userInfo:nil repeats:NO];
    }
    [standardUserDefaults setInteger:didUserShowCatalogMenu forKey:(NSString*)didUserShowCatalogMenuKey];
    [standardUserDefaults synchronize];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    self->navBarViewController.delegate = nil;
    [self->sectionMenu closeMenu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
// UITableViewDelegate
//
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    Question* question = [fetchedResultsController objectAtIndexPath:indexPath];
    [self startQueryMode:question];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Question* question = [fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat cellHeight = [LayAbstractCell heightForQuestion:question];
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    LaySectionViewMetaInfo *sectionMetaView = [self->sectionMetaViewList objectAtIndex:section];
    return sectionMetaView.sectionView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LaySectionViewMetaInfo *sectionMetaView = [self->sectionMetaViewList objectAtIndex:section];
    sectionMetaView.sectionInxdexInTable = section;
    return sectionMetaView.sectionView;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}*/


//
// UITableViewDataSource
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    LaySectionViewMetaInfo *sectionMetaView = [self->sectionMetaViewList objectAtIndex:section];
    sectionMetaView.sectionInxdexInTable = section;
    NSUInteger numberOfRowsInSection = [sectionInfo numberOfObjects];
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LayAbstractCell *abstractCell_ = (LayAbstractCell*)[tableView dequeueReusableCellWithIdentifier:(NSString*)abstractCellIdentifier];
    if(nil==abstractCell_) {
        abstractCell_ = [[self->abstractCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(NSString*)abstractCellIdentifier];
    }
    
    Question* question = [fetchedResultsController objectAtIndexPath:indexPath];
    abstractCell_.question = question;
    
    return abstractCell_;
}

-(void)setupSectionViewList {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog* currentCatalog = catalogManager.currentSelectedCatalog;
    NSArray *topicListOrderedByNumber = [currentCatalog topicListQuestions];
    const NSUInteger numberOfSections = [[self.fetchedResultsController sections]count];
    NSUInteger sectionCounter = 0;
    if([topicListOrderedByNumber count] == numberOfSections) {
        sectionMetaViewList = [NSMutableArray arrayWithCapacity:numberOfSections];
        for (id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchedResultsController sections]) {
            Topic* topic = (Topic*)[topicListOrderedByNumber objectAtIndex:sectionCounter++];
            NSString *label = topic.title;
            if([label isEqualToString:(NSString*)TITLE_OF_DEFAULT_TOPIC]) {
                label = NSLocalizedString(@"CatalogTitleOfDefaultTopic", nil);
            }
            LayTableSectionView *sectionView = [[LayTableSectionView alloc]initWithTitle:label andBorderColor:GrayTransparentBackground];
            NSUInteger numberOfRowsInSection = [sectionInfo numberOfObjects];
            LaySectionViewMetaInfo *sectionMetaView = [LaySectionViewMetaInfo viewMetaInfo:sectionView index:0 rows:numberOfRowsInSection  title:label];
            [self->sectionMetaViewList addObject:sectionMetaView];
        }
    } else {
        MWLogError([LayVcCatalogList class],
                   @"Number of sections does not match(%u, %u)!", [topicListOrderedByNumber count], numberOfSections);
    }
    
}

-(void) addPublisherLogo:(UIImage*)logo {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    const CGFloat heightOfStatusBar = [[UIApplication sharedApplication] statusBarFrame].size.height;
    const CGFloat widthOfWindow = window.frame.size.width;
    const CGFloat widthOfLogo = 210.0f;
    const CGFloat heightOfLogo = 50.0f;
    // center logo horizontally
    const CGFloat xPosLogo = widthOfWindow/2 - widthOfLogo/2;
    const CGFloat yPosLogo = heightOfStatusBar + 5.0f;
    CGRect logoRect = CGRectMake(xPosLogo, yPosLogo, widthOfLogo, heightOfLogo);
    self->logoView = [[LayPublisherLogoView alloc]initWithFrame:logoRect];
    self->logoView.image = logo;
    [window addSubview:logoView];
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
}

-(void)handleWantToImportCatalogNotification {
    if(self.navigationController.topViewController == self) {
        if(self->vcQuestion) {
            // session is running
            [self->vcQuestion stopQuestionSessionToImportCatalog];
        } else {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

-(void)handlePreferredFontSizeChanges {
    [self->sectionMenu hideSectionOverviewAnimated];
    for (LaySectionViewMetaInfo *sectionMetaView in self->sectionMetaViewList) {
        [sectionMetaView.sectionView adjustToNewPreferredFont];
    }
    [self.tableView reloadData];
}


//
// NSFetchedResultsController
//
- (NSFetchedResultsController *)fetchedResultsController {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    NSManagedObjectContext *managedObjectContext = [mainStore managedObjectContext];
    if (!fetchedResultsController ) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSSortDescriptor *topicSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"topicRef.number" ascending:YES];
        [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:managedObjectContext]];
        NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:topicSortDescriptor, numberSortDescriptor, nil]];
        Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catalogRef = %@",
                                  catalog];
        [request setPredicate:predicate];
        NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"topicRef.number" cacheName:nil];
        
        newController.delegate = self;
        fetchedResultsController = newController;
    }
    
    return fetchedResultsController;
}

//
// NSFetchedResultsControllerDelegate
//

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            /*UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            AWRandomDate *object = [controller objectAtIndexPath:indexPath];
            cell.textLabel.text = [object.date description];
            cell.detailTextLabel.text = object.dayName;*/
            break;
        }
    }
}

//
// LayVcNavigationBarDelegate
//
-(void) searchIconPressed {
    LayVcSearchViewController *searchViewController = [LayVcSearchViewController new];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:searchViewController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void) searchFinished {
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
}

//
// LayScrollMenuDelegate
//
-(void)entryTapped:(NSInteger)identifier {
    switch (identifier) {
        case MENU_LEARN:
            [self startLearnMode];
            break;
        case MENU_LEARN_OVERVIEW:
            [self showExplanationOverview];
            break;
        case MENU_QUERY:
            [self startQueryMode:nil];
            break;
        case MENU_QUERY_BY_TOPIC:
            [self showListOfTopicsToQuery];
            break;
        case MENU_LEARN_BY_TOPIC:
            [self showListOfTopicsToLearn];
            break;
        case MENU_RESOURCE:
            [self showResource];
            break;
        case MENU_NOTES:
            [self showNotes];
            break;
        case MENU_CREDITS:
            [self showCredits];
            break;
        case MENU_FAVOURITES:
            [self showFavourites];
            break;
        case MENU_STATISTIC:
            [self showStatistic];
            break;
        case MENU_SHARE:
            [self shareCatalog];
            break;
        default:
            MWLogError([LayVcCatalogListHeader class], @"Unknwown menu entry identifier!!!");
            break;
    }
}

-(void)startLearnMode {
    [self->sectionMenu closeMenu];
    LayVcExplanation *vcExplanation = [LayVcExplanation new];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:vcExplanation];
    [navController setNavigationBarHidden:YES animated:NO];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)showExplanationOverview {
    [self->sectionMenu closeMenu];
    LayVcExplanationList *vcExplanationList = [LayVcExplanationList new];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:vcExplanationList];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)startQueryMode:(Question*)question {
    [self->sectionMenu closeMenu];
    self->vcQuestion = [LayVcQuestion new];
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    catalogMgr.currentSelectedQuestion = question;
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:vcQuestion];
    [navController setNavigationBarHidden:YES animated:NO];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)showListOfTopicsToQuery {
    [self->sectionMenu closeMenu];
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    Catalog *currentCatalog = catalogMgr.currentSelectedCatalog;
    NSArray *listOfTopics = [currentCatalog topicList];
    LayVcCatalogTopics *catalogTopics = [[LayVcCatalogTopics alloc]initWithTopicList:listOfTopics andMode:START_TOPIC_MODE_QUERY];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:catalogTopics];
    //[navController setNavigationBarHidden:YES animated:NO];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)showListOfTopicsToLearn {
    [self->sectionMenu closeMenu];
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    Catalog *currentCatalog = catalogMgr.currentSelectedCatalog;
    NSArray *listOfTopics = [currentCatalog topicList];
    LayVcCatalogTopics *catalogTopics = [[LayVcCatalogTopics alloc]initWithTopicList:listOfTopics andMode:START_TOPIC_MODE_EXPLANATION];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:catalogTopics];
    //[navController setNavigationBarHidden:YES animated:NO];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)showFavourites {
    [self->sectionMenu closeMenu];
    LayVcFavouriteList *vcCatalogFavourites = [LayVcFavouriteList new];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:vcCatalogFavourites];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)showStatistic {
    [self->sectionMenu closeMenu];
    LayVcStatisticList *vcCatalogStatistic = [LayVcStatisticList new];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:vcCatalogStatistic];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)showResource {
    [self->sectionMenu closeMenu];
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    Catalog *currentCatalog = catalogMgr.currentSelectedCatalog;
    LayVcResource *vcCatalogResource = [[LayVcResource alloc]initWithCatalog:currentCatalog];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:vcCatalogResource];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)showNotes {
    [self->sectionMenu closeMenu];
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    Catalog *currentCatalog = catalogMgr.currentSelectedCatalog;
    LayVcNotes *vcCatalogNotes = [[LayVcNotes alloc]initWithCatalog:currentCatalog];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:vcCatalogNotes];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)showCredits {
    [self->sectionMenu closeMenu];
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    Catalog *currentCatalog = catalogMgr.currentSelectedCatalog;
    LayVcCredits *vcCatalogCredits = [[LayVcCredits alloc]initWithCatalog:currentCatalog];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:vcCatalogCredits];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)shareCatalog {
    if ([MFMailComposeViewController canSendMail])
	{
        MWLogDebug([[LayVcCatalogList class] class], @"Try to send message by mail.");
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        NSString *subject = NSLocalizedString(@"CatalogShareByMailSubject",nil);
        [picker setSubject:subject];
        
        [picker setToRecipients:nil];
        
        NSString *text = NSLocalizedString(@"CatalogShareByMailText",nil);
        LayCatalogManager *catalogManager = [LayCatalogManager instance];
        Catalog *catalog = catalogManager.currentSelectedCatalog;
        NSString *textWithSource = [NSString stringWithFormat:@"%@, %@", text, catalog.source];
        [picker setMessageBody:textWithSource isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
	else
	{
        MWLogError( [[LayVcCatalogList class] class], @"E-Mail is not configured!");
        NSString *text = NSLocalizedString(@"MailNotConfiguredText", nil);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:text
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
	}

}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if(error) {
        MWLogError([LayVcCatalogList class], @"mailComposeController:%@,%d", [error domain], [error code]);
    }
    
    switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			MWLogInfo([LayVcCatalogList class], @"Send report.");
			break;
		case MFMailComposeResultFailed:
			MWLogError([[LayVcCatalogList class] class], @"Failed to send report.");
			break;
		default:
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:nil];
}


//
// LaySectionMenuDelegate
//
-(void)sectionSelected:(NSUInteger)section {
    NSIndexPath *indexPathForRow = [NSIndexPath indexPathForRow:NSNotFound inSection:section];
    [self.tableView scrollToRowAtIndexPath:indexPathForRow atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)scrollToTop {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

-(BOOL)isOnTop {
    BOOL isOnTop = YES;
    const CGPoint scrolledIndicator = CGPointMake(0.0f, 50.0f);
    if(self.tableView.contentOffset.y > scrolledIndicator.y ) {
        isOnTop = NO;
    }
    return isOnTop;
}


@end


