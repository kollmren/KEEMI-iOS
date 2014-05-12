//
//  LayCatalogDetails.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 13.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayCatalogDetails.h"
#import "LayDetailsTable.h"
#import "LayStyleGuide.h"
#import "LayVBoxLayout.h"
#import "LayFrame.h"
#import "LayCatalogFileReader.h"
#import "LayMediaView.h"
#import "LayMediaData.h"

#import "Catalog+Utilities.h"
#import "Media+Utilities.h"
#import "Author.h"

#import "MWLogging.h"

static const CGFloat V_SPACE = 10.0f;
static const NSInteger TAG_MEDIA_VIEW = 1001;
static const NSInteger TAG_ADDITIONAL_INFO_VIEW = 1002;

@interface LayCatalogDetails() {
    LayCatalogFileInfo* catalogFileInfo;
    UIView *coverTitleContainer;
    UIView *detailsContainer;
    UIView *container;
    UILabel *description;
}
@end


static Class g_classObj = nil;

@implementation LayCatalogDetails

@synthesize showDetailTable, additionalInfo;

+(void) initialize {
    g_classObj = [LayCatalogDetails class];
}

-(id)initWithCatalog:(Catalog*)catalog andPosition:(CGPoint)position {
    return nil;
}

-(id)initWithCatalogFileInfo:(LayCatalogFileInfo*)catalogFileInfo_ andPositionY:(CGFloat)yPos {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    // The height of the view-frame is adjusted later.
    const CGRect viewFrame = CGRectMake(0.0f, 0.0f, screenFrame.size.width, 0.0f);
    self = [super initWithFrame:viewFrame];
    if (self) {
        self.clipsToBounds = YES;
        self->catalogFileInfo = catalogFileInfo_;
        // add an additional view here as the view in a table-header does not apply the set position
        const CGRect containerFrame = CGRectMake(hSpace, yPos, screenFrame.size.width - 2*hSpace, 0.0f);
        self->container = [[UIView alloc]initWithFrame:containerFrame];
        [self addSubview:self->container];
        [self setupViews:catalogFileInfo_];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id)initWithCatalog:(Catalog*)catalog andPositionY:(CGFloat)yPos {
    LayCatalogFileInfo *fileInfo = [LayCatalogFileInfo new];
    fileInfo.catalogTitle = catalog.title;
    fileInfo.cover = catalog.coverRef.data;
    fileInfo.catalogDescription = catalog.catalogDescription;
    [fileInfo setDetail:catalog.publisher forKey:@"publisher"];
    [fileInfo setDetail:catalog.publisherWebsite forKey:@"websitePublisher"];
    [fileInfo setDetail:catalog.publisherEmail forKey:@"emailPublisher"];
    Author *author = catalog.authorRef;
    [fileInfo setDetail:author.name forKey:@"author"];
    [fileInfo setDetail:author.emailAuthor forKey:@"emailAuthor"];
    NSString *numberOfQuestions = [NSString stringWithFormat:@"%lu", [catalog numberOfQuestions]];
    [fileInfo setDetail:numberOfQuestions forKey:@"numberOfQuestions"];
    NSString *numberOfExplanations = [NSString stringWithFormat:@"%lu", [catalog numberOfExplanations]];
    [fileInfo setDetail:numberOfExplanations forKey:@"numberOfExplanations"];
    [fileInfo setDetail:catalog.topic forKey:@"topic"];
    [fileInfo setDetail:catalog.language forKey:@"language"];
    [fileInfo setDetail:catalog.version forKey:@"version"];
    [fileInfo setDetail:catalog.source forKey:@"source"];
    self = [self initWithCatalogFileInfo:fileInfo andPositionY:yPos];
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    return [self initWithCatalogFileInfo:nil andPositionY:0.0f];
}

-(void)setShowDetailTable:(BOOL)showDetailTable_ {
    showDetailTable = showDetailTable_;
    if(showDetailTable) {
        self->detailsContainer.hidden = NO;
    } else {
        self->detailsContainer.hidden = YES;
    }
    [self layoutView];
}

-(void)setAdditionalInfo:(NSString *)additionalInfo_ {
    additionalInfo = additionalInfo_;
    UILabel *additionalInfoView = (UILabel*)[self->coverTitleContainer viewWithTag:TAG_ADDITIONAL_INFO_VIEW];
    if(additionalInfoView) {
        additionalInfoView.text = additionalInfo_;
        [additionalInfoView sizeToFit];
    }
}

-(void)setupViews:(LayCatalogFileInfo*)catalogFileInfo_ {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGSize viewSize = self->container.frame.size;
    const CGSize coverSize = [styleGuide coverMediaSize];
    const CGRect coverContainerFrame = CGRectMake(0.0f, 0.0f, viewSize.width, coverSize.height);
    self->coverTitleContainer = [[UIView alloc] initWithFrame:coverContainerFrame];
    const CGRect coverFrame = CGRectMake(0.0f, 0.0f, coverSize.width, coverSize.height);
    LayMediaData *coverMediaData = [LayMediaData byData:catalogFileInfo_.cover
                                                   type:catalogFileInfo_.coverMediaType
                                              andFormat:catalogFileInfo_.coverMediaFormat];
    LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:coverFrame andMediaData:coverMediaData];
    mediaView.zoomable = NO;
    mediaView.scaleToFrame = YES;
    mediaView.ignoreEvents = YES;
    mediaView.tag = TAG_MEDIA_VIEW;
    [mediaView layoutMediaView];
    [self->coverTitleContainer addSubview:mediaView];
    const CGFloat coverTitleHSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat coverTitleVSpace = 15.0f;
    const CGFloat xPosTitle = coverSize.width + coverTitleHSpace;
    const CGFloat titleWidth = viewSize.width - coverSize.width - coverTitleHSpace;
    const CGRect titleFrame = CGRectMake(xPosTitle, coverTitleVSpace, titleWidth, coverSize.height - coverTitleVSpace);
    UILabel *title = [[UILabel alloc]initWithFrame:titleFrame];
    title.numberOfLines = 3;
    title.backgroundColor = [UIColor clearColor];
    title.font = [styleGuide getFont:NormalFont];
    title.textColor = [styleGuide getColor:TextColor];
    title.text = catalogFileInfo_.catalogTitle;
    [title sizeToFit];
    [self->coverTitleContainer addSubview:title];
    const CGFloat yPosAddInfo = title.frame.origin.y + title.frame.size.height + 10.0f;
    const CGRect infoFrame = CGRectMake(xPosTitle, yPosAddInfo, titleWidth, coverSize.height - coverTitleVSpace);
    UILabel *additionalInfoView = [[UILabel alloc]initWithFrame:infoFrame];
    additionalInfoView.tag =TAG_ADDITIONAL_INFO_VIEW;
    additionalInfoView.numberOfLines = 1;
    additionalInfoView.backgroundColor = [UIColor clearColor];
    additionalInfoView.font = [styleGuide getFont:SubInfoFont];
    additionalInfoView.textColor = [UIColor darkGrayColor];
    NSString *numberOfQuestionsLabel = NSLocalizedString(@"CatalogNumberOfQuestionsLabel", nil);
    NSString *numberOfQuestions = [catalogFileInfo detailForKey:@"numberOfQuestions"];
    if(numberOfQuestions) {
        NSInteger numberOfQuestionsInteger = [numberOfQuestions integerValue];
        NSString *textToShow = [NSString stringWithFormat:numberOfQuestionsLabel, numberOfQuestionsInteger];
        additionalInfoView.text = textToShow;
    }
    [additionalInfoView sizeToFit];
    [self->coverTitleContainer addSubview:additionalInfoView];
    [self->container addSubview:self->coverTitleContainer];
    // Details
    const CGRect detailContainerFrame = CGRectMake(0.0f, 0.0f, viewSize.width, 0.0f);
    UIFont *detailFont = [styleGuide getFont:TitlePreferredFont];
    // Dont show the number of questions, its already shown in the header of each view!
    [catalogFileInfo_ removeDetailWithKey:@"numberOfQuestions"];
    self->detailsContainer = [[LayDetailsTable alloc]initWithArray:[catalogFileInfo_ labelDataList] frame:detailContainerFrame andFont:detailFont];
    [self->container addSubview:self->detailsContainer];
    // Description
    if(self->catalogFileInfo.catalogDescription) {
        const CGRect descriptionFrame = CGRectMake(0.0f, 0.0f, viewSize.width, 0.0f);
        self->description = [[UILabel alloc]initWithFrame:descriptionFrame];
        self->description.backgroundColor = [UIColor clearColor];
        self->description.font = [styleGuide getFont:NormalPreferredFont];
        self->description.text = catalogFileInfo_.catalogDescription;
        self->description.numberOfLines = [styleGuide numberOfLines];
        [self->description sizeToFit];
        self->description.hidden = YES;
        [self->container addSubview:self->description];
    }
    [self layoutView];
}

-(void)layoutView {
    // Layout
    CGFloat newViewHeight = [LayVBoxLayout layoutSubviewsOfView:self->container withSpace:V_SPACE];
    newViewHeight -= V_SPACE;
    [LayFrame setHeightWith:newViewHeight toView:self->container animated:NO];
    newViewHeight += self->container.frame.origin.y;
    [LayFrame setHeightWith:newViewHeight toView:self animated:NO];
}

-(void)showDescription {
    // Layout
    if(self->description) {
        self->description.hidden = NO;
        [self layoutView];
    }
}

-(void)hideDescription {
    // Layout
    if(self->description) {
        self->description.hidden = YES;
        [self layoutView];
    }
}

@end
