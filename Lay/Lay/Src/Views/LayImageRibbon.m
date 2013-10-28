//
//  LayRibbonEntry.m
//  Lay
//
//  Created by Rene Kollmorgen on 16.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayImageRibbon.h"
#import "LayMediaData.h"
#import "LayMediaView.h"
#import "LayPageControl.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"

#import "MWLogging.h"

//
// LayImageRibbonScrollViewDelegate
//
@class LayRibbonEntry;
@interface LayImageRibbonScrollViewDelegate : NSObject<UIScrollViewDelegate> {
    @private
    LayRibbonEntry *visibleEntry;
}
@property (nonatomic, readonly) BOOL userDidScroll;
@property (nonatomic,weak) LayImageRibbon* imageRibbon;
@end

//
// LayRibbonEntry
//
@interface LayRibbonEntry : UIView

@property (nonatomic, readonly ) LayMediaData *mediaData;
@property (nonatomic) NSInteger identifier;
@property (nonatomic) NSInteger page;
//
@property (nonatomic) LayMediaView *mediaView;

- (id)initWithFrame:(CGSize)size mediaData:(LayMediaData*)data;

- (void)layoutEntry;

@end

//
// LayRibbonLineLayer
//
@interface LayRibbonLineLayer : NSObject

@property (nonatomic, readonly) RibbonOrientation orientation;

 -(id)initWithOrientation:(RibbonOrientation)orientation_;
@end


//
// LayRibbonScrollView
//
@interface LayRibbonScrollView : UIScrollView {
    @public
    LayRibbonLineLayer* lineLayer;
}
@property (nonatomic,weak) LayImageRibbon* imageRibbon;

-(void)layoutEntriesHorizontalNonPageMode;
@end


//
// LayImageRibbon
//
@interface LayImageRibbon () {
@private
    LayRibbonScrollView *scrollView;
    LayImageRibbonScrollViewDelegate* scrollDelegate;
    NSInteger pageCounter;
@public
    LayPageControl *pageControl;
    NSUInteger ribbonEntryCurrentPage;
}

@end

// static - prevent other compilation units the access via e.g.
//          extern CGFloat g_MAX_ICON_HEIGHT_RATIO_WITH_LABEL;
static const CGFloat g_DEFAULT_ENTRY_SPACE = 20.0f;
static const NSUInteger RIBBON_ENTRY_START_PAGE = 1;
static const CGFloat g_PAGE_CONTROL_HEIGHT= 11.0f;

@implementation LayImageRibbon

@synthesize space, orientation, entrySize, entryBackgroundColor,
imageSizeRatio, ribbonDelegate, frame, pageMode, entriesInteractive, animateTap;
// LayVBoxView protocol
@synthesize spaceAbove, keepWidth, border;


- (id)initWithFrame:(CGRect)frame_ entrySize:(CGSize)entrySize_ andOrientation:(RibbonOrientation) orientation_ {
    self = [super initWithFrame:frame_];
    if (self) {
        // Set defaults
        space = g_DEFAULT_ENTRY_SPACE;
        pageMode = NO;
        entriesInteractive = YES;
        //
        orientation = orientation_;
        entrySize = entrySize_;
        pageCounter = RIBBON_ENTRY_START_PAGE;
        ribbonEntryCurrentPage = RIBBON_ENTRY_START_PAGE;
        self->scrollView = [[LayRibbonScrollView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, frame_.size.width, frame_.size.height)];
        self->scrollView.showsHorizontalScrollIndicator = NO;
        self->scrollView.imageRibbon = self;
        self->scrollView->lineLayer = [[LayRibbonLineLayer alloc]initWithOrientation:orientation_];
        self->scrollDelegate = [LayImageRibbonScrollViewDelegate new];
        self->scrollDelegate.imageRibbon = self;
        [self addSubview:self->scrollView];
        self->pageControl = [[LayPageControl alloc]initWithPosition:CGPointMake(0.0f, 0.0f) height:g_PAGE_CONTROL_HEIGHT andNumberOfPages:0];
        self->pageControl.userInteractionEnabled = NO;
        self->pageControl.hidesForSinglePage = YES;
        [self->pageControl setHidden:YES];
        [self addSubview:self->pageControl];
        //self.entryBackgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.6];
        self.backgroundColor = [[LayStyleGuide instanceOf:nil] getColor:NoColor];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayImageRibbon class], @"dealloc");
}

-(void)setFrame:(CGRect)frame_ {
    frame = frame_;
    super.frame = frame_;
    self->scrollView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
    [self layoutRibbon];
}

-(void)setPageMode:(BOOL)pageMode_ {
    pageMode = pageMode_;
    if(pageMode) {
        self->scrollView.pagingEnabled = YES;
        [self->pageControl setHidden:NO];
        self->scrollView.delegate = self->scrollDelegate;
    } else {
        self->scrollView.delegate = nil;
    }
}

-(void) addEntry:(LayMediaData*)data withIdentifier:(NSInteger)identifier {
    LayRibbonEntry *entry = [[LayRibbonEntry alloc]initWithFrame:self.entrySize mediaData:data];
    entry.page = self->pageCounter++;
    entry.backgroundColor = self.entryBackgroundColor;
    entry.identifier = identifier;
    [self->scrollView addSubview:entry];
    //[self layoutRibbon];
}

-(void)fitHeightOfRibbonToEntryContent {
    CGFloat highestEntryContent = 0.0f;;
    for (UIView* subview in self->scrollView.subviews) {
        if([subview isKindOfClass:[LayRibbonEntry class]]) {
            LayRibbonEntry *entry = (LayRibbonEntry*)subview;
            LayMediaView *entryMediaView = entry.mediaView;
            CGFloat heightOfMediaView = entryMediaView.frame.size.height;
            if(heightOfMediaView > highestEntryContent) {
                highestEntryContent = heightOfMediaView;
            }
        }
    }
    entrySize = CGSizeMake(self.entrySize.width, highestEntryContent);
    const CGFloat vSpace = 0.0f;
    CGFloat newHeightOfRibbon = highestEntryContent + 2 * (g_PAGE_CONTROL_HEIGHT+vSpace);
    [LayFrame setHeightWith:newHeightOfRibbon toView:self animated:NO];
}

-(void) addEntryWithImage:(UIImage*)image withIdentifier:(NSInteger)identifier {
    LayMediaData *imageMediaData = [LayMediaData byUIImage:image];
    [self addEntry:imageMediaData withIdentifier:identifier];
}

-(NSUInteger) numberOfEntries {
    NSUInteger numberOfEntries_ = 0;
    for (UIView* subview in self->scrollView.subviews) {
        if([subview isKindOfClass:[LayRibbonEntry class]]) ++numberOfEntries_;
    }
    return numberOfEntries_;
}

-(void) removeAllEntries {
    for (UIView* entry in self->scrollView.subviews) {
        [entry removeFromSuperview];
    }
    self->pageCounter = RIBBON_ENTRY_START_PAGE;
    self->ribbonEntryCurrentPage = RIBBON_ENTRY_START_PAGE;
    //[self->pageControl removeFromSuperview];
}

-(void) showEntryWithIdentifier:(NSUInteger)identfier {
    NSUInteger pageNumber = [self pageNumberForEntry:identfier];
    [self showPage:pageNumber];
}

-(void)showPage:(NSUInteger)pageNumber {
    NSArray *entryList = self->scrollView.subviews;
    if(pageNumber <= [entryList count]) {
        self->ribbonEntryCurrentPage = pageNumber;
        CGRect ribbonFrame = self.frame;
        ribbonFrame.origin.x = ribbonFrame.size.width * (pageNumber-1);
        [self->scrollView scrollRectToVisible:ribbonFrame animated:YES];
        self->pageControl.currentPage = pageNumber - 1;
    } else {
        MWLogError([LayImageRibbon class], @"Page-number :%u is equal than number of entries:%u", pageNumber, [entryList count]);
    }
}

-(NSUInteger)pageNumberForEntry:(NSInteger)entryIdentifier {
    NSUInteger pageNumber = RIBBON_ENTRY_START_PAGE;
    for (UIView* subview in [self->scrollView subviews]) {
        if([subview isKindOfClass:[LayRibbonEntry class]]) {
            LayRibbonEntry* entry = (LayRibbonEntry*)subview;
            if(entry.identifier == entryIdentifier) {
                break;
            } else {
                pageNumber++;
            }
        }
    }
    return pageNumber;
}

-(NSInteger)currentPageNumber {
    return self->ribbonEntryCurrentPage;
}

-(NSInteger)entryIdentifierForCurrentPage {
    NSInteger identifier = 0;
    CGFloat pageWidth = self->scrollView.contentOffset.x;
    for (UIView* subview in [self->scrollView subviews]) {
        CGRect entryRect = subview.frame;
        CGFloat xPosEntry = pageWidth + 2 * g_DEFAULT_ENTRY_SPACE;
        if( entryRect.origin.x == xPosEntry ) {
            if([subview isKindOfClass:[LayRibbonEntry class]]) {
                LayRibbonEntry* entry = (LayRibbonEntry*)subview;
                identifier = entry.identifier;
                break;
            }
        }
    }
    return identifier;
}

-(CGPoint)midPositionOfPageIndicatorOfPage:(NSInteger)pageNumber; {
    // ImageRibbon works with an pageNumber which start with 1, PageCotrol expects zero based numbers
    const CGPoint midPosCurrentPageIndicator = [self->pageControl midPositionOfPageIndicatorOfPage:pageNumber-1];
    const CGPoint midPosCurrentPageIndicatorInRibbon = [self->pageControl convertPoint:midPosCurrentPageIndicator toView:self];
    return midPosCurrentPageIndicatorInRibbon;
}

-(BOOL)nextPage {    
    BOOL thereAreFurtherPages = NO;
    NSUInteger numberOfEntriesInRibbon = [self numberOfEntries];
    if(numberOfEntriesInRibbon > self->ribbonEntryCurrentPage ) {
        self->ribbonEntryCurrentPage++;
        [self showPage:self->ribbonEntryCurrentPage];
        if(numberOfEntriesInRibbon > self->ribbonEntryCurrentPage ) thereAreFurtherPages = YES;
    }
    
    return thereAreFurtherPages;
}

-(BOOL)previousPage {
    BOOL thereAreFurtherPages = NO;
    if(RIBBON_ENTRY_START_PAGE < self->ribbonEntryCurrentPage ) {
        self->ribbonEntryCurrentPage--;
        [self showPage:self->ribbonEntryCurrentPage];
        if(RIBBON_ENTRY_START_PAGE < self->ribbonEntryCurrentPage ) thereAreFurtherPages = YES;
    }
    return thereAreFurtherPages;
}

-(void)setEntrySize:(CGSize)entrySize_ {
    entrySize = entrySize_;
    CGFloat ribbonHeight = self.frame.size.height;
    if(self.orientation == HORIZONTAL) {
        if(entrySize.height > ribbonHeight ) {
            MWLogWarning([LayImageRibbon class], @"Height(%d) of the entry does not fit into ribbon-height(%d)",
                        entrySize.height, ribbonHeight );
        }
        [self layoutEntriesHorizontal];
    } else {
        // TODO
    }
}

-(BOOL)userDidScroll {
    return [self->scrollDelegate userDidScroll];
}

-(void)layoutRibbon {
    if(self.orientation == HORIZONTAL) {
        [self layoutEntriesHorizontal];
    } else {
        MWLogInfo([LayImageRibbon class], @"!!TODO: Ribbon does not support VERTICAL orientation yes!");
    }
}

-(void) layoutEntriesHorizontal {
    if(self.pageMode) {
        [self layoutEntriesHorizontalPageMode];
    } else {
        [self layoutEntriesHorizontalNonPageMode];
    }
}

-(void) layoutEntriesHorizontalNonPageMode {
    [self->scrollView layoutEntriesHorizontalNonPageMode];
}


-(void) layoutEntriesHorizontalPageMode {
    const CGFloat ribbonHeight = self.frame.size.height;
    const CGFloat ribbonWidth = self.frame.size.width;
    const CGFloat heightOfPageControl = self->pageControl.frame.size.height;
    const CGFloat yPosEntryPage = (ribbonHeight - heightOfPageControl - entrySize.height) / 2;
    const CGFloat xDistanceToNextEntry = (ribbonWidth - entrySize.width);
    CGFloat xPosNext = (ribbonWidth - entrySize.width) / 2;
    for (UIView* subview in self->scrollView.subviews) {
        if([subview isKindOfClass:[LayRibbonEntry class]]) {
            [LayFrame setSizeWith:self.entrySize toView:subview];
            CGRect subviewFrame = subview.frame;
            subviewFrame.origin.x = xPosNext;
            subviewFrame.origin.y = yPosEntryPage;
            subview.frame = subviewFrame;
            xPosNext +=  entrySize.width + xDistanceToNextEntry;
            LayRibbonEntry* entry = (LayRibbonEntry*)subview;
            [entry layoutEntry];
        }
    }
    // Page control
    NSUInteger numberOfEntries = [self numberOfEntries];
    self->pageControl.numberOfPages = numberOfEntries;
    self->pageControl.currentPage = RIBBON_ENTRY_START_PAGE - 1;
    const CGFloat adjustedWidthOfPageControl = self->pageControl.frame.size.width;
    // center page-control
    const CGFloat xPosPageControl = (ribbonWidth / 2) - (adjustedWidthOfPageControl / 2);
    const CGFloat yPosPageControl = ribbonHeight - self->pageControl.frame.size.height;
    const CGPoint posPageControl = CGPointMake(xPosPageControl, yPosPageControl);
    [LayFrame setPos:posPageControl toView:self->pageControl];
    CGFloat contentWidth = numberOfEntries * ribbonWidth;
    [self->scrollView setContentSize:CGSizeMake(contentWidth, ribbonHeight)];
}

-(void) layoutEntriesVertical {
    // TODO
}

-(void)animateTap:(LayRibbonEntry*) entry {
    // Setup the properties of the animation
    CABasicAnimation *animation = [CABasicAnimation
                                   animationWithKeyPath:@"transform"];
    CATransform3D scaleMatrix = CATransform3DMakeScale(0.7f, 0.7f, 1.0f);
    CATransform3D identMatrix = CATransform3DIdentity;
    NSValue *scaleMatrixNsValue = [NSValue valueWithCATransform3D:scaleMatrix];
    NSValue *identMatrixNsValue = [NSValue valueWithCATransform3D:identMatrix];
    [animation setFromValue:identMatrixNsValue];
    [animation setToValue:scaleMatrixNsValue];
    [animation setDuration:0.1f];
    CALayer *imageViewLayer = entry.mediaView.layer;
    // Start the animation
    [CATransaction begin];
    [imageViewLayer addAnimation:animation forKey:@"scaleDown"];
    [CATransaction commit];
}

@end


//
// LayRibbonEntry
//
@implementation LayRibbonEntry

@synthesize mediaData, mediaView, identifier, page;

// Parameter title can be nil!
- (id)initWithFrame:(CGSize)size mediaData:(LayMediaData *)data
{
    CGRect frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    self = [super initWithFrame:frame];
    if (self) {
        mediaData = data;
        // add subviews
        CGRect notLayoutedRect = frame; // the height is adjusted in the layout method 
        self.mediaView = [[LayMediaView alloc]initWithFrame:notLayoutedRect andMediaData:mediaData];
        self.mediaView.fitToContent = YES;
        //[self.mediaView layoutMediaView];
        [self addSubview:self.mediaView];
        // layout
        //[self layoutEntry];
    }
    return self;
}

/**
 An entry should be touchable at all the MediaView and the UILabel. If the 
 label is interactive(userInteractionEnabled=YES) its touchable but the touch-event is
 forwarded as an touch from an UILabel to the ScrollView and not as LayRibbonEntry.
 */
/*- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = nil;
    BOOL anSubviewWasTouched = [self pointInside:point withEvent:event];
//    for (UIView *subview in self.subviews) {
//        if([subview pointInside:point withEvent:event]) {
//            anSubviewWasTouched = YES;
//            break;
//        }
//    }
    if(anSubviewWasTouched) view = self;
    return view;
}
 */

-(void)setBackgroundColor:(UIColor *)backgroundColor_ {
    super.backgroundColor = backgroundColor_;
    self.mediaView.backgroundColor = backgroundColor_;
}

-(void)layoutEntry {
    CGFloat entryHeight = self.frame.size.height;
    [LayFrame setHeightWith:entryHeight toView:self.mediaView animated:NO];
    [self.mediaView layoutMediaView];
    // center media vertically
    const CGFloat xPosMediaView = (self.frame.size.width - self.mediaView.frame.size.width) / 2.0f;
    [LayFrame setXPos:xPosMediaView toView:self.mediaView];
    const CGFloat yPosMediaView = (self.frame.size.width - self.mediaView.frame.size.height) / 2.0f;
    [LayFrame setYPos:yPosMediaView toView:self.mediaView];
    self.mediaView.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height / 2.0f);
}

@end

//
// LayRibbonLineLayer
//
@implementation LayRibbonLineLayer

const CGFloat lineMiddleBreak = 6.0f;

@synthesize orientation;

-(id)initWithOrientation:(RibbonOrientation)orientation_;
{
    self = [super init];
    if (self) {
        orientation = orientation_;
    }
    return self;
}

-(void) drawLayer:(CALayer*)layer inContext:(CGContextRef)context {
    if(self.orientation == HORIZONTAL) {
        CGFloat lineHeight = layer.frame.size.height;
        CGFloat lineMiddle = lineHeight / 2;
        CGFloat yEndFirstLine = lineMiddle - lineMiddleBreak / 2;
        CGFloat yStartSecondLine = lineMiddle + lineMiddleBreak / 2;
        const CGFloat yFrameLeftBottom = layer.frame.origin.y + layer.frame.size.height;
        //
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.8);
        // First line
        CGContextMoveToPoint(context, 0.0, 0.0);
        CGContextAddLineToPoint(context, 0.0, yEndFirstLine);
        // Second line
        CGContextMoveToPoint(context, 0.0, yStartSecondLine);
        CGContextAddLineToPoint(context, 0.0, yFrameLeftBottom);
        // And width 2.0 so they are a bit more visible
        CGContextSetLineWidth(context, 2.0);
        CGContextStrokePath(context);
    } else {
        //TODO
    }
}

@end

//
// LayRibbonScrollView
//
@implementation LayRibbonScrollView

@synthesize imageRibbon;

-(void)dealloc {
    MWLogDebug([LayRibbonScrollView class], @"dealloc");
}

-(id)initWithFrame:(CGRect)frame_ {
    self = [super initWithFrame:frame_];
    if(self) {
        
    }
    return self;
}

/*- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    if(!imageRibbon.entriesInteractive) return NO;
    if([view isKindOfClass:[LayRibbonEntry class]]) {
        LayRibbonEntry* entry = (LayRibbonEntry*)view;
        if(imageRibbon.animateTap) {
            [imageRibbon animateTap:entry];
        }
        
        if(imageRibbon.ribbonDelegate != nil) {
            [imageRibbon.ribbonDelegate entryTapped:entry.identifier];
        } else {
            MWLogWarning([LayImageRibbon class], @"No delegate set. No message send for tap on entry with id:%d", entry.identifier);
        }
    } else {
        MWLogError([LayImageRibbon class], @"There are subviews of an unknown type!");
    }
    return NO;
}*/


-(void) layoutEntriesHorizontalNonPageMode {
    // center entries vertically
   CGFloat ribbonHeight = self.frame.size.height;
    const CGFloat yPos = (ribbonHeight - imageRibbon.entrySize.height) / 2;
    CGFloat nextPosX = imageRibbon.space;
    BOOL firstEntry = YES;
    NSArray *entryList = self.subviews;
    for (UIView* entry in entryList) {
        [LayFrame setSizeWith:imageRibbon.entrySize toView:entry];
        LayRibbonEntry *ribbonEntry = (LayRibbonEntry*)entry;
        [ribbonEntry layoutEntry];
        CGRect entryFrame = entry.frame;
        if(firstEntry) entryFrame.origin.x = imageRibbon.space / 2;
        else entryFrame.origin.x = nextPosX;
        entryFrame.origin.y = yPos;
        entry.frame = entryFrame;
        if(!firstEntry) {
            CGFloat nextLinePosX = nextPosX - imageRibbon.space / 2;
            CALayer *line = [[CALayer alloc]init];
            line.frame = CGRectMake(nextLinePosX,0.0f,2.0f,ribbonHeight);
            line.delegate = self->lineLayer;
            [line setNeedsDisplay];
            [self.layer addSublayer:line];
        }
        firstEntry = NO;
        nextPosX = entryFrame.origin.x + entryFrame.size.width + imageRibbon.space;
    }
    [self setContentSize:CGSizeMake(nextPosX, ribbonHeight)];
}

@end



@implementation LayImageRibbonScrollViewDelegate

@synthesize userDidScroll;

- (id)init
{
    self = [super init];
    if (self) {
        userDidScroll = NO;
        visibleEntry = nil;
    }
    return self;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    userDidScroll = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    userDidScroll = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.imageRibbon || self.userDidScroll==NO) return;
    for (UIView *subview in scrollView.subviews) {
        if([subview isKindOfClass:[LayRibbonEntry class]]) {
            LayRibbonEntry *entry = (LayRibbonEntry *)subview;
            CGRect entryFrame = entry.frame;
            bool intersect = CGRectIntersectsRect(scrollView.bounds, entryFrame);
            if(intersect) {
                visibleEntry = entry;
            }
        }
    }
    
    self.imageRibbon->pageControl.currentPage = visibleEntry.page-1;
    self.imageRibbon->ribbonEntryCurrentPage = visibleEntry.page;
    if(self.imageRibbon.ribbonDelegate) {
        [self.imageRibbon.ribbonDelegate scrolledToPage:visibleEntry.page];
    }
    //MWLogInfo([LayImageRibbonScrollViewDelegate class], @"Current visible entry:%@ page:%u", visibleEntry.mediaData.name, visibleEntry.page);
}

@end

/**@implementation MyUILabel

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inside = [super pointInside:point withEvent:nil];
    if(inside) {
        BOOL i = NO; //never reached
    }
    return inside;
}

@end
 */


