//
//  LayVcCatalogHeader.m
//  Lay
//
//  Created by Rene Kollmorgen on 18.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcCatalogListHeader.h"
#import "LayMediaData.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayCatalogManager.h"
#import "LayImage.h"
#import "LayMediaView.h"
#import "LayUserDefaults.h"

#import "Catalog+Utilities.h"
#import "Media+Utilities.h"

#import "MWLogging.h"

static const NSInteger TAG_MEDIA_VIEW = 1001;

@implementation LayVcCatalogListHeader

@synthesize menu;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        self->appearsFirstTime = YES;
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *appSettings = [standardUserDefaults dictionaryRepresentation];
        self->userBoughtProVersion = [appSettings objectForKey:(NSString*)userDidBuyProVersion]==nil?NO:YES;
    }
    return self;
}

-(void)setCover:(Media *)cover_ {
    UIView *subview = [self.view viewWithTag:TAG_MEDIA_VIEW];
    if(subview) {
        [subview removeFromSuperview];
        subview = nil;
    }
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGSize coverSize = [styleGuide coverMediaSize];
    const CGRect coverMediaRect = CGRectMake(hSpace, 10.0f, coverSize.width, coverSize.height);
    LayMediaData *coverMediaData = [LayMediaData byMediaObject:cover_];
    LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:coverMediaRect andMediaData:coverMediaData];
    mediaView.scaleToFrame = YES;
    mediaView.ignoreEvents = YES;
    mediaView.tag = TAG_MEDIA_VIEW;
    [mediaView layoutMediaView];
    [self.view addSubview:mediaView];
}

-(void)dealloc {
    MWLogDebug([LayVcCatalogListHeader class], @"dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    
    const NSUInteger numberOfQuestions = [catalog numberOfQuestions];
    //const NSUInteger numberOfExplanations = [catalog numberOfExplanations];
    NSString *numberOfQuestionsLabel = NSLocalizedString(@"CatalogNumberOfQuestionsLabel", nil);
    NSString *textToShow = [NSString stringWithFormat:numberOfQuestionsLabel, numberOfQuestions];
    /*if(numberOfExplanations > 0) {
        NSString *numberOfExplanationsLabel = NSLocalizedString(@"CatalogNumberOfExplanationsLabel", nil);
        NSString *textWithExplanations = [NSString stringWithFormat:numberOfExplanationsLabel, numberOfExplanations];
        textToShow = [NSString stringWithFormat:@"%@  %@", textToShow, textWithExplanations];
    }*/
    const CGRect labelFrame = CGRectMake(self.catalogTitle.frame.origin.x, 0.0f, self.catalogTitle.frame.size.width, 0.0f);
    UILabel *summaryLabel = [[UILabel alloc]initWithFrame:labelFrame];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    summaryLabel.font = [styleGuide getFont:SubInfoFont];
    summaryLabel.textColor = [UIColor darkGrayColor];
    summaryLabel.text = textToShow;
    summaryLabel.backgroundColor = [UIColor clearColor];
    summaryLabel.numberOfLines = 1;
    [summaryLabel sizeToFit];
    
    self.catalogTitle.font = [styleGuide getFont:NormalFont];
    self.catalogTitle.textColor = [styleGuide getColor:TextColor];
    self.catalogTitle.text = catalog.title;
    [self.catalogTitle sizeToFit];
    [self setCover:catalog.coverRef];
    
    const CGFloat newYPoslabel = self.catalogTitle.frame.origin.y + self.catalogTitle.frame.size.height + 10.0f;
    [LayFrame setYPos:newYPoslabel toView:summaryLabel];
    [self.view addSubview:summaryLabel];
    [self setupMenu];
    self->appearsFirstTime = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    if(!self->appearsFirstTime) {
        [self updateMenu];
    }
    [self->menu collapseSubMenuEntries];
    self->appearsFirstTime = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

static const CGFloat g_MENU_HEIGHT = 70.0f;
static const CGFloat V_SPACE = 15.0f;

-(void) setupMenu {    
    CGRect menuRect = CGRectMake(0.0f, 0.0, self.view.frame.size.width, self.view.frame.size.height - 10.0f);
    const CGFloat entryHeight = 65.0f;
    menu = [[LayMenu alloc]initWithFrame:menuRect entryHeight:entryHeight andOrientation:HORIZONTAL];
    menu.imageSizeRatio = 60.0f;
    
    UIImage *learnIcon = [LayImage imageWithId:LAY_IMAGE_LEARN];
    UIImage *queryIcon = [LayImage imageWithId:LAY_IMAGE_QUERY];
    UIImage *statisticIcon = [LayImage imageWithId:LAY_IMAGE_STATISTICS];
    UIImage *creditsIcon = [LayImage imageWithId:LAY_IMAGE_CREDITS];
    UIImage *resourcesIcon = [LayImage imageWithId:LAY_IMAGE_RESOURCES_SELECTED];
    UIImage *notesIcon = [LayImage imageWithId:LAY_IMAGE_NOTES_SELECTED];
    UIImage *mailIcon = [LayImage imageWithId:LAY_IMAGE_MAIL];
    
    
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    NSString *entryText = NSLocalizedString(@"CatalogRecall", nil);
    [menu addEntryWithImage:queryIcon:entryText identifier:MENU_QUERY ];
    if([catalog hasMoreThanOneTopicsWithQuestions]) {
        entryText = NSLocalizedString(@"CatalogRecallByTopic", nil);
        [menu addSubEntryWithImage:queryIcon:entryText identifier:MENU_QUERY subIdentifier:MENU_QUERY_BY_TOPIC];
    }
    
    if([catalog hasExplanations]) {
        NSString *entryText = NSLocalizedString(@"CatalogLearn", nil);
        [menu addEntryWithImage:learnIcon:entryText identifier:MENU_LEARN ];
        if([catalog hasTopicsWithExplanations]) {
            entryText = NSLocalizedString(@"CatalogRecallByTopic", nil);
            [menu addSubEntryWithImage:learnIcon:entryText identifier:MENU_LEARN subIdentifier:MENU_LEARN_BY_TOPIC];
        }
    }
    
    entryText = NSLocalizedString(@"CatalogMenuStatistic", nil);
    [menu addEntryWithImage:statisticIcon:entryText identifier:MENU_STATISTIC ];
    
    if([catalog numberOfFavourites] > 0) {
        NSString *entryText = NSLocalizedString(@"CatalogFavourites", nil);
        UIImage *favouritesIcon = [LayImage imageWithId:LAY_IMAGE_FAVOURITES_SELECTED];
        [menu addEntryWithImage:favouritesIcon:entryText identifier:MENU_FAVOURITES ];
    }

    if([catalog hasResources] || self->userBoughtProVersion) {
        NSString *entryText = NSLocalizedString(@"CatalogResources", nil);
        [menu addEntryWithImage:resourcesIcon:entryText identifier:MENU_RESOURCE ];
    }
    
    if(self->userBoughtProVersion) {
        entryText = NSLocalizedString(@"CatalogNotes", nil);
        [menu addEntryWithImage:notesIcon:entryText identifier:MENU_NOTES];
    }
    
    if(catalog.source && [catalog.source length] > 0) {
        entryText = NSLocalizedString(@"CatalogShare", nil);
        [menu addEntryWithImage:mailIcon:entryText identifier:MENU_SHARE];
    }
    
    entryText = NSLocalizedString(@"CatalogCredits", nil);
    [menu addEntryWithImage:creditsIcon:entryText identifier:MENU_CREDITS ];
    
    [self.view addSubview:self->menu];
}

-(void)updateMenu {
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    if([catalog numberOfFavourites] > 0) {
        if(![self->menu hasEntryWithIdentifier:MENU_FAVOURITES]) {
            NSString *entryText = NSLocalizedString(@"CatalogFavourites", nil);
            UIImage *favouritesIcon = [LayImage imageWithId:LAY_IMAGE_FAVOURITES_SELECTED];
            [menu addEntryWithImage:favouritesIcon:entryText identifier:MENU_FAVOURITES nextTo:MENU_STATISTIC animated:NO];
            [menu showEntryWithIdentifier:MENU_FAVOURITES];
        }
    } else {
        [menu removeEntry:MENU_FAVOURITES];
    }
}

@end


