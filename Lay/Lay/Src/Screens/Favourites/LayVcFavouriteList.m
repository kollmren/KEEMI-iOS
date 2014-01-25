//
//  LayVcCatalogDetail.m
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcFavouriteList.h"
#import "LayVcFavouriteListHeader.h"
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
#import "LayTableSectionView.h"
#import "LayConstants.h"

#import "LayVcQuestion.h"
#import "LayVcStatisticList.h"
#import "LayVcResource.h"
#import "LayVcExplanation.h"
#import "LayVcCatalogTopics.h"
#import "LayVcNavigation.h"

#import "MWLogging.h"


@interface LayVcFavouriteList () {
    LayVcFavouriteListHeader* vcHeader;
    LayVcNavigationBar* navBarViewController;
    LayPublisherLogoView *logoView;
    LayVcQuestion* vcQuestion;
    Class abstractCell;
}
@end

static Class g_classObj = nil;

@implementation LayVcFavouriteList

@synthesize fetchedResultsController;

- (id)init {
    self = [super initWithNibName:@"LayVcFavouriteList" bundle:nil];
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
    g_classObj = [LayVcFavouriteList class];
}

-(UIView*) retrieveRoot:(UIView*)view {
    if([view superview]==nil) return view;
    else return [self retrieveRoot:[view superview]];
}

-(void)dealloc {
    MWLogDebug([LayVcFavouriteList class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self->vcHeader = [[LayVcFavouriteListHeader alloc]initWithNibName:nil bundle:nil];
    self.tableView.tableHeaderView = vcHeader.view;
    //
    [self setupNavigation];
    //
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    self.tableView.backgroundColor = [style getColor:BackgroundColor];;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    [self.tableView registerClass:[LayAbstractCell class] forCellReuseIdentifier:(NSString*)abstractCellIdentifier];
#endif
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
}

-(void)setupNavigation {
    // Setup the navigation controller
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navBarViewController.delegate = self;
    self->navBarViewController.cancelButtonInNavigationBar = YES;
    self->navBarViewController.queryButtonInNavigationBar = YES;
    
    NSString *title = NSLocalizedString(@"CatalogFavouritesTitle", nil);
    [self->navBarViewController showTitle:title atPosition:TITLE_CENTER];
    [self->navBarViewController showButtonsInNavigationBar];
}

-(void)updateNavigation {
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    const NSUInteger numberOfFavourites = [catalog numberOfFavourites];
    if(numberOfFavourites==0) {
        self->navBarViewController.queryButtonInNavigationBar = NO;
    }
    [self->navBarViewController showButtonsInNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    self->vcQuestion = nil;
    self->navBarViewController.delegate = self;
    [self updateNavigation];
    //
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if( !success ) {
        MWLogError(g_classObj, @"Could not load favourites! Details:%@", [error description]);
    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_DONT_SHOW_MEDIA_LABELS object:self];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (void)viewWillDisappear:(BOOL)animated {
    self->navBarViewController.delegate = nil;
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

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}*/


//
// UITableViewDataSource
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOFSections = [[fetchedResultsController sections] count];
    return numberOFSections;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
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
    [self.tableView reloadData];
}


-(void)startQueryMode:(Question*)question {
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

//
// NSFetchedResultsController
//
- (NSFetchedResultsController *)fetchedResultsController {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    NSManagedObjectContext *managedObjectContext = [mainStore managedObjectContext];
    if (!fetchedResultsController ) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:managedObjectContext]];
        NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:numberSortDescriptor, nil]];
        Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catalogRef = %@ and favourite = %@",
                                  catalog, [NSNumber numberWithBool:YES]];
        [request setPredicate:predicate];
        NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        fetchedResultsController = newController;
    }
    
    return fetchedResultsController;
}

//
// LayVcNavigationBarDelegate
//
-(void)cancelPressed {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)queryPressed {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    NSArray *favouriteList = [[self fetchedResultsController] fetchedObjects];
    catalogManager.selectedQuestions = favouriteList;
    [LayCatalogManager instance].currentCatalogShouldBeQueriedDirectly = YES;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void) searchStarted {
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
}

-(void) searchFinished {
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
}


@end


