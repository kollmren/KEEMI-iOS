//
//  LayVcCatalogDetail.m
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcExplanationList.h"
#import "LayVcExplanationListHeader.h"
#import "LayVcNavigationBar.h"
#import "LayStyleGuide.h"
#import "LayAbstractCell.h"
#import "LayImage.h"
#import "LayAppNotifications.h"
#import "LayCatalogManager.h"
#import "LayPublisherLogoView.h"
#import "LayMainDataStore.h"
#import "LaySectionViewMetaInfo.h"
#import "LayTableSectionView.h"
#import "LayConstants.h"

#import "LayVcExplanation.h"
#import "LayVcNavigation.h"

#import "Catalog+Utilities.h"
#import "Explanation+Utilities.h"

#import "MWLogging.h"


@interface LayVcExplanationList () {
    LayVcExplanationListHeader* vcHeader;
    LayVcNavigationBar* navBarViewController;
    LayPublisherLogoView *logoView;
    LayVcExplanation* vcExplanation;
    Class abstractCell;
}
@end

static Class g_classObj = nil;

@implementation LayVcExplanationList

@synthesize fetchedResultsController;

- (id)init {
    self = [super initWithNibName:@"LayVcExplanationList" bundle:nil];
    if (self) {
        [LayCatalogManager instance].currentSelectedQuestion = nil;
        [LayCatalogManager instance].selectedQuestions = nil;
        self->abstractCell = [LayAbstractCell class];
        self->vcExplanation = nil;
        [self registerEvents];
    }
    return self;
}

+(void)initialize {
    g_classObj = [LayVcExplanationList class];
}

-(UIView*) retrieveRoot:(UIView*)view {
    if([view superview]==nil) return view;
    else return [self retrieveRoot:[view superview]];
}

-(void)dealloc {
    MWLogDebug([LayVcExplanationList class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self->vcHeader = [[LayVcExplanationListHeader alloc]initWithNibName:nil bundle:nil];
    self.tableView.tableHeaderView = vcHeader.view;
    //
    [self setupNavigation];
    //
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    self.tableView.backgroundColor = [style getColor:BackgroundColor];;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    [self.tableView registerClass:[LayAbstractCell class] forCellReuseIdentifier:(NSString*)abstractCellIdentifier];
#endif
    
    
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if( !success ) {
        MWLogError(g_classObj, @"Could not load explantions! Details:%@", [error description]);
    }
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
}

-(void)setupNavigation {
    // Setup the navigation controller
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navBarViewController.delegate = self;
    self->navBarViewController.cancelButtonInNavigationBar = YES;
    
    NSString *title = NSLocalizedString(@"CatalogExplanationsTitle", nil);
    [self->navBarViewController showTitle:title atPosition:TITLE_CENTER];
    [self->navBarViewController showButtonsInNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    self->vcExplanation = nil;
    self->navBarViewController.delegate = self;
    
    NSIndexPath *pathToSelectedRow = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:pathToSelectedRow animated:NO];
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
    Explanation* explanation = [fetchedResultsController objectAtIndexPath:indexPath];
    [self startLearnMode:explanation];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Explanation* explanation = [fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat cellHeight = [LayAbstractCell heightForExplanation:explanation];
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
    
    Explanation* explanation = [fetchedResultsController objectAtIndexPath:indexPath];
    abstractCell_.explanation = explanation;
    
    return abstractCell_;
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
}

-(void)handleWantToImportCatalogNotification {
    if(self.navigationController.topViewController == self) {
        if(self->vcExplanation) {
           [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

-(void)handlePreferredFontSizeChanges {
    [self.tableView reloadData];
}


-(void)startLearnMode:(Explanation*)explanation {
    self->vcExplanation = [LayVcExplanation new];
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    catalogMgr.currentSelectedExplanation = explanation;
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:self->vcExplanation];
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
        [request setEntity:[NSEntityDescription entityForName:@"Explanation" inManagedObjectContext:managedObjectContext]];
        NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:numberSortDescriptor, nil]];
        Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catalogRef = %@",
                                  catalog];
        [request setPredicate:predicate];
        NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
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
-(void)cancelPressed {
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


