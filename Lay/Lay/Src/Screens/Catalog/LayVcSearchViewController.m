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
    [self->navigationItemCfg showTitle:@"Search" atPosition:TITLE_CENTER];
    self->navigationItemCfg.cancelButtonInNavigationBar = YES;
    [self->navigationItemCfg showButtonsInNavigationBar];
    // UISearchBar
    UINavigationBar* navBar = self.navigationController.navigationBar;
    const CGRect navBarRect = CGRectMake(0.0f, 0.0f, navBar.frame.size.width, navBar.frame.size.height);
    UISearchBar* searchBar = [[UISearchBar alloc]initWithFrame:navBarRect];
    searchBar.placeholder = @"search catalog ...";
    //LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    //searchBar.barTintColor = [styleGuide getColor:ToolBarBackground];
    //searchBar.tintColor = [styleGuide getColor:ButtonSelectedColor];
    searchBar.showsCancelButton = YES;
    searchBar.scopeButtonTitles = @[@"Questions", @"Explanations"];
    searchBar.selectedScopeButtonIndex = LAY_SEARCH_QUESTION_OBJ;
    searchBar.delegate = self;
    // UISearchController
    self->searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
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
    //catalogDetails.alpha = 0.7f;
    catalogDetails.showDetailTable = NO;
    [self.tableView setBackgroundView:catalogDetails];
}

-(void) hideCatalogInfoAsBackground {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(self->searchResultsFetchedController ) {
        Question *question = [self->searchResultsFetchedController objectAtIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSPredicate *searchWordPredicate = [self predicateForSearchString:searchString];
    NSArray *searchWordRelationList = [self resultListOfSearchWordRelationsWithPredicate:searchWordPredicate];
    self->searchResultsFetchedController = [self fetchedResultsControllerForSearchObject:LAY_SEARCH_QUESTION_OBJ andSearchWordRelationList:searchWordRelationList];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self->searchResultsFetchedController = nil;
}


#pragma mark UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    searchBar.text = @"";
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //UISearchDisplayController *searchDisplayController_ = self.searchDisplayController;
    //[searchDisplayController_ setActive:YES animated:YES];
}

#pragma mark LayVcNavigationBarDelegate

-(void) cancelPressed {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Predicates and ResultController

- (NSPredicate *)predicateForSearchString:(NSString *)searchString {
    searchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *stringComponents = [searchString componentsSeparatedByString:@" "];
    // TODO: That results in a question search first!! Would it be better to search for words at first?
    NSString *predicateFormat = @"searchWordRef.word CONTAINS[c] %@";
    NSPredicate *predicate = nil;
    if( [stringComponents count] > 1 )
        predicate = [self predicateForSearchComponents:stringComponents withFormat:predicateFormat];
    else
        predicate = [NSPredicate predicateWithFormat:predicateFormat, searchString];
    
    return predicate;
}

- (NSPredicate *)predicateForSearchComponents:(NSArray *)stringComponents withFormat:(NSString*)format {
    if( [stringComponents count] < 1 ) return nil;
    
    NSMutableArray *wordMatchPredicateList = [NSMutableArray arrayWithCapacity:[stringComponents count]];
    for (NSString* searchWord in stringComponents) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:format, searchWord];
        [wordMatchPredicateList addObject:predicate];
    }

    NSPredicate *searchWordPredicateList = [NSCompoundPredicate andPredicateWithSubpredicates:wordMatchPredicateList];
    return searchWordPredicateList;
}

-(NSArray*)resultListOfSearchWordRelationsWithPredicate:(NSPredicate*)searchWordsPredicate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    LayMainDataStore *mainStore = [LayMainDataStore store];
    NSManagedObjectContext *managedObjectContext = [mainStore managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchWordRelation"
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    //
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    NSString *catalogURI = [[[catalog objectID] URIRepresentation] path];
    NSPredicate *predicateLimitsToCatalog = [NSPredicate predicateWithFormat:@"catalogURI = %@", catalogURI];
    NSPredicate *finalSearchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateLimitsToCatalog, searchWordsPredicate]];
    [fetchRequest setPredicate:finalSearchPredicate];
    NSError *error;
    NSArray *searchWordRelationist = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (searchWordRelationist == nil) {
        MWLogError(g_classObj, @"Failure getting all SearchWordRelations:%@ in ", [error description]);
    }
    return searchWordRelationist;
}

- (NSFetchedResultsController *)fetchedResultsControllerForSearchObject:(LaySearchObject)searchObj andSearchWordRelationList:(NSArray*)searchWordRelationist {
    //
    NSMutableArray *searchWordRelationPredicateList = [NSMutableArray arrayWithCapacity:[searchWordRelationist count]];
    for (SearchWordRelation* searchWordRelation in searchWordRelationist) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchWordRelationRef = %@", searchWordRelation];
        [searchWordRelationPredicateList addObject:predicate];
    }
    NSPredicate *searchWordRelationPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:searchWordRelationPredicateList];
    //
    LayMainDataStore *mainStore = [LayMainDataStore store];
    NSManagedObjectContext *managedObjectContext = [mainStore managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:managedObjectContext]];
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    NSPredicate *predicateLimitToCatalog = [NSPredicate predicateWithFormat:@"catalogRef = %@", catalog];
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateLimitToCatalog,searchWordRelationPredicate]];
    [request setPredicate:finalPredicate];
    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:numberSortDescriptor, nil]];
    
    NSFetchedResultsController *fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];

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
