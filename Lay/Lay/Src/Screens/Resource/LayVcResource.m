//
//  LayVcCatalogDetail.m
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcResource.h"
#import "LayVcNavigationBar.h"
#import "LayStyleGuide.h"
#import "LayCatalogDetails.h"
#import "LayTableSectionView.h"
#import "LayButton.h"
#import "LayResourceType.h"
#import "LayVBoxLayout.h"
#import "LayFrame.h"
#import "LayImage.h"
#import "LAyMediaData.h"
#import "LayInfoDialog.h"
#import "LayUserDataStore.h"
#import "LayCatalogManager.h"
#import "LayAppNotifications.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Explanation+Utilities.h"
#import "Resource+Utilities.h"

#import "UGCCatalog+Utilities.h"
#import "UGCResource+Utilities.h"
#import "UGCExplanation+Utilities.h"
#import "UGCQuestion+Utilities.h"

#import "MWLogging.h"

static const NSUInteger TAG_TEXT_FIELD_TITLE = 1001;
static const NSUInteger TAG_TEXT_FIELD_LINK = 1002;
static const NSUInteger TAG_STATUS_LABEL = 1003;
static const NSUInteger TAG_SAVE_BUTTON = 1004;

static const NSInteger SECTION_WEB = 0;
static const NSInteger SECTION_FILE = 1;
static const NSInteger SECTION_BOOK = 2;

@interface LayVcResource () {
    LayVcNavigationBar* navBarViewController;
    UIView *addResourceDialog;
    Catalog *catalogParam;
    Question *questionParam;
    Explanation *explanationParam;
    NSMutableArray *resourceListWeb;
    NSMutableArray *resourceListFile;
    NSMutableArray *resourceListBook;
    LayTableSectionView *sectionViewWeb;
    LayTableSectionView *sectionViewFile;
    LayTableSectionView *sectionViewBook;
    LayButton *addWebResource;
    LayButton *addFileResource;
    LayButton *addBookResource;
    BOOL titleTextFieldDefaultValueSwitch;
    BOOL linkTextFieldDefaultValueSwitch;
}

@end

//
// LayVcResource
//

static Class g_classObj = nil;

@implementation LayVcResource

+(void)initialize {
    g_classObj = [LayVcResource class];
}

-(id)initWithCatalog:(Catalog*)catalog_ {
    self = [self initWithNibName:nil bundle:nil];
    if(self) {
        self->catalogParam = catalog_;
        [self separateResourceList:[catalog_ resourceList]];
    }
    return self;
}

-(id)initWithExplanation:(Explanation*)explanation {
    self = [self initWithNibName:nil bundle:nil];
    if(self) {
        self->explanationParam = explanation;
        self->catalogParam = explanation.catalogRef;
        [self separateResourceList:[explanation resourceList]];
    }
    return self;
}

-(id)initWithQuestion:(Question*)question {
    self = [self initWithNibName:nil bundle:nil];
    if(self) {
        self->questionParam = question;
        self->catalogParam = question.catalogRef;
        [self separateResourceList:[question resourceList]];
    }
    return self;
}


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        [self registerEvents];
    }
    return self;
}

-(void)loadView {
    const CGRect initialTableFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    UITableView *tableView = [[UITableView alloc]initWithFrame:initialTableFrame style:UITableViewStylePlain];
    tableView.separatorColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.view = tableView;
}

-(void)dealloc {
    MWLogDebug([LayVcResource class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    self->navBarViewController.delegate = nil;
}


-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
	[nc addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navBarViewController.cancelButtonInNavigationBar = YES;
    [self->navBarViewController showButtonsInNavigationBar];
    NSString *title = NSLocalizedString(@"CatalogResources", nil);
    [self->navBarViewController showTitle:title  atPosition:TITLE_CENTER];
     self->navBarViewController.delegate = self;
    //
    [self setupTableHeader];
    [self setupSectionViews];
    [self setupAddButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    if(catalogManager.pendingCatalogToImport) {
        UINavigationController *navController = self.navigationController;
        [navController popToRootViewControllerAnimated:NO];
    }
    NSIndexPath *pathToSelectedRow = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:pathToSelectedRow animated:NO];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self saveUpdatedResource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupTableHeader {
    if(self.tableView.tableHeaderView) {
        [self.tableView.tableHeaderView removeFromSuperview];
    }
    if(self->catalogParam && (!self->questionParam && !self->explanationParam)) {
        LayCatalogDetails *catalogDetailView = [[LayCatalogDetails alloc]initWithCatalog:self->catalogParam andPositionY:10.0f];
        catalogDetailView.showDetailTable = NO;
        self.tableView.tableHeaderView = catalogDetailView;
    } else {
        const CGRect screenFrame = [[UIScreen mainScreen] bounds];
        const CGFloat width = screenFrame.size.width;
        const CGFloat vSpace = 15.0f;
        const CGRect headerRect = CGRectMake(0.0f, 0.0f, width, 0.0f);
        UIView *header = [[UIView alloc]initWithFrame:headerRect];
        header.backgroundColor = [UIColor clearColor];
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
        const CGRect titleRect = CGRectMake(hSpace, vSpace, width-2*hSpace, 0.0f);
        UILabel *title = [[UILabel alloc]initWithFrame:titleRect];
        title.font = [styleGuide getFont:NormalPreferredFont];
        title.numberOfLines = [styleGuide numberOfLines];
        title.textColor = [styleGuide getColor:TextColor];
        title.backgroundColor = [UIColor clearColor];
        title.textAlignment = NSTextAlignmentLeft;
        NSString *text = nil;
        if(self->questionParam) {
            text = self->questionParam.question;
        } else if(explanationParam) {
            text = self->explanationParam.title;
        } else {
            MWLogError([LayVcResource class], @"Invalid object initialization!");
        }
        title.text = text;
        [title sizeToFit];

        CGFloat newHeaderHeight = vSpace + title.frame.size.height + 2*vSpace;
        if(self->questionParam) {
            UIView *questionTitleContainer = [self questionView:self->questionParam withWidth:width];
            if(questionTitleContainer) {
                [LayFrame setYPos:vSpace toView:questionTitleContainer];
                const CGFloat yPosTitle = vSpace + questionTitleContainer.frame.size.height + vSpace;
                [LayFrame setYPos:yPosTitle toView:title];
                [header addSubview:questionTitleContainer];
                newHeaderHeight += questionTitleContainer.frame.size.height + vSpace;
            }
            
        }
        
        [LayFrame setHeightWith:newHeaderHeight toView:header animated:NO];
        [header addSubview:title];
        self.tableView.tableHeaderView = header;
    }
}

static const NSUInteger TAG_QUESTION_TITLE = 105;
-(UIView*)questionView:(Question*)question withWidth:(CGFloat)width {
    UIView *titleContainer = nil;
    if(question.title) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        UIFont *smallFont = [styleGuide getFont:TitlePreferredFont];
        UIColor *textColor = [styleGuide getColor:TextColor];
        const CGFloat indent = 10.0f;
        CGFloat horizontalBorderOfView = [styleGuide getHorizontalScreenSpace];
        const CGFloat titleContainerWidth = width -  2*horizontalBorderOfView;
        const CGRect titleContainerFrame = CGRectMake(horizontalBorderOfView, 0.0f, titleContainerWidth, 0.0f);
        titleContainer = [[UIView alloc]initWithFrame:titleContainerFrame];
        titleContainer.tag = TAG_QUESTION_TITLE;
        //
        const CGFloat titleWith = titleContainerWidth - 2 * horizontalBorderOfView - 2 * indent;
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(indent, indent, titleWith, 0.0f)];
        title.textColor = textColor;
        title.backgroundColor = [UIColor clearColor];
        title.font = smallFont;
        title.text = [NSString stringWithFormat:@"%@", question.title];
        title.numberOfLines = [styleGuide numberOfLines];
        [title sizeToFit];
        const CGFloat heightTitleContainer = title.frame.size.height + 2 * indent;
        [LayFrame setHeightWith:heightTitleContainer toView:titleContainer animated:NO];
        [titleContainer addSubview:title];
        [styleGuide makeRoundedBorder:titleContainer withBackgroundColor:GrayTransparentBackground andBorderColor:ClearColor];
    }
    return titleContainer;
}

-(void)setupSectionViews {
    NSString *sectionTitle = NSLocalizedString(@"ResourceWebLink", nil);
    self->sectionViewWeb = [[LayTableSectionView alloc]initWithTitle:sectionTitle andBorderColor:ButtonBorderColor];
    sectionTitle = NSLocalizedString(@"ResourceFileLink", nil);
    self->sectionViewFile = [[LayTableSectionView alloc]initWithTitle:sectionTitle andBorderColor:ButtonBorderColor];
    sectionTitle = NSLocalizedString(@"ResourceBookLink", nil);
    self->sectionViewBook = [[LayTableSectionView alloc]initWithTitle:sectionTitle andBorderColor:ButtonBorderColor];
}

-(void)setupAddButtons {
    CGFloat screenWidth = [[UIApplication sharedApplication] statusBarFrame].size.width;
    NSString *buttonTitle = NSLocalizedString(@"WebAddLinkButtonTitle", nil);
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIImage *plusIcon = [LayImage imageWithId:LAY_IMAGE_ADD];
    LayMediaData *mediaData = [LayMediaData byUIImage:plusIcon];
    const CGFloat buttonHeight = [styleGuide getDefaultButtonHeight];
    const CGRect initialButtonRect = CGRectMake(0.0f, 0.0f, screenWidth, buttonHeight);
    self->addWebResource = [[LayButton alloc]initWithFrame:initialButtonRect label:buttonTitle mediaData:mediaData font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:WhiteTransparentBackground]];
    self->addWebResource.topBottomLayer = YES;
    [self->addWebResource fitToHeight];
    [self->addWebResource hiddeBorders:YES];
    [self->addWebResource addTarget:self action:@selector(addWebLink:) forControlEvents:UIControlEventTouchUpInside];
    
    buttonTitle = NSLocalizedString(@"FileAddLinkButtonTitle", nil);
    self->addFileResource = [[LayButton alloc]initWithFrame:initialButtonRect label:buttonTitle mediaData:mediaData font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:WhiteTransparentBackground]];
    
    self->addFileResource.topBottomLayer = YES;
    [self->addFileResource fitToHeight];
    [self->addFileResource hiddeBorders:YES];
    [self->addFileResource addTarget:self action:@selector(addFileLink:) forControlEvents:UIControlEventTouchUpInside];
    
    buttonTitle = NSLocalizedString(@"BookAddLinkButtonTitle", nil);
    self->addBookResource = [[LayButton alloc]initWithFrame:initialButtonRect label:buttonTitle mediaData:mediaData font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:WhiteTransparentBackground]];
    self->addBookResource.topBottomLayer = YES;
    [self->addBookResource fitToHeight];
    [self->addBookResource hiddeBorders:YES];
    [self->addBookResource addTarget:self action:@selector(addBookLink:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setBackgroundColorForButtons];
}

-(void)setBackgroundColorForButtons {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->addWebResource.backgroundColor = [styleGuide getColor:WhiteTransparentBackground];
    self->addFileResource.backgroundColor = [styleGuide getColor:WhiteTransparentBackground];
    self->addBookResource.backgroundColor = [styleGuide getColor:WhiteTransparentBackground];
}

-(void)separateResourceList:(NSArray*)resourceList {
    self->resourceListWeb = [NSMutableArray arrayWithCapacity:15];
    self->resourceListFile = [NSMutableArray arrayWithCapacity:15];
    self->resourceListBook = [NSMutableArray arrayWithCapacity:15];
    for (Resource* resource in resourceList) {
        LayResourceTypeIdentifier resourceType = [resource resourceType];
        if(resourceType == RESOURCE_TYPE_WEB) {
            [self->resourceListWeb addObject:resource];
        } else if(resourceType == RESOURCE_TYPE_FILE) {
            [self->resourceListFile addObject:resource];
        } else if(resourceType == RESOURCE_TYPE_BOOK) {
             [self->resourceListBook addObject:resource];
        }
    }
}

-(Resource*)resourceForIndexPath:(NSIndexPath*)indexPath {
    Resource* resource = nil;
    const NSInteger section = [indexPath section];
    const NSInteger index = [indexPath row];
    if(SECTION_WEB==section) {
        resource = [self->resourceListWeb objectAtIndex:index];
    } else if(SECTION_FILE==section) {
        resource = [self->resourceListFile objectAtIndex:index];
    } else if(SECTION_BOOK==section) {
        resource = [self->resourceListBook objectAtIndex:index];
    }
    return resource;
}

-(void)addNewResource:(NSString*)title link:(NSString*)link ofType:(LayResourceTypeIdentifier)resourceType {    
    UGCResource *resource = [self saveEditedResource:title link:link context:self->catalogParam andType:resourceType];
    if(resource) {
        NSInteger lastRowInSection = 0;
        NSInteger section = 0;
        if(resourceType == RESOURCE_TYPE_WEB) {
            lastRowInSection = [self->resourceListWeb count];
            section = SECTION_WEB;
            [self->resourceListWeb addObject:resource];
        } else if(resourceType == RESOURCE_TYPE_FILE) {
            lastRowInSection = [self->resourceListFile count];
            section = SECTION_FILE;
            [self->resourceListFile addObject:resource];
        } else if(resourceType == RESOURCE_TYPE_BOOK) {
            lastRowInSection = [self->resourceListBook count];
            section = SECTION_BOOK;
            [self->resourceListBook addObject:resource];
        }
        // show resource
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowInSection inSection:section];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [self.tableView endUpdates];
    }
}

-(NSString*)titleForType:(LayResourceTypeIdentifier)resourceTypeId addMode:(BOOL)addMode {
    NSString *title = nil;
    if(resourceTypeId == RESOURCE_TYPE_WEB) {
        if(addMode) {
            title = NSLocalizedString(@"WebAddLinkButtonTitle", nil);
        } else {
            title = NSLocalizedString(@"WebEditLinkButtonTitle", nil);
        }
    } else if(resourceTypeId == RESOURCE_TYPE_FILE) {
        if(addMode) {
             title = NSLocalizedString(@"FileAddLinkButtonTitle", nil);
        } else {
             title = NSLocalizedString(@"FileEditLinkButtonTitle", nil);
        }
    } else if(resourceTypeId == RESOURCE_TYPE_BOOK) {
        if(addMode) {
            title = NSLocalizedString(@"BookAddLinkButtonTitle", nil);
        } else {
            title = NSLocalizedString(@"BookEditLinkButtonTitle", nil);
        }
    }
    return title;
}

//
// UITableViewDelegate
//
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    LayResourceCell *resourceCell = (LayResourceCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self openLink:resourceCell.resource];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = nil;
    if(SECTION_WEB==section) {
        footerView = self->addWebResource;
    } else if(SECTION_FILE==section) {
        footerView = self->addFileResource;
    } else if(SECTION_BOOK==section) {
        footerView = self->addBookResource;
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0;
    if(SECTION_WEB==section) {
        height = self->addWebResource.frame.size.height;
    } else if(SECTION_FILE==section) {
        height = self->addFileResource.frame.size.height;
    } else if(SECTION_BOOK==section) {
        height = self->addBookResource.frame.size.height;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Resource* resource = [self resourceForIndexPath:indexPath];
    CGFloat cellHeight = [LayResourceCell heightForResource:resource];
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 0.0f;
    if(SECTION_WEB==section) {
        headerHeight = self->sectionViewWeb.frame.size.height;
    } else if(SECTION_FILE==section) {
        headerHeight = self->sectionViewFile.frame.size.height;
    } else if(SECTION_BOOK==section) {
        headerHeight = self->sectionViewBook.frame.size.height;
    }
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = nil;
    if(SECTION_WEB==section) {
        sectionView = self->sectionViewWeb;
    } else if(SECTION_FILE==section) {
        sectionView = self->sectionViewFile;
    } else if(SECTION_BOOK==section) {
        sectionView = self->sectionViewBook;
    }
    return sectionView;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL showMenu = NO;
    Resource* resource = [self resourceForIndexPath:indexPath];
    if(resource) {
        if([resource.questionRef count] > 0 || [resource.explanationRef count] > 0 ||
                    [resource isKindOfClass:[UGCResource class]]) {
            showMenu = YES;
        }
    }
    return showMenu;
}


// The two following methods must be implemented to get the menu right. So far the are never called!
-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    /*
    BOOL canPerformAction = NO;
    if(action == @selector(openRelatedQuestions:)){
        Resource* resource = [self resourceForIndexPath:indexPath];
        if([resource.questionRef count] > 0 ) {
            canPerformAction = YES;
        }
    } else if(action == @selector(openRelatedExplanations:)){
        Resource* resource = [self resourceForIndexPath:indexPath];
        if([resource.explanationRef count] > 0 ) {
            canPerformAction = YES;
        }
    }
    return canPerformAction;
     */
    return YES;
}


- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    /*
    if(action == @selector(openRelatedQuestions:)){
        
    } else if(action == @selector(openRelatedExplanations:)){
       
    };
     */
}


/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
 return [sectionInfo name];
 }*/


//
// UITableViewDataSource
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;/* weblibks, filelinks, book */
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    if(SECTION_WEB==section) {
        numberOfRowsInSection = [self->resourceListWeb count];
    } else if(SECTION_FILE==section) {
        numberOfRowsInSection = [self->resourceListFile count];
    } else if(SECTION_BOOK==section) {
        numberOfRowsInSection = [self->resourceListBook count];
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LayResourceCell *resourceCell = (LayResourceCell*)[tableView dequeueReusableCellWithIdentifier:(NSString*)resourceCellIdentifier];
    if(nil==resourceCell) {
        resourceCell = [[LayResourceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(NSString*)resourceCellIdentifier];
    }
    resourceCell.delegate = self;
    Resource* resource = [self resourceForIndexPath:indexPath];
    resourceCell.resource = resource;
    if(self->explanationParam || self->questionParam) {
        resourceCell.canOpenLinkedQuestionsOrExplanations = NO;
    } else {
        resourceCell.canOpenLinkedQuestionsOrExplanations = YES;
    }
    
    return resourceCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        LayResourceCell *resourceCell = (LayResourceCell *)[tableView cellForRowAtIndexPath:indexPath];
        if([resourceCell.resource isKindOfClass:[UGCResource class]]) {
            NSManagedObjectContext *context = [resourceCell.resource managedObjectContext];
            [context deleteObject:resourceCell.resource];
            NSInteger section = [indexPath section];
            NSInteger index = [indexPath row];
            if(SECTION_WEB==section) {
                [self->resourceListWeb removeObjectAtIndex:index];
            } else if(SECTION_FILE==section) {
                [self->resourceListFile removeObjectAtIndex:index];
            } else if(SECTION_BOOK==section) {
                [self->resourceListBook removeObjectAtIndex:index];
            }
            
            // Animated deletion crashes with:
            
            /*Assertion failure in -[UIViewAnimation initWithView:indexPath:endRect:endAlpha:startFraction:endFraction:curve:animateFromCurrentPosition:shouldDeleteAfterAnimation:editing:], /SourceCache/UIKit/UIKit-2903.2/UITableViewSupport.m:2661
             */
            
            //NSArray *rowsToDelete = [NSArray arrayWithObjects:indexPath, nil];
            //[tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationTop];
            [tableView reloadData];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // User generated resources can be deleted!
    BOOL editAble = NO;
    LayResourceCell *resourceCell = (LayResourceCell *)[tableView cellForRowAtIndexPath:indexPath];
    if([resourceCell.resource isKindOfClass:[UGCResource class]]) {
        editAble = YES;
    }
    return editAble;
}

//
// LayVcNavigationBarDelegate
//
-(void)cancelPressed {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

//
// Action handlers
//
-(void)openLink:(Resource*)resource {
    if([resource resourceType]==RESOURCE_TYPE_WEB) {
        [self openWebLink:resource];
    } else if([resource resourceType]==RESOURCE_TYPE_FILE) {
        [self openFileLink:resource];
    } else if([resource resourceType]==RESOURCE_TYPE_BOOK) {
        [self openBookLink:resource];
    }
}

-(void)openWebLink:(Resource*)resource {
    if(resource) {
        LayInfoDialog *infoDlg = [[LayInfoDialog alloc]initWithWindow:self.view.window];
        [infoDlg showResource:resource.title link:resource.link];
    }
}

-(void)openFileLink:(Resource*)resource {
    if(resource) {
        NSURL *link = [NSURL URLWithString:resource.link];
        if (![[UIApplication sharedApplication] openURL:link]) {
            MWLogError([LayVcResource class], @"Could not open link to:%@", [link description]);
        }
    }
}

-(void)openBookLink:(Resource*)resource {

}

-(void)editLink:(Resource*) resource {
    if([resource resourceType]==RESOURCE_TYPE_WEB) {
        [self setupResourceDialog:RESOURCE_TYPE_WEB withResource:resource];
        [self openResourceDialog:self->addResourceDialog];
    } else if([resource resourceType]==RESOURCE_TYPE_FILE) {
        [self setupResourceDialog:RESOURCE_TYPE_FILE withResource:resource];
        [self openResourceDialog:self->addResourceDialog];
    } else if([resource resourceType]==RESOURCE_TYPE_BOOK) {
        [self setupResourceDialog:RESOURCE_TYPE_BOOK withResource:resource];
        [self openResourceDialog:self->addResourceDialog];
    }
}

-(void)addWebLink:(UIButton*)button {
    [self setupResourceDialog:RESOURCE_TYPE_WEB withResource:nil];
    [self openResourceDialog:self->addResourceDialog];
}

-(void)addFileLink:(UIButton*)button {
    [self setupResourceDialog:RESOURCE_TYPE_FILE withResource:nil];
    [self openResourceDialog:self->addResourceDialog];
}

-(void)addBookLink:(UIButton*)button {
    [self setupResourceDialog:RESOURCE_TYPE_BOOK withResource:nil];
    [self openResourceDialog:self->addResourceDialog];
}

//
// add resource dialog
//

-(void)setupResourceDialog:(LayResourceTypeIdentifier)resourceTypeId_ withResource:(Resource*)resource {
    UIWindow *window = self.view.window;
    if(window) {
        if(resource) {
            titleTextFieldDefaultValueSwitch = YES;
            linkTextFieldDefaultValueSwitch = YES;
        } else {
            titleTextFieldDefaultValueSwitch = NO;
            linkTextFieldDefaultValueSwitch = NO;
        }
        const CGFloat width = window.frame.size.width;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        UIView *backgound = [[UIView alloc] initWithFrame:window.frame];
        backgound.backgroundColor = [[LayStyleGuide instanceOf:nil] getColor:InfoBackgroundColor];
        [window addSubview:backgound];
        self->addResourceDialog = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 0.0f)];
        self->addResourceDialog.tag = resourceTypeId_;
        self->addResourceDialog.backgroundColor = [styleGuide getColor:BackgroundColor];
        self->addResourceDialog.clipsToBounds = TRUE;
        // title
        const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
        const CGRect titleRect = CGRectMake(hSpace, 0.0f, width-2*hSpace, 0.0f);
        UILabel *title = [[UILabel alloc]initWithFrame:titleRect];
        title.font = [styleGuide getFont:NormalPreferredFont];
        title.numberOfLines = [styleGuide numberOfLines];
        title.textColor = [styleGuide getColor:TextColor];
        title.backgroundColor = [UIColor clearColor];
        title.text =  [self titleForType:resourceTypeId_ addMode:resource?NO:YES];
        [title sizeToFit];
        [self->addResourceDialog addSubview:title];
        // Textfields
        UIFont *textFieldFont = [styleGuide getFont:NormalPreferredFont];
        const CGFloat heightTextFields = textFieldFont.lineHeight * 2.0f;
        const CGRect textFieldRect = CGRectMake(hSpace, 0.0f, width-2*hSpace, heightTextFields);
        UITextField *titleTextField = [[UITextField alloc]initWithFrame:textFieldRect];
        [titleTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        titleTextField.tag = TAG_TEXT_FIELD_TITLE;
        titleTextField.delegate = self;
        titleTextField.layer.borderWidth = [styleGuide getBorderWidth:NormalBorder];
        titleTextField.layer.borderColor = [styleGuide getColor:ButtonBorderColor].CGColor;
        titleTextField.font = textFieldFont;
        titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //[styleGuide makeRoundedBorder:titleTextField withBackgroundColor:WhiteBackground andBorderColor:BorderColor];
        [self->addResourceDialog addSubview:titleTextField];
        UITextField *linkTextField = [[UITextField alloc]initWithFrame:textFieldRect];
        linkTextField.font = textFieldFont;
        [linkTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        linkTextField.tag = TAG_TEXT_FIELD_LINK;
        linkTextField.delegate = self;
        linkTextField.layer.borderWidth = [styleGuide getBorderWidth:NormalBorder];
        linkTextField.layer.borderColor = [styleGuide getColor:ButtonBorderColor].CGColor;
        linkTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //[styleGuide makeRoundedBorder:linkTextField withBackgroundColor:WhiteBackground andBorderColor:BorderColor];
        [self->addResourceDialog addSubview:linkTextField];
        // Buttons
        const CGFloat buttonHeight = [styleGuide getDefaultButtonHeight];
        const CGRect buttonContainerRect = CGRectMake(hSpace, 0.0f, width, buttonHeight);
        UIView *dialogButtonContainer = [[UIView alloc]initWithFrame:buttonContainerRect];
        UIFont *font = [styleGuide getFont:NormalPreferredFont];
        NSString *buttonLabel = NSLocalizedString(@"Save", nil);
        LayButton *buttonSave = [[LayButton alloc]initWithFrame:buttonContainerRect label:buttonLabel font:font andColor:[styleGuide getColor:WhiteTransparentBackground]];
        buttonSave.tag = TAG_SAVE_BUTTON;
        buttonSave.enabled = NO;
        buttonSave.resource = resource;
        [buttonSave addTarget:self action:@selector(saveEditedResource:) forControlEvents:UIControlEventTouchUpInside];
        [buttonSave fitToContent];
        buttonLabel = NSLocalizedString(@"Cancel", nil);
        LayButton *buttonCancel = [[LayButton alloc]initWithFrame:buttonContainerRect label:buttonLabel font:font andColor:[styleGuide getColor:WhiteTransparentBackground]];
        [buttonCancel addTarget:self action:@selector(cancelAddingResource) forControlEvents:UIControlEventTouchUpInside];
        [buttonCancel fitToContent];
        [dialogButtonContainer addSubview:buttonSave];
        [dialogButtonContainer addSubview:buttonCancel];
        [self layoutResourceDialogButtonContainer:dialogButtonContainer];
        [self->addResourceDialog addSubview:dialogButtonContainer];
        if(resource) {
            titleTextField.text = resource.title;
            linkTextField.text = resource.link;
        } else {
            [self showDefaultValueForTextField:titleTextField resourceType:resourceTypeId_ show:YES];
            [self showDefaultValueForTextField:linkTextField resourceType:resourceTypeId_ show:YES];
        }
        // status band
         const CGRect statusRect = CGRectMake(hSpace, 0.0f, width-2*hSpace, 0.0f);
        UILabel *statusLabel = [[UILabel alloc]initWithFrame:statusRect];
        statusLabel.tag = TAG_STATUS_LABEL;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.font = [styleGuide getFont:SmallFont];
        statusLabel.textColor = [styleGuide getColor:AnswerWrong];
        statusLabel.numberOfLines = 2;
        statusLabel.text = @"dummy";
        statusLabel.hidden = YES;
        [statusLabel sizeToFit];
        [self->addResourceDialog addSubview:statusLabel];
        //
        [backgound addSubview:self->addResourceDialog];
    }
}

-(BOOL)validLink:(NSString*)link forResourceType:(LayResourceTypeIdentifier)resourceTypeId_ {
    BOOL validLink = NO;
    if(resourceTypeId_ == RESOURCE_TYPE_FILE || resourceTypeId_ == RESOURCE_TYPE_WEB) {
        NSURL *linkUrl = [NSURL URLWithString:link];
        if(linkUrl && linkUrl.scheme && linkUrl.host) {
            validLink = YES;
        }
    } else if(resourceTypeId_ == RESOURCE_TYPE_BOOK) {
        validLink = YES;
    }
    return validLink;
}

-(void)openResourceDialog:(UIView*)dialog {
    const CGPoint dialogCenter = CGPointMake(0.0f, self.view.window.frame.size.height/2.0f);
    [LayFrame setPos:dialogCenter toView:dialog];
    const CGFloat dialogHeight = [self layoutResourceDialog:dialog];
    CALayer *dialogLayer = dialog.layer;
    [UIView animateWithDuration:0.3 animations:^{
        dialogLayer.bounds = CGRectMake(0.0f, 0.0f, dialog.frame.size.width, dialogHeight);
    }];
}

-(CGFloat)layoutResourceDialog:(UIView*)dialog {
    const CGFloat vSpace = 10.0f;
    CGFloat currentYPos = 15.0f;
    for (UIView* subView in [dialog subviews]) {
        [LayFrame setYPos:currentYPos toView:subView];
        currentYPos += subView.frame.size.height + vSpace;
        if(subView.tag == TAG_TEXT_FIELD_TITLE) {
            currentYPos += 5.0f;
        }
    }
    return currentYPos;
}

-(void)layoutResourceDialogButtonContainer:(UIView*)dialogButtonContainer {
    const CGFloat hSpace = 20.0f;
    CGFloat currentXPos = 0.0f;
    for (UIView* subView in [dialogButtonContainer subviews]) {
        [LayFrame setXPos:currentXPos toView:subView];
        currentXPos += subView.frame.size.width + hSpace;
    }
}

-(void)closeAddResourceDialog {
    [self.tableView reloadData];
    if(self->addResourceDialog) {
        [self->addResourceDialog.superview removeFromSuperview];
        self->addResourceDialog = nil;
    }
}

- (void)textFieldChanged:(UITextField *)textField {
    UITextField *titleTextField = (UITextField*)[self->addResourceDialog viewWithTag:TAG_TEXT_FIELD_TITLE];
    UITextField *linkTextField = (UITextField*)[self->addResourceDialog viewWithTag:TAG_TEXT_FIELD_LINK];
    LayButton *saveButton = (LayButton*)[self->addResourceDialog viewWithTag:TAG_SAVE_BUTTON];
    if(([titleTextField.text length] > 0) && ([linkTextField.text length] > 0)
        && titleTextFieldDefaultValueSwitch && linkTextFieldDefaultValueSwitch) {
        saveButton.enabled = YES;
        UILabel* statusLabel = (UILabel*)[self->addResourceDialog viewWithTag:TAG_STATUS_LABEL];
        statusLabel.hidden = YES;
    } else {
        saveButton.enabled = NO;
    }
}

-(void)showDefaultValueForTextField:(UITextField*)textField resourceType:(LayResourceTypeIdentifier)resourceType show:(BOOL)showDefaultValue {
    if(self->addResourceDialog) {
        if(showDefaultValue) {
            NSString *defaultValue = nil;
            if(textField.tag == TAG_TEXT_FIELD_TITLE) {
                defaultValue = NSLocalizedString(@"ResourceTitleDefault", nil);
            } else {
                if(resourceType == RESOURCE_TYPE_BOOK) {
                    defaultValue = NSLocalizedString(@"ResourceBookDefault", nil);
                } else {
                   defaultValue = NSLocalizedString(@"ResourceLinkDefault", nil);
                }
            }
            textField.textColor = [UIColor lightGrayColor];
            textField.text = defaultValue;
        } else {
            LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
            textField.textColor = [styleGuide getColor:TextColor];
            textField.text = @"";
        }
    }
}

//
// keyboard events
//
- (void)keyboardWillShow:(NSNotification *)notification
{
	const CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat overlapVSpace = self->addResourceDialog.frame.origin.y + self->addResourceDialog.frame.size.height - keyboardFrame.origin.y;
    if(overlapVSpace > 0.0f) {
        CALayer *dialogLayer = self->addResourceDialog.layer;
        const CGFloat newYPosDialog = dialogLayer.position.y - overlapVSpace;
        [UIView animateWithDuration:0.3 animations:^{
            dialogLayer.position = CGPointMake(dialogLayer.position.x, newYPosDialog);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
}

//
// LayResourceCellDelegate
//
-(void)editResource:(id)resource {
    if([resource isKindOfClass:[UGCResource class]]) {
        [self editLink:resource];
    }
}

//
// UITextFieldDelegate methods
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CALayer *dialogLayer = self->addResourceDialog.layer;
    const CGFloat newYPosDialog = self->addResourceDialog.superview.layer.position.y;
    [UIView animateWithDuration:0.3 animations:^{
        dialogLayer.position = CGPointMake(dialogLayer.position.x, newYPosDialog);
    }];
    
    [textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField.tag == TAG_TEXT_FIELD_TITLE && !self->titleTextFieldDefaultValueSwitch) {
        self->titleTextFieldDefaultValueSwitch = YES;
         [self showDefaultValueForTextField:textField resourceType:RESOURCE_TYPE_WEB show:NO];
    } else if(textField.tag == TAG_TEXT_FIELD_LINK && !self->linkTextFieldDefaultValueSwitch) {
        self->linkTextFieldDefaultValueSwitch = YES;
        [self showDefaultValueForTextField:textField resourceType:RESOURCE_TYPE_WEB show:NO];
    }
    return YES;
}

//
-(void)cancelAddingResource {
    [self closeAddResourceDialog];
}

-(void)saveEditedResource:(UIButton*)sender {
    if(self->addResourceDialog) {
        UITextField *titleTextField = (UITextField*)[self->addResourceDialog viewWithTag:TAG_TEXT_FIELD_TITLE];
        NSString *title = titleTextField.text;
        UITextField *linkTextField = (UITextField*)[self->addResourceDialog viewWithTag:TAG_TEXT_FIELD_LINK];
        NSString *link = linkTextField.text;
        if([self validLink:link forResourceType:self->addResourceDialog.tag]) {
            LayButton *button = (LayButton*)sender;
            Resource *resource = (Resource*)button.resource;
            if(resource) {
                resource.title = title;
                LayResourceTypeIdentifier resourceType = [resource resourceType];
                if(resourceType == RESOURCE_TYPE_BOOK) {
                    resource.text = link;
                } else {
                    resource.link = link;
                }
            } else {
                [self addNewResource:title link:link ofType:self->addResourceDialog.tag];
            }
            [self closeAddResourceDialog];
        } else {
            UILabel* statusLabel = (UILabel*)[self->addResourceDialog viewWithTag:TAG_STATUS_LABEL];
            [LayFrame setWidthWith:self->addResourceDialog.frame.size.width toView:statusLabel];
            statusLabel.hidden = NO;
            statusLabel.text = NSLocalizedString(@"ResourceInvalidLinkMessage", nil);
        }
    }
}

-(UGCResource*)saveEditedResource:(NSString*)title link:(NSString*)link context:(NSManagedObject*)managedObject andType:(LayResourceTypeIdentifier)resourceTypeId_ {
    UGCResource *uResource = nil;
    if([managedObject isKindOfClass:[Catalog class]]) {
        Catalog *catalog = (Catalog*)managedObject;
        LayUserDataStore *uStore = [LayUserDataStore store];
        UGCCatalog *uCatalog = [uStore findCatalogByTitle:catalog.title andPublisher:[catalog publisher]];
        if(!uCatalog) {
            uCatalog = [uStore insertObject:UGC_OBJECT_CATALOG];
            uCatalog.title = catalog.title;
            uCatalog.nameOfPublisher = [catalog publisher];
        }
        uResource = [uStore insertObject:UGC_OBJECT_RESOURCE];
        uResource.title = title;
        LayResourceTypeIdentifier resourceType = [uResource resourceType];
        if(resourceType == RESOURCE_TYPE_BOOK) {
            uResource.text = link;
        } else {
            uResource.link = link;
        }

        uResource.catalogRef = uCatalog;
        uResource.type = [NSNumber numberWithUnsignedInteger:resourceTypeId_];
        if(self->explanationParam) {
            UGCExplanation *uExplanation = [uCatalog explanationByName:self->explanationParam.name];
            if(!uExplanation) {
                uExplanation = [uStore insertObject:UGC_OBJECT_EXPLANATION];
                uExplanation.name = self->explanationParam.name;
                uExplanation.title = self->explanationParam.title;
                [uCatalog addExplanationRefObject:uExplanation];
            }
            [uExplanation addResourceRefObject:uResource];
        } else if(self->questionParam) {
            UGCQuestion *uQuestion = [uCatalog questionByName:self->questionParam.name];
            if(!uQuestion) {
                uQuestion = [uStore insertObject:UGC_OBJECT_QUESTION];
                uQuestion.name = self->questionParam.name;
                uQuestion.question = self->questionParam.question;
                [uCatalog addQuestionsRefObject:uQuestion];
            }
            [uQuestion addResourceRefObject:uResource];
        }
    } else {
        MWLogError([LayVcResource class], @"A catalog context is required!");
    }
    return uResource;
}

-(void)saveUpdatedResource {
    LayUserDataStore *uStore = [LayUserDataStore store];
    if(![uStore saveChanges]) {
        MWLogError([LayVcResource class], @"Could not save resources!");
    } else {
        MWLogDebug([LayVcResource class], @"Saved resources successfully!");
    }
}

-(void)handlePreferredFontSizeChanges {
    [self setupSectionViews];
    [self setupAddButtons];
    [self setupTableHeader];
    [self.tableView reloadData];
}

-(void)handleWantToImportCatalogNotification {
    if(self.navigationController.topViewController == self) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

@end



