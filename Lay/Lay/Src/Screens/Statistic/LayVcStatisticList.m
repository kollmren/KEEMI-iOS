//
//  LayVcCatalogDetail.m
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcStatisticList.h"
#import "LayVcStatisticListHeader.h"
#import "LayVcNavigationBar.h"
#import "LayStyleGuide.h"
#import "LayAbstractCell.h"
#import "LayImage.h"
#import "LayAppNotifications.h"
#import "LayCatalogManager.h"
#import "LayPublisherLogoView.h"
#import "LayVcNavigation.h"
#import "LayVcQuestion.h"
#import "LayMainDataStore.h"
#import "LayStatisticFetchedResultsController.h"
#import "LayTableSectionView.h"
#import "LaySectionViewMetaInfo.h"
#import "LayFrame.h"
#import "LayVBoxLayout.h"
#import "LayIconButton.h"
#import "LaySectionMenu.h"

#import "Catalog+Utilities.h"
#import "UGCCatalog+Utilities.h"
#import "Question.h"

#import "MWLogging.h"

//
// LayVcStatisticList
//
static const NSUInteger maxNumberOfSections = 6;

@interface LayVcStatisticList () {
    LayVcStatisticListHeader* vcHeader;
    LayVcNavigationBar* navBarViewController;
    LayPublisherLogoView *logoView;
    LayVcQuestion* vcQuestion;
    Class abstractCell;
    NSMutableArray *sectionMetaViewList;
    LaySectionMenu *sectionMenu;
}

@end

static Class g_classObj = nil;

@implementation LayVcStatisticList

@synthesize fetchedResultsController;


+(void)initialize {
    g_classObj = [LayVcStatisticList class];
}

- (id)init {
    self = [super initWithNibName:@"LayVcStatisticList" bundle:nil];
    if (self) {
        [LayCatalogManager instance].currentSelectedQuestion = nil;
        [LayCatalogManager instance].selectedQuestions = nil;
        self->sectionMetaViewList = [NSMutableArray arrayWithCapacity:maxNumberOfSections];
        NSString *menuTitle = NSLocalizedString(@"CatalogStatisticMenuTitle", nil);
        self->sectionMenu = [[LaySectionMenu alloc]initWithSectionViewMetaInfoList:self->sectionMetaViewList andTitle:menuTitle];
        self->sectionMenu.menuDelegate = self;
        self->abstractCell = [LayAbstractCell class];
        [self registerEvents];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayVcStatisticList class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
     [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self->vcHeader = [[LayVcStatisticListHeader alloc]initWithNibName:nil bundle:nil];
    self.tableView.tableHeaderView = vcHeader.view;
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navBarViewController.cancelButtonInNavigationBar = YES;
    [self->navBarViewController showButtonsInNavigationBar];
    NSString *title = NSLocalizedString(@"CatalogStatistic", nil);
    [self->navBarViewController showTitle:title  atPosition:TITLE_CENTER];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    [self.tableView registerClass:[LayAbstractCell class] forCellReuseIdentifier:(NSString*)abstractCellIdentifier];
#endif
    
    [self setupSectionViewList];
    
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if( !success ) {
        MWLogError(g_classObj, @"Could not load questions! Details:%@", [error description]);
    } else {
        self->vcHeader.delegate = self;
    }
    
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    self->vcQuestion = nil;
    self->navBarViewController.delegate = self;
    
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if( !success ) {
        MWLogError(g_classObj, @"Could not load questions! Details:%@", [error description]);
    } else {
        self->vcHeader.delegate = self;
    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    if(catalogManager.pendingCatalogToImport) {
        UINavigationController *navController = self.navigationController;
        [navController popToRootViewControllerAnimated:NO];
    } else {
        NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_DONT_SHOW_MEDIA_LABELS object:self];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    }
    
    [self->sectionMenu setWindow:self.tableView.window];
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
    [self->sectionMenu hideSectionOverview:NO];
    Question* question = [fetchedResultsController objectAtIndexPath:indexPath];
    [self startQueryMode:question];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Question* question = [fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat cellHeight = [LayAbstractCell heightForQuestion:question];
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections]objectAtIndex:section];
    NSUInteger caseNumber = [sectionInfo.name integerValue];
    LaySectionViewMetaInfo *sectionMetaView = [self->sectionMetaViewList objectAtIndex:caseNumber];
    return sectionMetaView.sectionView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections]objectAtIndex:section];
    NSUInteger caseNumber = [sectionInfo.name integerValue];
    LaySectionViewMetaInfo *sectionMetaView = [self->sectionMetaViewList objectAtIndex:caseNumber];
    sectionMetaView.sectionInxdexInTable = section;
    return sectionMetaView.sectionView;
}


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
    NSUInteger numberOfRowsInSection = [sectionInfo numberOfObjects];
    NSUInteger caseNumber = [sectionInfo.name integerValue];
    LaySectionViewMetaInfo *sectionMetaView = [self->sectionMetaViewList objectAtIndex:caseNumber];
    sectionMetaView.numberOfRowsInSection = numberOfRowsInSection;
    sectionMetaView.sectionInxdexInTable = section;
   
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

//
//
-(void)setupSectionViewList {
    NSString *label = NSLocalizedString(@"CatalogStatisticKnowNotAnweredYet", nil);
    LayTableSectionView *sectionView = [[LayTableSectionView alloc]initWithTitle:label andBorderColor:ButtonBorderColor];
    LaySectionViewMetaInfo *sectionMetaView = [LaySectionViewMetaInfo viewMetaInfo:sectionView index:0 rows:0 title:label];
    [self->sectionMetaViewList addObject:sectionMetaView];
    
    label = NSLocalizedString(@"CatalogStatisticKnowNothing", nil);
    sectionView = [[LayTableSectionView alloc]initWithTitle:label andBorderColor:AnswerWrong];
    sectionMetaView = [LaySectionViewMetaInfo viewMetaInfo:sectionView index:0 rows:0 title:label];
    [self->sectionMetaViewList addObject:sectionMetaView];
    
    label = NSLocalizedString(@"CatalogStatisticKnowBad", nil);
    sectionView = [[LayTableSectionView alloc]initWithTitle:label andBorderColor:MemoBad];
    sectionMetaView = [LaySectionViewMetaInfo viewMetaInfo:sectionView index:0 rows:0 title:label];
    [self->sectionMetaViewList addObject:sectionMetaView];
    
    label = NSLocalizedString(@"CatalogStatisticKnowWell", nil);
    sectionView = [[LayTableSectionView alloc]initWithTitle:label andBorderColor:MemoWell];
    sectionMetaView = [LaySectionViewMetaInfo viewMetaInfo:sectionView index:0 rows:0 title:label];
    [self->sectionMetaViewList addObject:sectionMetaView];
    
    label = NSLocalizedString(@"CatalogStatisticKnowGood", nil);
    sectionView = [[LayTableSectionView alloc]initWithTitle:label andBorderColor:MemoGood];
    sectionMetaView = [LaySectionViewMetaInfo viewMetaInfo:sectionView index:0 rows:0 title:label];
    [self->sectionMetaViewList addObject:sectionMetaView];
    
    label = NSLocalizedString(@"CatalogStatisticKnowReliable", nil);
    sectionView = [[LayTableSectionView alloc]initWithTitle:label andBorderColor:AnswerCorrect];
    sectionMetaView = [LaySectionViewMetaInfo viewMetaInfo:sectionView index:0 rows:0 title:label];
    [self->sectionMetaViewList addObject:sectionMetaView];
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

//
// LayVcNavigationBarDelegate
//
-(void)cancelPressed {
    [self->sectionMenu closeMenu];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

//
// NSFetchedResultsController
//
- (LayStatisticFetchedResultsController *)fetchedResultsController {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    NSManagedObjectContext *managedObjectContext = [mainStore managedObjectContext];
    if (!fetchedResultsController ) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:managedObjectContext]];
        NSSortDescriptor *caseNumberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"caseNumber" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:caseNumberDescriptor, numberDescriptor, nil]];
        Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catalogRef = %@",
                                  catalog];
        [request setPredicate:predicate];
        LayStatisticFetchedResultsController *newController = [[LayStatisticFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"caseNumber" cacheName:nil];
        
        newController.delegate = self;
        fetchedResultsController = newController;
    }
    
    return fetchedResultsController;
}

//
// NSFetchedResultsControllerDelegate
//

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {   
        case NSFetchedResultsChangeDelete:
        {
            NSUInteger caseNumber = [sectionInfo.name integerValue];
            LaySectionViewMetaInfo *sectionMetaView = [self->sectionMetaViewList objectAtIndex:caseNumber];
            sectionMetaView.numberOfRowsInSection = 0;
            break;
        }
    }
}

//
// LayStatisticListHeader
//

-(void)circlePressed {
    if(![self->sectionMenu menuIsVisible]) {
        [self->sectionMenu showMenu];
    } else {
        [self->sectionMenu hideSectionOverviewAnimated];
    }
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

//
// Action handlers
//
-(void)handlePreferredFontSizeChanges {
    [self->sectionMenu hideSectionOverviewAnimated];
    for (LaySectionViewMetaInfo *sectionMetaView in self->sectionMetaViewList) {
        [sectionMetaView.sectionView adjustToNewPreferredFont];
    }
    [self.tableView reloadData];
}

-(void)handleWantToImportCatalogNotification {
    [self->sectionMenu closeMenu];
    if(self.navigationController.topViewController == self) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

@end



