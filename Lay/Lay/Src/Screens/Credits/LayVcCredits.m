//
//  LayVcImport.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 13.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayVcCredits.h"
#import "LayCatalogDetails.h"
#import "LayStyleGuide.h"
#import "LayVcNavigationBar.h"
#import "LayImage.h"
#import "LayFrame.h"
#import "LayButton.h"
#import "LayVBoxLayout.h"
#import "LaySectionView.h"
#import "LayError.h"
#import "LayAppNotifications.h"

#import "MWLogging.h"

#import "Catalog+Utilities.h"
#import "About+Utilities.h"

static const CGFloat V_SPACE = 15.0f;
static const NSInteger TAG_MY_VIEWS = 1001;
static const NSInteger TAG_SECTION_VIEW = 1002;

@interface LayVcCredits () {
    Catalog *catalog;
    UIScrollView *creditView;
    LayVcNavigationBar *navBarViewController;
    LayCatalogDetails *catalogDetailView;
    LayButton *moreDetailsButton;
}

@end

static Class g_classObj = nil;

@implementation LayVcCredits

+(void) initialize {
    g_classObj = [LayVcCredits class];
}

-(id)initWithCatalog:(Catalog*)catalog_ {
    self->catalog = catalog_;
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self registerEvents];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug(g_classObj, @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
}

- (void)loadView
{
    const CGRect screenFrame = [[UIScreen mainScreen] bounds];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat heightOfNavigation = self.navigationController.navigationBar.frame.size.height;
    const CGRect viewFrame = CGRectMake(0.0f, 0.0f, screenFrame.size.width, screenFrame.size.height - heightOfNavigation);
    self->creditView = [[UIScrollView alloc]initWithFrame:viewFrame];
    self->creditView.backgroundColor = [styleGuide getColor:BackgroundColor];
    [self setupView];
    [self setView:self->creditView];
    [self setupNavigation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSectionView:self->catalog.aboutRef];
    [self layoutView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupView {
    const CGRect screenFrame = [[UIScreen mainScreen] bounds];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat heightOfNavigation = self.navigationController.navigationBar.frame.size.height;
    const CGRect viewFrame = CGRectMake(0.0f, 0.0f, screenFrame.size.width, screenFrame.size.height - heightOfNavigation);
    const CGSize buttonSize = CGSizeMake(viewFrame.size.width-2*hSpace, [styleGuide getDefaultButtonHeight]);
    // catalog details
    self->catalogDetailView = [[LayCatalogDetails alloc]initWithCatalog:self->catalog andPositionY:0.0f];
    self->catalogDetailView.tag = TAG_MY_VIEWS;
    [self->creditView addSubview:catalogDetailView];
    // More details button
    if(self->catalog.catalogDescription) {
        const CGRect moreDetailsButtonFrame = CGRectMake(hSpace, 0.0f, buttonSize.width, buttonSize.height);
        NSString* moreDetailsLabel = NSLocalizedString(@"ImportShowDescription", nil);
        self->moreDetailsButton = [[LayButton alloc]initWithFrame:moreDetailsButtonFrame label:moreDetailsLabel font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
        self->moreDetailsButton.tag = TAG_MY_VIEWS;
        [moreDetailsButton addTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];
        [moreDetailsButton fitToContent];
        [self->creditView addSubview:moreDetailsButton];
    }
}

-(void)setupSectionView:(About*)about {
    if(about) {
        NSArray *sectionList = [about sectionList];
        if(sectionList && [sectionList count]>0) {
            LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
            const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
            const CGFloat width = self.view.frame.size.width-2*hSpace;
            const CGRect rect = CGRectMake(hSpace, 0.0f, width, 0.0f);
            LaySectionView *sectionView = [[LaySectionView alloc]initWithFrame:rect andSectionList:sectionList];
            sectionView.tag = TAG_SECTION_VIEW;
            [self->creditView addSubview:sectionView];
        }
    }
}

-(void)setupNavigation {
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navBarViewController.delegate = self;
    self->navBarViewController.cancelButtonInNavigationBar = YES;
    [self->navBarViewController showButtonsInNavigationBar];
    NSString *title = NSLocalizedString(@"CatalogCreditsTitle", nil);
    [self->navBarViewController showTitle:title  atPosition:TITLE_CENTER];
}

-(void)layoutView {
    CGFloat space = V_SPACE;
    CGFloat currentOffsetY = 15.0f;
    for (UIView *subview in self->creditView.subviews) {
        if(!subview.hidden && subview.tag >= TAG_MY_VIEWS) {
            CGRect subViewFrame = subview.frame;
            // y-Pos
            if(subview.tag == TAG_SECTION_VIEW) {
                currentOffsetY += space;
            }
            subViewFrame.origin.y = currentOffsetY;
            subview.frame = subViewFrame;
            currentOffsetY += subViewFrame.size.height + space;
        }
    }
    CGSize newSize = CGSizeMake(self.view.frame.size.width, currentOffsetY);
    [self->creditView setContentSize:newSize];
}

//
// Action handlers
//
-(void) showDescription {
    [self->catalogDetailView showDescription];
    [self->moreDetailsButton removeTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];
    [self->moreDetailsButton addTarget:self action:@selector(hideDescription) forControlEvents:UIControlEventTouchUpInside];
    self->moreDetailsButton.label = NSLocalizedString(@"ImportHiddeDescription", nil);
    [self->moreDetailsButton fitToContent];
    [self layoutView];
}

-(void)hideDescription {
    [self->catalogDetailView hideDescription];
    [self->moreDetailsButton removeTarget:self action:@selector(hiddeDescription) forControlEvents:UIControlEventTouchUpInside];
    [self->moreDetailsButton addTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];
    self->moreDetailsButton.label = NSLocalizedString(@"ImportShowDescription", nil);
    [self->moreDetailsButton fitToContent];
    [self layoutView];
}

-(void)handlePreferredFontSizeChanges {
    for (UIView* subview in [self->creditView subviews]) {
        [subview removeFromSuperview];
    }
    [self setupView];
    [self setupSectionView:self->catalog.aboutRef];
    [self layoutView];
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
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
