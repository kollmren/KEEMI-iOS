//
//  LayVcSearchViewController.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 17.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayVcSearchViewController.h"
#import "LayVcNavigationBar.h"
#import "LayCatalogDetails.h"
#import "LayCatalogManager.h"
#import "LayStyleGuide.h"
#import "LayMainDataStore.h"
#import "LayAbstractCell.h"
#import "LayVcQuestion.h"
#import "LayVcExplanation.h"
#import "LayButton.h"
#import "LayFrame.h"

#import "Catalog+Utilities.h"
#import "SearchWordRelation+Utilities.h"

#import "MWLogging.h"

typedef enum LaySearchObject_ {
    LAY_SEARCH_QUESTION_OBJ = 0,
    LAY_SEARCH_EXPLANATION_OBJ,
    LAY_SEARCH_RESOURCE_OBJ
} LaySearchObject;

@interface LayVcSearchViewController () {
    LayVcNavigationBar *navigationItemCfg;
    UISearchDisplayController *searchDisplayController;
    NSFetchedResultsController *searchResultsFetchedController;
}

@end

@implementation LayVcSearchViewController

static Class g_classObj = nil;

+(void) initialize {
    g_classObj = [LayVcSearchViewController class];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc {
    MWLogDebug( g_classObj, @"dealloc" );
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    catalogMgr.selectedQuestions = nil;
    catalogMgr.selectedExplanations = nil;
    if(self->startSessionButton) {
        [self->startSessionButton removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    // setup navigation
    self->navigationItemCfg = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navigationItemCfg.delegate = self;
    NSString *searchTitle = NSLocalizedString(@"CatalogSearch", nil);
    [self->navigationItemCfg showTitle:searchTitle atPosition:TITLE_CENTER];
    self->navigationItemCfg.cancelButtonInNavigationBar = YES;
    [self->navigationItemCfg showButtonsInNavigationBar];
    // UISearchBar
    UINavigationBar* navBar = self.navigationController.navigationBar;
    const CGRect navBarRect = CGRectMake(0.0f, 0.0f, navBar.frame.size.width, navBar.frame.size.height);
    UISearchBar* searchBar = [[UISearchBar alloc]initWithFrame:navBarRect];
    searchBar.placeholder = NSLocalizedString(@"CatalogSearchPlaceholder", nil);
    //LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    //searchBar.barTintColor = [styleGuide getColor:ToolBarBackground];
    //searchBar.tintColor = [styleGuide getColor:ButtonSelectedColor];
    searchBar.showsCancelButton = YES;
    NSString *questionScopeLabel =  NSLocalizedString(@"CatalogDetailLabelNumberOdQuestions", nil);
    NSString *explanationScopeLabel =  NSLocalizedString(@"CatalogDetailLabelNumberOdExplanations", nil);
    searchBar.scopeButtonTitles = @[questionScopeLabel, explanationScopeLabel];
    searchBar.selectedScopeButtonIndex = LAY_SEARCH_QUESTION_OBJ;
    searchBar.delegate = self;
    // UISearchController
    self->searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    self->searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self->searchDisplayController.searchResultsTableView.separatorColor = [UIColor clearColor];
    //self->searchDisplayController .displaysSearchBarInNavigationBar = YES;
    self->searchDisplayController .delegate = self;
    self->searchDisplayController.searchResultsDataSource = self;
    self->searchDisplayController.searchResultsDelegate = self;
    //
    self.tableView.tableHeaderView = searchBar;
    
    [self showCatalogInfoAsBackground];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showCatalogInfoAsBackground {
    const CGFloat heightOfStatusBar = [[UIApplication sharedApplication] statusBarFrame].size.height;
    const CGFloat yPos = self.navigationController.navigationBar.frame.size.height + self.searchDisplayController.searchBar.frame.size.height + heightOfStatusBar + 15.0f;
    Catalog *currentSelectedCatalog = [LayCatalogManager instance].currentSelectedCatalog;
    LayCatalogDetails* catalogDetails = [[LayCatalogDetails alloc]initWithCatalog:currentSelectedCatalog andPositionY:yPos];
    catalogDetails.alpha = 0.5f;
    catalogDetails.showDetailTable = NO;
    [self.tableView setBackgroundView:catalogDetails];
}

-(void)setupSearchFetchController:(UISearchDisplayController *)controller forSearchString:(NSString *)searchString {
    if(self->startSessionButton) {
        [self->startSessionButton removeFromSuperview];
        self->startSessionButton = nil;
    }
    
    NSArray *stringComponents = [searchString componentsSeparatedByString:@" "];
    LaySearchObject *searchObject = LAY_SEARCH_QUESTION_OBJ;
    if( controller.searchBar.selectedScopeButtonIndex == LAY_SEARCH_EXPLANATION_OBJ ) {
        searchObject = LAY_SEARCH_EXPLANATION_OBJ;
    }
    self->searchResultsFetchedController = [self fetchedResultsControllerForSearchObject:searchObject andSearchWordList:stringComponents];
}

-(void)startQueryMode:(Question*)question {
    LayVcQuestion *vcQuestion = [LayVcQuestion new];
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    catalogMgr.currentSelectedQuestion = question;
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:vcQuestion];
    [navController setNavigationBarHidden:YES animated:NO];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)startLearnMode:(Explanation*)explanation {
    LayVcExplanation *vcExplanation = [LayVcExplanation new];
    LayCatalogManager* catalogMgr = [LayCatalogManager instance];
    catalogMgr.currentSelectedExplanation = explanation;
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:vcExplanation];
    [navController setNavigationBarHidden:YES animated:NO];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)addStartSessionButton {
    if(self->startSessionButton) {
        [self->startSessionButton removeFromSuperview];
    } else {
        LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
        const CGRect buttonRect = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, [style maxHeightOfAnswerButton]);
        NSString *label = NSLocalizedString(@"CatalogSearchOpenAll", nil);
        self->startSessionButton = [[LayButton alloc]initWithFrame:buttonRect label:label font:[style getFont:NormalPreferredFont] andColor:[style getColor:ClearColor]];
        self->startSessionButton.backgroundColor = [style getColor:WhiteTransparentBackground];
        [self->startSessionButton addTarget:self action:@selector(startSessionWithSearchResults) forControlEvents:UIControlEventTouchUpInside];
        [startSessionButton fitToContent];
        const CGFloat yPosButton = self.tableView.frame.origin.y + self.tableView.frame.size.height - startSessionButton.frame.size.height - 15.0f;
        const CGFloat xPosButton = (self.tableView.frame.size.width - startSessionButton.frame.size.width) / 2.0;
        [LayFrame setPos:CGPointMake(xPosButton, yPosButton) toView:startSessionButton];
    }
    
    if(self->searchResultsFetchedController) {
        NSArray *searchResultList = [self->searchResultsFetchedController fetchedObjects];
        if([searchResultList count] > 1) {
            [self.tableView addSubview:startSessionButton];
        }
    }
}

-(void)startSessionWithSearchResults {
    if(self->searchDisplayController.searchBar.selectedScopeButtonIndex == LAY_SEARCH_QUESTION_OBJ) {
        LayVcQuestion *vcQuestion = [LayVcQuestion new];
        LayCatalogManager* catalogMgr = [LayCatalogManager instance];
        catalogMgr.selectedQuestions = [[self->searchResultsFetchedController fetchedObjects] copy];
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:vcQuestion];
        [navController setNavigationBarHidden:YES animated:NO];
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
        [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        LayVcExplanation *vcExplanation = [LayVcExplanation new];
        LayCatalogManager* catalogMgr = [LayCatalogManager instance];
        catalogMgr.selectedExplanations = [[self->searchResultsFetchedController fetchedObjects] copy];
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:vcExplanation];
        [navController setNavigationBarHidden:YES animated:NO];
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
        [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 0;
    if( self->searchResultsFetchedController ) {
        numberOfSections = 1;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if( self->searchResultsFetchedController ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self->searchResultsFetchedController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LayAbstractCell *abstractCell = [[LayAbstractCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if(self->searchResultsFetchedController ) {
        NSManagedObject *managedObject = [self->searchResultsFetchedController objectAtIndexPath:indexPath];
        if([managedObject isKindOfClass:[Question class]]) {
          abstractCell.question = (Question*)managedObject;
        } else {
            abstractCell.explanation = (Explanation*)managedObject;
        }
    }
    
    return abstractCell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0.0f;
    if(self->searchResultsFetchedController ) {
        NSManagedObject *managedObject = [self->searchResultsFetchedController objectAtIndexPath:indexPath];
        if([managedObject isKindOfClass:[Question class]]) {
            cellHeight = [LayAbstractCell heightForQuestion:(Question*)managedObject];
        } else {
            cellHeight = [LayAbstractCell heightForExplanation:(Explanation*)managedObject];
        }
    }
    return cellHeight;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    if(self->searchResultsFetchedController ) {
        NSManagedObject *managedObject = [self->searchResultsFetchedController objectAtIndexPath:indexPath];
        if([managedObject isKindOfClass:[Question class]]) {
            Question *question = (Question*)managedObject;
            [self startQueryMode:question];
        } else {
            Explanation *explanation = (Explanation*)managedObject;
            [self startLearnMode:explanation];
        }
    }
}

#pragma mark UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self setupSearchFetchController:controller forSearchString:searchString];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    UISearchBar *searchBar = controller.searchBar;
    NSString *searchString = searchBar.text;
    [self setupSearchFetchController:controller forSearchString:searchString];
    [self addStartSessionButton];
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self->searchResultsFetchedController = nil;
    [self.tableView reloadData];
}


#pragma mark UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    searchBar.text = @"";
    self->searchResultsFetchedController = nil;
    [self.tableView reloadData];
    //
    if(self->startSessionButton) {
        [self->startSessionButton removeFromSuperview];
        self->startSessionButton = nil;
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //UISearchDisplayController *searchDisplayController_ = self.searchDisplayController;
    //[searchDisplayController_ setActive:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText length] == 0) {
        self->searchResultsFetchedController = nil;
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self addStartSessionButton];
}

#pragma mark LayVcNavigationBarDelegate

-(void) cancelPressed {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Predicates and ResultController

- (NSFetchedResultsController *)fetchedResultsControllerForSearchObject:(LaySearchObject)searchObj andSearchWordList:(NSArray*)searchWordist {
    NSFetchedResultsController *fetchResultController = nil;
    //
    if( [searchWordist count] > 0) {
        
        NSMutableArray *searchWordPredicateList = [NSMutableArray arrayWithCapacity:[searchWordist count]];
        NSString *searchWordPredicateFormat = @"SUBQUERY(searchWordRelationRef, $wordRelation, $wordRelation.searchWordRef.word like[c] %@).@count > 0";
        for (NSString* searchWord in searchWordist) {
            NSString* searchWordToUse = [searchWord stringByFoldingWithOptions:kCFCompareCaseInsensitive|kCFCompareDiacriticInsensitive locale:[NSLocale systemLocale]];
            NSString *wildcardedString = [NSString stringWithFormat:@"%@*", searchWordToUse];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:searchWordPredicateFormat, wildcardedString];
            [searchWordPredicateList addObject:predicate];
        }
        NSPredicate *searchWordRelationPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:searchWordPredicateList];
        Catalog *currentSelectedCatalog = [LayCatalogManager instance].currentSelectedCatalog;
        NSPredicate *searchCatalogPredicate = [NSPredicate predicateWithFormat:@"catalogRef = %@", currentSelectedCatalog];
        NSPredicate *finalSearchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[searchCatalogPredicate, searchWordRelationPredicate]];
        NSString *entityToSearch = @"Question";
        if(searchObj == LAY_SEARCH_EXPLANATION_OBJ) {
            entityToSearch = @"Explanation";
        }
        //
        LayMainDataStore *mainStore = [LayMainDataStore store];
        NSManagedObjectContext *managedObjectContext = [mainStore managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:entityToSearch inManagedObjectContext:managedObjectContext]];
        [request setPredicate:finalSearchPredicate];
        NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:numberSortDescriptor, nil]];
        
        fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        NSError *error = nil;
        BOOL success = [fetchResultController performFetch:&error];
        if( !success ) {
            MWLogError(g_classObj, @"Could not search within %@! Details:%@", entityToSearch, [error description]);
            fetchResultController = nil;
        }
    }
    return fetchResultController;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
