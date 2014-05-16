//
//  LayViewController.m
//  Lay
//
//  Created by Rene on 29.10.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcMyCatalogList.h"
#import "LayMainDataStore.h"
#import "LayMyCatalogListItem.h"
#import "LayVcCatalogList.h"
#import "LayVcNavigationBar.h"
#import "LayImage.h"
#import "LayVBoxLayout.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayTableSectionView.h"
#import "LayAppNotifications.h"
#import "LayImportStateViewHandler.h"
#import "LayHintView.h"
#import "LayVcNavigation.h"
#import "LayVcSettings.h"
#import "LayVcCatalogStoreList.h"

#import "LayCatalogManager.h"
#import "Catalog+Utilities.h"
#import "MWLogging.h"


@interface LayVcMyCatalogList () {
    LayTableSectionView* sectionMyCatalog;
    LayImportStateViewHandler *stateViewHandler;
    LayVcNavigationBar* navBarViewController;
    Catalog *catalogToDelete;
    NSIndexPath *indexPathToDelete;
    NSMutableArray* allCatalogs;
    UILabel *noCatalogsLoadedLabel;
}

@end


@implementation LayVcMyCatalogList


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    
    self = [super initWithNibName:@"LayVcMyCatalogList"
                           bundle:nil];
    if (self) {
        self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
        self->navBarViewController.delegate = self;
        self->navBarViewController.addButtonInNavigationBar = YES;
        self->navBarViewController.infoButtonInNavigationBar = YES;
        [self registerEvents];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    [self->navBarViewController showButtonsInNavigationBar];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIFont *appTitleFont = [styleGuide getFont:AppTitleFont];
    UIColor *appNameColor = [styleGuide getColor:TextColor];
    [self->navBarViewController showTitle:@"KEEMI" atPosition:TITLE_CENTER withFont:appTitleFont andColor:appNameColor];
    //
    NSString *sectionMyCatalogsTitle = NSLocalizedString(@"MyCatalogs", nil);
    self->sectionMyCatalog = [self sectionLabelWithTitle:sectionMyCatalogsTitle];
    self.tableView.tableHeaderView = self->sectionMyCatalog;
    //
    self.tableView.backgroundColor = [styleGuide getColor:BackgroundColor];
    //
    UINib* cellXibFile = [UINib nibWithNibName:@"LayMyCatalogListItem" bundle:nil];
    [self.tableView registerNib:cellXibFile forCellReuseIdentifier:@"CatalogListItemIdentifier"];
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat width = self.tableView.frame.size.width - 2 * hSpace;
    const CGRect labelRect = CGRectMake(0.0f, 0.0f, width, 0.0f);
    self->noCatalogsLoadedLabel = [[UILabel alloc]initWithFrame:labelRect];
    noCatalogsLoadedLabel.textColor = [UIColor lightGrayColor];
    noCatalogsLoadedLabel.text = NSLocalizedString(@"MyCatalogsNoCatalogsStored", nil);
    [self.tableView setBackgroundView:noCatalogsLoadedLabel];
    [self adjustNoCatalogsStoredLabel];
    // Sime informations about the table are requested before: viewWillAppear
    NSArray *catalogsInStore = [[LayMainDataStore store] findAllCatalogsOrderedByDateLastImportedFirst];
    self->allCatalogs = [NSMutableArray arrayWithArray:catalogsInStore];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    if(catalogManager.currentCatalogShouldBeOpenedDirectly) {
        catalogManager.currentCatalogShouldBeOpenedDirectly = NO;
        LayVcCatalogList *vcCatalog = [LayVcCatalogList new];
        // Push it onto the top of the navigation controller's stack
        [[self navigationController] pushViewController:vcCatalog
                                               animated:NO];
    } else if(catalogManager.pendingCatalogToImport) {
        catalogManager.pendingCatalogToImport = NO;
        NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_DO_IMPORT_CATALOG object:self];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    } else {
        [catalogManager resetAllProperties];
        NSIndexPath *pathToSelectedRow = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:pathToSelectedRow animated:NO];
        [self.tableView reloadData];
    }
    
    self->catalogToDelete = nil;
    self->indexPathToDelete = nil;
    
    NSArray *catalogsInStore = [[LayMainDataStore store] findAllCatalogsOrderedByDateLastImportedFirst];
    self->allCatalogs = [NSMutableArray arrayWithArray:catalogsInStore];
    if([self->allCatalogs count] == 0) {
        self->noCatalogsLoadedLabel.hidden = NO;
    }
    [self adjustNoCatalogsStoredLabel];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)adjustNoCatalogsStoredLabel {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat width = self.tableView.frame.size.width - 2 * hSpace;
    [LayFrame setWidthWith:width toView:self->noCatalogsLoadedLabel];
    self->noCatalogsLoadedLabel.textColor = [UIColor lightGrayColor];
    self->noCatalogsLoadedLabel.textAlignment = NSTextAlignmentCenter;
    self->noCatalogsLoadedLabel.font = [styleGuide getFont:NormalPreferredFont];
    noCatalogsLoadedLabel.text = NSLocalizedString(@"CatalogNoCatalogsStored", nil);;
    [noCatalogsLoadedLabel sizeToFit];
    self->noCatalogsLoadedLabel.center = self.tableView.center;
    if([self->allCatalogs count] == 0) {
        self->noCatalogsLoadedLabel.hidden = NO;
    } else {
        self->noCatalogsLoadedLabel.hidden = YES;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create an instance of UITableViewCell, with default appearance
    // Check for a reusable cell first, use that if it exists
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"CatalogListItemIdentifier"];
    
    // If there is no reusable cell of this type, create a new one
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"CatalogListItemIdentifier"];
    }

    LayMyCatalogListItem *column = (LayMyCatalogListItem *)cell;
    Catalog *catalog = [self->allCatalogs objectAtIndex:[indexPath section]];
    NSString *numberOfQuestionsFormat = NSLocalizedString(@"CatalogNumberOfQuestionsLabel", nil);
    NSString *numberOfQuestions = [NSString stringWithFormat:numberOfQuestionsFormat, [catalog numberOfQuestions]];
    [column setCover:catalog.coverRef title:catalog.title publisher:[catalog publisher] andNumberOfQuestions:numberOfQuestions];
    
    return cell;
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        Catalog *catalog = [self->allCatalogs objectAtIndex:[indexPath section]];
        if(catalog) {
            [self setupCatalogToDelete:catalog atIndexPath:indexPath];
        } else {
            MWLogError([LayVcMyCatalogList class], @"Could not get a catalog at index:%u", [indexPath section]);
        }
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Catalog *catalog = [self->allCatalogs objectAtIndex:[indexPath section]];
    [LayCatalogManager instance].currentSelectedCatalog = catalog;
    LayVcCatalogList *vcCatalog = [LayVcCatalogList new];
    // Push it onto the top of the navigation controller's stack
    [[self navigationController] pushViewController:vcCatalog
                                           animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     NSInteger numberOfCatalogs = [self->allCatalogs count];
     return numberOfCatalogs;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfCatalogsInSection = 1;
    return numberOfCatalogsInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat heightOfSection = 25.0f;
    if(section == 0) {
        heightOfSection = 0.0f;
    }
    return heightOfSection;
}

-(LayTableSectionView*) sectionLabelWithTitle:(NSString*)title {
    LayTableSectionView *sectionView = [[LayTableSectionView alloc]initWithTitle:title andBorderColor:NoColor];
    return sectionView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

//
-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
}

-(void)handlePreferredFontSizeChanges {
    [self->sectionMyCatalog adjustToNewPreferredFont];
    [self adjustNoCatalogsStoredLabel];
}

-(void)handleWantToImportCatalogNotification {
    if(self.navigationController.topViewController == self) {
        LayCatalogManager *catalogManager = [LayCatalogManager instance];
        if(catalogManager.pendingCatalogToImport) {
            if(self->stateViewHandler && self->stateViewHandler.busy) {
                [LayCatalogManager instance].pendingCatalogToImport = NO;
                NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_IGNORE_IMPORT_CATALOG__ANOTHER_IS_STILL_IN_PROGRESS object:self];
                [[NSNotificationCenter defaultCenter] postNotification:note];
                NSString *text = NSLocalizedString(@"ImportStillATaskInProgress", nil);
                [self showHint:text withTarget:nil andAction:nil state:NO andDuration:4.0f];
            } else {
                catalogManager.pendingCatalogToImport = NO;
                NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_DO_IMPORT_CATALOG object:self];
                [[NSNotificationCenter defaultCenter] postNotification:note];
            }
        }
    }
}

//
-(void)setupCatalogToDelete:(Catalog*)catalog atIndexPath:(NSIndexPath *)indexPath {
    NSString *text = NSLocalizedString(@"ImportDeleteCatalogState", nil);
    UIImage *image = [LayImage imageWithId:LAY_IMAGE_IMPORT];
    self->stateViewHandler = [[LayImportStateViewHandler alloc]initWithSuperView:self.tableView.window icon:image andText:text];
    self->stateViewHandler.delegate = self;
    self->stateViewHandler.useTimerForSteps = YES;
    self->catalogToDelete = catalog;
    self->indexPathToDelete = indexPath;
    [self->stateViewHandler startWork];
}

-(void)deleteCatalogFromtableAnimated {
    [self->allCatalogs removeObjectAtIndex:[self->indexPathToDelete section]];
    //NSArray *rowsToDelete = [NSArray arrayWithObjects:self->indexPathToDelete, nil];
    //[self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationTop];
    NSIndexSet *sectionToDelete = [NSIndexSet indexSetWithIndex:[self->indexPathToDelete section]];
    [self.tableView deleteSections:sectionToDelete withRowAnimation:UITableViewRowAnimationTop];
    //[self.tableView reloadData];
    [self adjustNoCatalogsStoredLabel];
}

//
// LayVcNavigationBarDelegate
//
-(void) addPressed {
    LayVcCatalogStoreList *catalogStore = [[LayVcCatalogStoreList alloc]init];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:catalogStore];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void) infoPressed {
    LayVcSettings *settings = [[LayVcSettings alloc]init];
    LayVcNavigation *navController = [[LayVcNavigation alloc] initWithRootViewController:settings];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}
//
// LayImportStateViewHandlerDelegate
//
-(NSString*)startWork:(id<LayImportProgressDelegate>)progressDelegate {
    NSString *errorMessage = nil;
    NSString *titleOfCatalog = self->catalogToDelete.title;
    NSString *publisherOfCatalog = [self->catalogToDelete publisher];
    MWLogInfo([LayVcMyCatalogList class], @"Delete catalog with title:%@, publisher:%@ .", titleOfCatalog, publisherOfCatalog);
    const NSUInteger maxSteps = [self->catalogToDelete numberOfQuestions] + [self->catalogToDelete numberOfExplanations];
    [progressDelegate setMaxSteps:maxSteps];
    Catalog *catalog = [[LayMainDataStore store] findCatalogByTitle:titleOfCatalog andPublisher:publisherOfCatalog];
    if(catalog) {
        BOOL deletedCatalog = [LayMainDataStore deleteCatalogWithinNewCreatedContext:catalog];
        if(!deletedCatalog) {
             MWLogError( [LayVcMyCatalogList class], @"Could not delete catalog:(%@, %@)!", titleOfCatalog, publisherOfCatalog);
            self->catalogToDelete = nil;
            self->indexPathToDelete = nil;
        }
    } else {
        MWLogError( [LayVcMyCatalogList class], @"Could not find catalog:(%@, %@) for deletion!", titleOfCatalog, publisherOfCatalog);
    }
    
    //TODO: What should happen if a catalog could not be deleted?
    
    return errorMessage;
}

-(void)buttonPressed {
    
}

-(void)closedStateView {
    if(self->catalogToDelete && self->indexPathToDelete) {
        [self deleteCatalogFromtableAnimated];
    }
}

//
//
//
-(void) showHint:(NSString*)hint withTarget:(id)target andAction:(SEL)action state:(BOOL)state andDuration:(CGFloat)duration {
    const CGRect viewFrame = [[UIScreen mainScreen] bounds];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    LayStyleGuideColor color = AnswerCorrect;
    if(!state) {
        color = AnswerWrong;
    }
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat width = viewFrame.size.width-2*hSpace;
    LayHintView *hintView = [[LayHintView alloc]initWithWidth:width view:self.view target:target andAction:action];
    hintView.duration = duration;
    [hintView showHint:hint withBorderColor:color];
}


@end
