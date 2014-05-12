//
//  LayVcCatalogHeader.m
//  Lay
//
//  Created by Rene Kollmorgen on 18.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcExplanationListHeader.h"
#import "LayMediaData.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayCatalogManager.h"
#import "LayImage.h"
#import "LayMediaView.h"

#import "Catalog+Utilities.h"
#import "Media+Utilities.h"

#import "MWLogging.h"

static const CGFloat YPOS_COVER = 10;
static const NSInteger TAG_MEDIA_VIEW = 1001;

@implementation LayVcExplanationListHeader

@synthesize summaryLabel;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
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
    const CGRect coverMediaRect = CGRectMake(hSpace, YPOS_COVER, coverSize.width, coverSize.height);
    LayMediaData *coverMediaData = [LayMediaData byMediaObject:cover_];
    LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:coverMediaRect andMediaData:coverMediaData];
    mediaView.zoomable = NO;
    mediaView.scaleToFrame = YES;
    mediaView.ignoreEvents = YES;
    mediaView.tag = TAG_MEDIA_VIEW;
    [mediaView layoutMediaView];
    [self.view addSubview:mediaView];
}

-(void)dealloc {
    MWLogDebug([LayVcExplanationListHeader class], @"dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    
    const CGRect labelFrame = CGRectMake(self.catalogTitle.frame.origin.x, 0.0f, self.catalogTitle.frame.size.width, 0.0f);
    summaryLabel = [[UILabel alloc]initWithFrame:labelFrame];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    summaryLabel.font = [styleGuide getFont:SubInfoFont];
    summaryLabel.textColor = [UIColor darkGrayColor];
    summaryLabel.backgroundColor = [UIColor clearColor];
    summaryLabel.numberOfLines = 1;
    
    self.catalogTitle.font = [styleGuide getFont:NormalFont];
    self.catalogTitle.textColor = [styleGuide getColor:TextColor];
    self.catalogTitle.text = catalog.title;
    [self.catalogTitle sizeToFit];
    [self setCover:catalog.coverRef];
    
    const CGFloat newYPoslabel = self.catalogTitle.frame.origin.y + self.catalogTitle.frame.size.height + 10.0f;
    [LayFrame setYPos:newYPoslabel toView:summaryLabel];
    [self.view addSubview:summaryLabel];
    [self updateLabel];
}

-(void)viewWillAppear:(BOOL)animated {
    [self updateLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void)updateLabel {
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    const NSUInteger numberOfExplanations = [catalog numberOfExplanations];
    NSString *numberOfItemsLabel = NSLocalizedString(@"CatalogNumberOfExplanations", nil);
    NSString *textToShow = [NSString stringWithFormat:numberOfItemsLabel, numberOfExplanations];
    summaryLabel.text = textToShow;
    [summaryLabel sizeToFit];
}

@end


