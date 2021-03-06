//
//  LayMenuEntry.m
//  Lay
//
//  Created by Rene Kollmorgen on 16.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayMenu.h"
#import "LayMediaData.h"
#import "LayMediaView.h"
#import "LayPageControl.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"

#import "MWLogging.h"

static const NSInteger NO_SUBMENU_ENTRY_IDENTIFIER = -1;

//
// LayMenuScrollViewDelegate
//
@class LayMenuEntry;
@interface LayMenuScrollViewDelegate : NSObject<UIScrollViewDelegate> {
}
@end

//
// LayMenuEntry
//
@interface LayMenuEntry : UIView

@property (nonatomic) CGFloat mediaSizeRatio;
@property (nonatomic, readonly, copy) NSString *labelText;
@property (nonatomic, readonly ) LayMediaData *mediaData;
@property (nonatomic) NSInteger identifier;
@property (nonatomic) NSInteger superIdentifier;
//
@property (nonatomic) LayMediaView *mediaView;
@property (nonatomic) UILabel *label;
@property (nonatomic) BOOL showAnimated;

- (id)initWithHeight:(CGFloat)entryHeight mediaData:(LayMediaData*)data label:(NSString*) label;

- (void) layoutEntry;

@end

//
// LayMenuLineLayer
//
@interface LayMenuLineLayer : NSObject

@property (nonatomic, readonly) LayMenuOrientation orientation;

 -(id)initWithOrientation:(LayMenuOrientation)orientation_;
@end


//
// LayMenuScrollView
//
@interface LayMenuScrollView : UIScrollView {
    @public
    LayMenuLineLayer* lineLayer;
}
@property (nonatomic,weak) LayMenu* imageMenu;

-(void)layoutEntriesHorizontal;

-(void)collapseSubMenuEntries:(BOOL)animated;

@end


//
// LayImageMenu
//
@interface LayMenu () {
@private
    LayMenuScrollView *scrollView;
    LayMenuScrollViewDelegate* scrollDelegate;
}

@end

// static - prevent other compilation units the access via e.g.
//          extern CGFloat g_MAX_ICON_HEIGHT_RATIO_WITH_LABEL;
static const NSInteger g_MAX_MEDIA_HEIGHT_RATIO_WITH_LABEL = 60.0f;
static const CGFloat g_VERTICAL_SPACE_ICON_LABEL = 5.0f;
static const CGFloat g_DEFAULT_ENTRY_SPACE = 20.0f;

@implementation LayMenu

static const NSString *lineLayerName = @"l";

@synthesize space, orientation, entryHeight, entryBackgroundColor,
imageSizeRatio, menuDelegate, frame, entriesInteractive;
// LayVBoxView protocol
@synthesize spaceAbove, keepWidth, border;


- (id)initWithFrame:(CGRect)frame_ entryHeight:(CGFloat)entryHeight_ andOrientation:(LayMenuOrientation) orientation_ {
    self = [super initWithFrame:frame_];
    if (self) {
        // Set defaults
        space = g_DEFAULT_ENTRY_SPACE;
        entriesInteractive = YES;
        //
        orientation = orientation_;
        entryHeight = entryHeight_;
        const CGFloat scrollMenuHeight = 2 * entryHeight_ + g_DEFAULT_ENTRY_SPACE;
        const CGFloat yPosScrollMenu = frame_.size.height - scrollMenuHeight;
        self->scrollView = [[LayMenuScrollView alloc]initWithFrame:CGRectMake(0.0f, yPosScrollMenu, frame_.size.width, scrollMenuHeight)];
        self->scrollView.showsHorizontalScrollIndicator = NO;
        self->scrollView.imageMenu = self;
        self->scrollView->lineLayer = [[LayMenuLineLayer alloc]initWithOrientation:orientation_];
        //self->scrollView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.6];//[UIColor clearColor];
        self->scrollDelegate = [LayMenuScrollViewDelegate new];
        self->scrollView.delegate = self->scrollDelegate;
        [self addSubview:self->scrollView];
        //self.entryBackgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.6];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayMenu class], @"dealloc");
}

-(void)setFrame:(CGRect)frame_ {
    frame = frame_;
    super.frame = frame_;
    self->scrollView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
    [self layoutMenu];
}

-(void)removeEntry:(NSInteger)identifier {
    UIView *entry = [self->scrollView viewWithTag:identifier];
    if(entry) {
        [entry removeFromSuperview];
        [self layoutMenu];
    }
}

-(BOOL)hasEntryWithIdentifier:(NSInteger)identifier {
    BOOL hasEntry = NO;
    UIView *entry = [self->scrollView viewWithTag:identifier];
    if(entry) {
        hasEntry = YES;
    }
    return hasEntry;
}

-(void) addEntry:(LayMediaData*)data :(NSString*) label identifier:(NSInteger)identifier {
    UIView *entry = [self->scrollView viewWithTag:identifier];
    if(!entry) {
        LayMenuEntry *entry = [[LayMenuEntry alloc]initWithHeight:self.entryHeight mediaData:data label:label];
        entry.backgroundColor = self.entryBackgroundColor;
        entry.identifier = identifier;
        entry.tag = identifier;
        [self->scrollView addSubview:entry];
        [self layoutMenu];
    }
}

-(void) addEntry:(LayMediaData*)data :(NSString*) label identifier:(NSInteger)identifier nextTo:(NSInteger)identifierNext animated:(BOOL)animated {
    UIView *entry = [self->scrollView viewWithTag:identifier];
    if(!entry) {
        LayMenuEntry *entry = [[LayMenuEntry alloc]initWithHeight:self.entryHeight mediaData:data label:label];
        entry.showAnimated = animated;
        entry.backgroundColor = self.entryBackgroundColor;
        entry.identifier = identifier;
        entry.tag = identifier;
        UIView *entryNext = [self->scrollView viewWithTag:identifierNext];
        if(entryNext) {
            [self->scrollView insertSubview:entry aboveSubview:entryNext];
        } else {
            [self->scrollView addSubview:entry];
        }
        
        [self layoutMenu];
    }
}

-(void) addSubEntry:(LayMediaData*)data :(NSString*)label identifier:(NSInteger)identifier subIdentifier:(NSInteger)subIdentifier {
    LayMenuEntry *entry = [[LayMenuEntry alloc]initWithHeight:self.entryHeight mediaData:data label:label];
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    entry.backgroundColor = [style getColor:WhiteTransparentBackground];
    entry.layer.cornerRadius = 10.0f;
    entry.identifier = subIdentifier;
    entry.superIdentifier = identifier;
    entry.tag = identifier;
    entry.hidden = YES;
    entry.userInteractionEnabled = NO;
    [self->scrollView addSubview:entry];
    [self layoutMenu];
}

-(void) addEntryWithImage:(UIImage*)image :(NSString*) label identifier:(NSInteger)identifier {
    LayMediaData *imageMediaData = [LayMediaData byUIImage:image];
    [self addEntry:imageMediaData :label identifier:identifier];
}

-(void) addEntryWithImage:(UIImage*)image :(NSString*) label identifier:(NSInteger)identifier nextTo:(NSInteger)identifierNext animated:(BOOL)animated{
    LayMediaData *imageMediaData = [LayMediaData byUIImage:image];
    [self addEntry:imageMediaData :label identifier:identifier nextTo:identifierNext animated:animated];
}

-(void) addSubEntryWithImage:(UIImage*)image :(NSString*) label identifier:(NSInteger)identifier subIdentifier:(NSInteger)subIdentifier {
    LayMediaData *imageMediaData = [LayMediaData byUIImage:image];
    [self addSubEntry:imageMediaData :label identifier:identifier subIdentifier:subIdentifier];
}

-(void) collapseSubMenuEntries {
    [self->scrollView collapseSubMenuEntries:NO];
}

-(void)touch {
    const CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    const CGFloat menuWidth = self->scrollView.contentSize.width;
    if(menuWidth > screenWidth) {
        const CGFloat moveWidth = 80.0f;
        const CGRect rectToShow = CGRectMake(screenWidth, 0.0f, moveWidth, 10.0f);
        [self->scrollView scrollRectToVisible:rectToShow animated:YES];
    }
}

-(void)showEntryWithIdentifier:(NSInteger)identifier {
    UIView *entry = [self->scrollView viewWithTag:identifier];
    if(entry) {
        const CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        const CGFloat entryXDimension = entry.frame.origin.x + entry.frame.size.width;
        if(entryXDimension > screenWidth) {
            [self->scrollView scrollRectToVisible:entry.frame animated:YES];
        }
    }
}

-(void)setEntryHeight:(CGFloat)entryHeight_ {
    entryHeight = entryHeight_;
    CGFloat menuHeight = self.frame.size.height;
    if(self.orientation == HORIZONTAL) {
        if(entryHeight > menuHeight ) {
            MWLogWarning([LayMenu class], @"Height(%d) of the entry does not fit into Menu-height(%d)",
                        entryHeight, menuHeight );
        }
        [self layoutEntriesHorizontal];
    } else {
        // TODO
    }
}

-(void)layoutMenu {
    if(self.orientation == HORIZONTAL) {
        [self layoutEntriesHorizontal];
    } else {
        MWLogDebug([LayMenu class], @"!!TODO: Menu does not support VERTICAL orientation yes!");
    }
}

-(void) layoutEntriesHorizontal {
    [self->scrollView layoutEntriesHorizontal];
}

-(void) layoutEntriesVertical {
    // TODO
}

-(void)animateTap:(LayMenuEntry*) entry {
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
    CALayer *labelLayer = entry.label.layer;
    // Start the animation
    [CATransaction begin];
    [imageViewLayer addAnimation:animation forKey:@"scaleDown"];
    [labelLayer addAnimation:animation forKey:@"scaleDown"];
    [CATransaction commit];
}

@end


//
// LayMenuEntry
//
@interface LayMenuEntry () {
    CGFloat entryHeight;
}

@end


@implementation LayMenuEntry

@synthesize mediaSizeRatio, labelText, label, mediaData, mediaView, identifier, superIdentifier, showAnimated;

// Parameter title can be nil!
- (id)initWithHeight:(CGFloat)entryHeight_ mediaData:(LayMediaData *)data label:(NSString *)label_
{
    CGRect frame = CGRectMake(0.0f, 0.0f, entryHeight_, entryHeight_); // the width is recalculated
    self = [super initWithFrame:frame];
    if (self) {
        self->entryHeight = entryHeight_;
        labelText = label_;
        mediaData = data;
        superIdentifier = NO_SUBMENU_ENTRY_IDENTIFIER;
        if(label_)
            self.mediaSizeRatio = g_MAX_MEDIA_HEIGHT_RATIO_WITH_LABEL;
        else
            self.mediaSizeRatio = 100.0;

        self.showAnimated = NO;
        self.mediaView = [[LayMediaView alloc]initWithFrame:frame andMediaData:mediaData];
        self.mediaView.zoomable = NO;
        //self.mediaView.alpha = 0.9f;
        self.mediaView.fitToContent = YES;
        [self addSubview:self.mediaView];
        [self addLabel];
        // layout
        [self layoutEntry];
        //
        LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
        //[style makeRoundedBorder:self withBackgroundColor:WhiteTransparentBackground  andBorderColor:ButtonBorderColor];
        self.backgroundColor = [style getColor:WhiteTransparentBackground];
    }
    return self;
}

/**
 An entry should be touchable at all the MediaView and the UILabel. If the 
 label is interactive(userInteractionEnabled=YES) its touchable but the touch-event is
 forwarded as an touch from an UILabel to the ScrollView and not as LayMenuEntry.
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = nil;
    BOOL anSubviewWasTouched = [self pointInside:point withEvent:event];
    /*for (UIView *subview in self.subviews) {
        if([subview pointInside:point withEvent:event]) {
            anSubviewWasTouched = YES;
            break;
        }
    }*/
    if(anSubviewWasTouched) view = self;
    return view;
}

-(void) addLabel {
    if(self.labelText != nil) {
        LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
        self.label = [[UILabel alloc]initWithFrame:self.frame];
        self.label.text = self.labelText;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [style getColor:ButtonSelectedColor];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.userInteractionEnabled = YES;
        //self.label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.6];
        [self addSubview:self.label];
    }
}

-(void) setMediaSizeRatio:(CGFloat)mediaSizeRatio_ {
    mediaSizeRatio = mediaSizeRatio_;
    if(self.labelText == nil) mediaSizeRatio = 100;
    else {
        if(mediaSizeRatio < 0 || mediaSizeRatio > g_MAX_MEDIA_HEIGHT_RATIO_WITH_LABEL) {
            mediaSizeRatio = g_MAX_MEDIA_HEIGHT_RATIO_WITH_LABEL;
        }
    }
}

-(void)setBackgroundColor:(UIColor *)backgroundColor_ {
    super.backgroundColor = backgroundColor_;
    self.mediaView.backgroundColor = backgroundColor_;
    //self.mediaView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.6];
}

-(void)layoutEntry {
    // calculate height icon
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    const CGFloat hIndent = [style getHorizontalScreenSpace];
    const CGFloat mediaRatioHeight = self->entryHeight * (self.mediaSizeRatio / 100.0f);
    const CGFloat labelHeight = self->entryHeight - mediaRatioHeight - 2 * g_VERTICAL_SPACE_ICON_LABEL;
    [LayFrame setHeightWith:mediaRatioHeight toView:self.mediaView animated:NO];
    [self.mediaView layoutMediaView];
    if(self.label) {
        // calculate height and width label
        UIFont *labelFont = [style getFont:NormalFont];
        self.label.font = labelFont;
        [self.label sizeToFit]; // fit to the width too
        const CGFloat yPosLabel = mediaRatioHeight + g_VERTICAL_SPACE_ICON_LABEL;
        [LayFrame setYPos:yPosLabel toView:self.label];
        [LayFrame setXPos:hIndent toView:self.label];
        const CGFloat newEntryWidth = self.label.frame.size.width +  2 * hIndent;
        [LayFrame setWidthWith:newEntryWidth toView:self];
        // center media based on the the new width of the entry
        const CGFloat xPosMediaView = (self.frame.size.width - self.mediaView.frame.size.width) / 2;
        [LayFrame setXPos:xPosMediaView toView:self.mediaView];
        const CGFloat yPosMediaView = (self.frame.size.height - self.mediaView.frame.size.height - labelHeight) / 2;
        [LayFrame setYPos:yPosMediaView toView:self.mediaView];
    } else {
        self.mediaView.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f);
    }
}

@end

//
// LayMenuLineLayer
//
@implementation LayMenuLineLayer

static const CGFloat lineMiddleBreak = 6.0f;

@synthesize orientation;

-(id)initWithOrientation:(LayMenuOrientation)orientation_;
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
        //CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.8);
        CGContextSetRGBStrokeColor(context, 0.0, 0.48, 0.71, 1.0);
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
// LayMenuScrollView
//
@implementation LayMenuScrollView

@synthesize imageMenu;

-(void)dealloc {
    MWLogDebug([LayMenuScrollView class], @"dealloc");
}

-(id)initWithFrame:(CGRect)frame_ {
    self = [super initWithFrame:frame_];
    if(self) {
        self.clipsToBounds = NO;
    }
    return self;
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    if(!imageMenu.entriesInteractive) return NO;
    if([view isKindOfClass:[LayMenuEntry class]]) {
        if(!view.hidden) {
            LayMenuEntry* entry = (LayMenuEntry*)view;
            [imageMenu animateTap:entry];
            if(imageMenu.menuDelegate != nil) {
                static BOOL subMenuPresented = NO;
                if(subMenuPresented && [self willShowSubMenuEntryForSuperMenuEntry:entry]) {
                    [self collapseSubMenuEntries:YES];
                }
                subMenuPresented = [self showSubMenuEntryForSuperMenuEntry:entry];
                if(!subMenuPresented) {
                    [imageMenu.menuDelegate entryTapped:entry.identifier];
                }
            } else {
                MWLogWarning([LayMenu class], @"No delegate set. No message send for tap on entry with id:%d", entry.identifier);
            }
        }
    } else {
        MWLogError([LayMenu class], @"There are subviews of an unknown type!");
    }
    return NO;
}

-(BOOL)showSubMenuEntryForSuperMenuEntry:(LayMenuEntry*)superMenuentry {
    BOOL subMenuPresented = NO;
    NSArray *subMenuEntryList = [self subMenuEntryForSuperMenuWithIdentifier:superMenuentry.identifier];
    subMenuPresented = [self showSubMenu:subMenuEntryList forSuperMenuEntry:superMenuentry];

    return subMenuPresented;
}

-(BOOL)showSubMenu:(NSArray*)subMenuList forSuperMenuEntry:(LayMenuEntry*)superMenu {
    BOOL subMenuPresented = NO;
    const NSUInteger numberOfMenus = [subMenuList count];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat lineWidth = [styleGuide getBorderWidth:NormalBorder];
    if( numberOfMenus > 0 ) {
        if( numberOfMenus == 1 ) {
            LayMenuEntry *subMenu1 = [subMenuList objectAtIndex:0];
            if(subMenu1.hidden) {
                subMenuPresented = YES;
                // current position
                subMenu1.hidden = NO;
                subMenu1.userInteractionEnabled = YES;
                CALayer *superMenuEntryLayer = superMenu.layer;
                CALayer *subMenuEntryLayer = subMenu1.layer;
                subMenuEntryLayer.position = superMenuEntryLayer.position;
                CALayer *line = [[CALayer alloc]init];
                line.name = (NSString*)lineLayerName;
                line.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
                line.bounds = CGRectMake(0.0f,0.0f,lineWidth,0.0f);
                const CGFloat newYPosSubMenuEntry = superMenuEntryLayer.position.y - subMenuEntryLayer.bounds.size.height - g_DEFAULT_ENTRY_SPACE;
                const CGFloat newXPosSubMenuEntry = subMenuEntryLayer.position.x;
                const CGPoint newPositionSubMenuEntry = CGPointMake(newXPosSubMenuEntry, newYPosSubMenuEntry);
                line.anchorPoint = CGPointMake(0.5f, 0.0f);
                line.position = CGPointMake(subMenuEntryLayer.bounds.size.width/2, subMenuEntryLayer.bounds.size.height);
                [subMenuEntryLayer addSublayer:line];
                const CGRect newLineBounds = CGRectMake(0.0f,0.0f,lineWidth,g_DEFAULT_ENTRY_SPACE);
                [UIView animateWithDuration:0.2 animations:^{
                    subMenuEntryLayer.position = newPositionSubMenuEntry;
                    line.bounds = newLineBounds;
                }];
            }
        } else if( numberOfMenus == 2 ) {
            LayMenuEntry *subMenu1 = [subMenuList objectAtIndex:0];
            LayMenuEntry *subMenu2 = [subMenuList objectAtIndex:1];
            if( subMenu1.hidden && subMenu2.hidden ) {
                subMenuPresented = YES;
                subMenu1.hidden = NO;
                subMenu1.userInteractionEnabled = YES;
                CALayer *superMenuEntryLayer = superMenu.layer;
                CALayer *subMenuEntryLayer = subMenu1.layer;
                subMenuEntryLayer.position = superMenuEntryLayer.position;
                CALayer *line = [[CALayer alloc]init];
                line.name = (NSString*)lineLayerName;
                line.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
                line.bounds = CGRectMake(0.0f,0.0f,lineWidth,0.0f);
                const CGFloat newYPosSubMenuEntry = superMenuEntryLayer.position.y - subMenuEntryLayer.bounds.size.height - g_DEFAULT_ENTRY_SPACE;
                const CGFloat newXPosSubMenuEntry = subMenuEntryLayer.position.x;
                const CGPoint newPositionSubMenuEntry = CGPointMake(newXPosSubMenuEntry, newYPosSubMenuEntry);
                line.anchorPoint = CGPointMake(0.5f, 0.0f);
                line.position = CGPointMake(subMenuEntryLayer.bounds.size.width/2, subMenuEntryLayer.bounds.size.height);
                [subMenuEntryLayer addSublayer:line];
                const CGRect newLineBounds = CGRectMake(0.0f,0.0f,lineWidth,g_DEFAULT_ENTRY_SPACE);
                //
                subMenu2.hidden = YES;
                subMenu2.userInteractionEnabled = YES;
                CALayer *subMenuEntryLayer2 = subMenu2.layer;
                subMenuEntryLayer2.position = superMenuEntryLayer.position;
                // show animated menu1 in the first step
                [UIView animateWithDuration:0.2 animations:^{
                    subMenuEntryLayer.position = newPositionSubMenuEntry;
                    subMenuEntryLayer2.position = newPositionSubMenuEntry;
                    line.bounds = newLineBounds;
                } completion:^(BOOL finished) {
                    subMenu2.hidden = NO;
                    const CGFloat newXPosSubMenuEntry = subMenuEntryLayer.position.x - (subMenuEntryLayer.bounds.size.width / 2.0f) - (g_DEFAULT_ENTRY_SPACE / 2.0f);
                    const CGFloat newXPosSubMenuEntry2 = subMenuEntryLayer.position.x + (subMenuEntryLayer.bounds.size.width / 2.0f) + (g_DEFAULT_ENTRY_SPACE / 2.0f);
                    const CGPoint newPositionSubMenuEntry = CGPointMake(newXPosSubMenuEntry, newYPosSubMenuEntry);
                    const CGPoint newPositionSubMenuEntry2 = CGPointMake(newXPosSubMenuEntry2, newYPosSubMenuEntry);
                    const CGPoint vertLinePosition = CGPointMake( line.position.x + (subMenuEntryLayer.bounds.size.width / 2.0f) + (g_DEFAULT_ENTRY_SPACE / 2.0f), line.position.y );
                    // Prepare horizontal line
                    CALayer *horizontalLine = [[CALayer alloc]init];
                    horizontalLine.name = (NSString*)lineLayerName;
                    horizontalLine.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
                    horizontalLine.bounds = CGRectMake(0.0f,0.0f,0.0f,lineWidth);
                    horizontalLine.anchorPoint = CGPointMake(0.0f, 1.0f);
                    horizontalLine.position = CGPointMake(subMenuEntryLayer.bounds.size.width, subMenuEntryLayer.bounds.size.height);
                    const CGRect horizontalLineBounds = CGRectMake(0.0f,0.0f,g_DEFAULT_ENTRY_SPACE,lineWidth);
                    [subMenuEntryLayer addSublayer:horizontalLine];
                    [UIView animateWithDuration:0.2 animations:^{
                        subMenuEntryLayer.position = newPositionSubMenuEntry;
                        subMenuEntryLayer2.position = newPositionSubMenuEntry2;
                        line.position = vertLinePosition;
                        horizontalLine.bounds = horizontalLineBounds;
                    } ];
                }];
            }
        } else {
            MWLogError( [LayMenu class], @"More than two subMenus are not allowed!" );
        }
    }
    return subMenuPresented;
}

-(BOOL)willShowSubMenuEntryForSuperMenuEntry:(LayMenuEntry*)superMenuentry {
    BOOL willPresentSubMenu = NO;
    NSArray *subMenuEntryList = [self subMenuEntryForSuperMenuWithIdentifier:superMenuentry.identifier];
    if( [subMenuEntryList count] > 0 ) {
        LayMenuEntry *subMenuEntry = [subMenuEntryList objectAtIndex:0];
        if(subMenuEntry) {
            if(subMenuEntry.hidden) {
                willPresentSubMenu = YES;
            }
        }
    }
    return willPresentSubMenu;
}

-(void)collapseSubMenuEntries:(BOOL)animated {
    for (UIView* subView in [self subviews]) {
        if([subView isKindOfClass:[LayMenuEntry class]]) {
            LayMenuEntry* menuEntry = (LayMenuEntry*)subView;
            if(menuEntry.superIdentifier!=NO_SUBMENU_ENTRY_IDENTIFIER && !menuEntry.hidden) {
                CALayer *subMenuEntryLayer = menuEntry.layer;
                const CGPoint positionSubMenuEntry = CGPointMake(subMenuEntryLayer.position.x, subMenuEntryLayer.position.y + subMenuEntryLayer.bounds.size.height + g_DEFAULT_ENTRY_SPACE);
                if(animated) {
                    [UIView animateWithDuration:0.3 animations:^{
                        subMenuEntryLayer.position = positionSubMenuEntry;
                    } completion:^(BOOL finished){
                        subMenuEntryLayer.position = positionSubMenuEntry;
                        menuEntry.hidden = YES;
                        menuEntry.userInteractionEnabled = NO;
                        [self sendSubviewToBack:menuEntry];
                    }];
                } else {
                    subMenuEntryLayer.position = positionSubMenuEntry;
                    menuEntry.hidden = YES;
                    menuEntry.userInteractionEnabled = NO;
                    [self sendSubviewToBack:menuEntry];
                }
                
                for (CALayer *layer in [[[menuEntry layer] sublayers] copy]) {
                    if( [layer.name isEqualToString:(NSString*)lineLayerName] ) {
                        [layer removeFromSuperlayer];
                    }
                }
            }
        }
    }
}

-(NSArray*)subMenuEntryForSuperMenuWithIdentifier:(NSInteger)superIdentifier {
    NSMutableArray *subMenuEntryList = [NSMutableArray arrayWithCapacity:2];
    for (UIView* subView in [self subviews]) {
        if([subView isKindOfClass:[LayMenuEntry class]]) {
            LayMenuEntry* menuEntry = (LayMenuEntry*)subView;
            if(menuEntry.superIdentifier==superIdentifier) {
                [subMenuEntryList addObject:menuEntry];
            }
        }
    }
    return subMenuEntryList;
}

-(void) layoutEntriesHorizontal {
    NSArray *lineLayerList = [[self.layer sublayers]copy];
    for (CALayer* layer in lineLayerList) {
        if([layer.name isEqualToString:(NSString*)lineLayerName]) {
            [layer removeFromSuperlayer];
        }
    }
    // center entries vertically
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat lineHeight = [styleGuide getBorderWidth:NormalBorder];
    CGFloat menuHeight = self.frame.size.height;
    const CGFloat yPos = menuHeight - imageMenu.entryHeight;
    CGFloat nextPosX = 0.0f;
    CGFloat nextLinePosX = 0.0f;
    const CGFloat linePosY = yPos + (imageMenu.entryHeight / 2);
    BOOL firstEntry = YES;
    const NSInteger tagUnkownView = 0;
    NSArray *entryList = self.subviews;
    for (UIView* entry in entryList) {
        if(entry.tag == tagUnkownView) continue;
        if(entry.hidden) {
            [LayFrame setYPos:linePosY toView:entry];
            [LayFrame setXPos:nextPosX toView:entry];
            [self sendSubviewToBack:entry];
            continue;
        }
        CGRect entryFrame = entry.frame;
        if(firstEntry) entryFrame.origin.x = imageMenu.space / 2;
        else entryFrame.origin.x = nextPosX;
        entryFrame.origin.y = yPos;
        entry.frame = entryFrame;
        if(((LayMenuEntry*)entry).showAnimated) {
            [self showEntryAnimated:entry];
        }
        if(!firstEntry) {
            CALayer *line = [[CALayer alloc]init];
            line.name = (NSString*)lineLayerName;
            line.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
            line.frame = CGRectMake(nextLinePosX,linePosY,imageMenu.space,lineHeight);
            [self.layer addSublayer:line];
        }
        firstEntry = NO;
        nextPosX = entryFrame.origin.x + entryFrame.size.width + imageMenu.space;
        nextLinePosX = entryFrame.origin.x + entryFrame.size.width;
    }
    [self setContentSize:CGSizeMake(nextPosX, menuHeight)];
}

-(void)showEntryAnimated:(UIView*)entry {
    CABasicAnimation *animation = [CABasicAnimation
     animationWithKeyPath:@"transform"];
     CATransform3D scaleMatrix = CATransform3DMakeScale(1.1f, 1.1f, 1.0f);
     CATransform3D identMatrix = CATransform3DIdentity;
     NSValue *scaleMatrixNsValue = [NSValue valueWithCATransform3D:scaleMatrix];
     NSValue *identMatrixNsValue = [NSValue valueWithCATransform3D:identMatrix];
     [animation setFromValue:identMatrixNsValue];
     [animation setToValue:scaleMatrixNsValue];
     [animation setDuration:1.0f];
     CALayer *layer = entry.layer;
     // Start the animation
     [CATransaction begin];
     [layer addAnimation:animation forKey:@"scaleUp"];
     [CATransaction commit];

}

@end



@implementation LayMenuScrollViewDelegate

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    LayMenuScrollView *menuScrollView = (LayMenuScrollView*)scrollView;
    [menuScrollView collapseSubMenuEntries:YES];
}

@end



