//
//  LayAnswerViewMultipleChoice.m
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerViewAssign.h"
#import "LayVBoxLayout.h"
#import "LayAnswerItemView.h"
#import "LayImageRibbon.h"
#import "LayAnswerViewDelegate.h"
#import "LayInfoDialog.h"
#import "LayStyleGuide.h"
#import "LayAnswerButton.h"
#import "LayFrame.h"

#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "AnswerMedia.h"

#import "MWLogging.h"

//
// LayAssignIndicatorLayerDelegate
//
@interface LayAssignIndicatorLayerDelegate : NSObject
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL showAsHint;
@property (nonatomic) CGPoint midPosPageIndicator;
@end

//
// LayAssignedAnswerItemToMedia
//
@interface LayAssignedIdentPair : NSObject
@property (nonatomic) BOOL assigned;
@property (nonatomic) NSInteger identifier;

+(LayAssignedIdentPair*) makePair:(BOOL)assigned :(NSInteger)identifier;
@end

//
// LayAnswerViewAssign
//
@interface LayAnswerViewAssign() {
    CALayer *assignIndicator;
    LayAssignIndicatorLayerDelegate *assignIndicatorDelegate;
    //
    Answer* answer;
    LayImageRibbon *imageRibbon;
    LayAnswerItemView* answerItemView;
    NSMutableArray* listOfMediaIdentifiers;
    BOOL userSetAnswer;
    BOOL evaluated;
    __weak id<LayAnswerViewDelegate> answerViewDelegate;
}
@end

static const CGFloat g_horizontalBorderOfView = 10.0f; // left and right border

@implementation LayAnswerViewAssign

static const CGFloat VERTICAL_SPACE = 20.0f;
static const NSInteger HEIGTH_EMPTY_RIBBON = 70.0f;
static const NSInteger HEIGTH_FILLED_RIBBON = 190.0f;
static const CGSize SIZE_EMPTY_RIBBON_ENTRY = {0.0, 0.0};
static const NSInteger TAG_IMAGE_RIBBON = 1001;
static const NSInteger NOT_ASSIGNABLE = 100;
static const NSInteger NOT_ASSIGNED_IDENTIFIER = 0;

-(id)initWithFrame:(CGRect)frame {
    CGRect frame_ = frame;
    self = [super initWithFrame:frame_];
    if (self) {
        self->listOfMediaIdentifiers = nil;
        self->evaluated = NO;
        self->imageRibbon = [[LayImageRibbon alloc]initWithFrame:frame entrySize:SIZE_EMPTY_RIBBON_ENTRY andOrientation:HORIZONTAL];
        self->imageRibbon.ribbonDelegate = self;
        self->imageRibbon.tag = TAG_IMAGE_RIBBON;
        self->imageRibbon.pageMode = YES;
        self->imageRibbon.entriesInteractive = NO;
        [self setupLayer];
        [self addSubview:self->imageRibbon];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayAnswerViewAssign class], @"dealloc");
}

-(void)resetView {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    self->answer = nil;
    self->evaluated = NO;
    [self->imageRibbon removeAllEntries];
    self->listOfMediaIdentifiers = nil;
}

-(void) setupLayer {
    self->assignIndicatorDelegate = [[LayAssignIndicatorLayerDelegate alloc] init];
    self->assignIndicator = [[CALayer alloc]init];
    self->assignIndicator.delegate = self->assignIndicatorDelegate;
    CGSize superViewSize = self.frame.size;
    self->assignIndicator.frame = CGRectMake(0.0f, 0.0f, superViewSize.width, VERTICAL_SPACE);
    [self->assignIndicator setNeedsDisplay];
    [self.layer addSublayer:self->assignIndicator];
}

-(void)showAnswerMedia:(Answer*)answer_ {
    NSArray *answerMediaList = [answer_ answerMediaList];
    if(answerMediaList && [answerMediaList count]>0) {
        listOfMediaIdentifiers = [NSMutableArray arrayWithCapacity:[answerMediaList count]];
        NSInteger mediaNotAssignableIdentifierCounter = NOT_ASSIGNABLE;
        self->imageRibbon.frame = CGRectMake(0.0, 0.0, self.frame.size.width, HEIGTH_FILLED_RIBBON);
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self->imageRibbon.entrySize = [styleGuide maxRibbonEntrySize];
        for (AnswerMedia* answerMedia in answerMediaList) {
            AnswerItem* answerItem = answerMedia.answerItemRef;
            NSInteger identifier = 0;
            if(answerItem) {
                identifier = [answerItem.number unsignedIntegerValue];
            } else {
                identifier = mediaNotAssignableIdentifierCounter++;
            }
            LayAssignedIdentPair *mediaIdentPair = [LayAssignedIdentPair makePair:NO :identifier];
            [listOfMediaIdentifiers addObject:mediaIdentPair];
            LayMediaData *mediaData = [LayMediaData byMediaObject:answerMedia.mediaRef];
            [self->imageRibbon addEntry:mediaData withIdentifier:identifier];
        }
        if([self->imageRibbon numberOfEntries]>0) {
            [self->imageRibbon layoutRibbon];
        }
    } else {
        self->imageRibbon.entrySize = SIZE_EMPTY_RIBBON_ENTRY;
        self->imageRibbon.frame = CGRectMake(0.0, 0.0, self.frame.size.width, HEIGTH_EMPTY_RIBBON);
    }
    [self addSubview:self->imageRibbon];
}

-(void) addAnswerItemViewWith:(Answer*)answer_ {
    if(self->answerItemView) {
        [self->answerItemView removeFromSuperview];
        self->answerItemView = nil;
    }
    CGRect ribbonFrame = self->imageRibbon.frame;
    CGFloat yPosAnswerItemView = ribbonFrame.origin.y + ribbonFrame.size.height + VERTICAL_SPACE;
    CGFloat xPosAnswerItemView = g_horizontalBorderOfView;
    CGPoint posAnswerItemView = CGPointMake(xPosAnswerItemView, yPosAnswerItemView);
    CGFloat answerItemViewWidth = self.frame.size.width - 2 * g_horizontalBorderOfView;
    self->answerItemView = [[LayAnswerItemView alloc]initWithPosition:posAnswerItemView
                                                                width:answerItemViewWidth andAnswer:answer_];
    self->answerItemView.itemViewDelegate = self;
    self->answerItemView.itemViewSolutionDelegate = self;
    self->answerItemView.withBackground = NO;
    [self addSubview:self->answerItemView];
    [self showAssignIndicator:NO:NO];
}

-(void)adjustViewsHeight {
    CGRect answerItemViewFrame = self->answerItemView.frame;
    CGFloat newHeight = answerItemViewFrame.origin.y + answerItemViewFrame.size.height;
    [LayFrame setHeightWith:newHeight toView:self animated:NO];
}

-(void) adjustAssignIndicatorLayer {
    CGFloat yPosFrame = self->imageRibbon.frame.origin.y + self->imageRibbon.frame.size.height;
    self->assignIndicator.frame = CGRectMake(0.0f, yPosFrame, self.frame.size.width, VERTICAL_SPACE);
    [self->assignIndicator setNeedsDisplay];
}

-(AnswerItem*)answerItemWithAssignedIdentifier:(NSInteger)identifier {
    AnswerItem* answerItemWithIdentAssignedTo = nil;
    for (AnswerItem *answerItem in [self->answer answerItemListOrderedByNumber]) {
        if([answerItem.sessionData unsignedIntegerValue]==identifier) {
            answerItemWithIdentAssignedTo = answerItem;
        }
    }
    return answerItemWithIdentAssignedTo;
}

-(void) handleUserChoice:(LayAnswerButton*)answerButton :(BOOL)wasSelected {
    if(wasSelected) {
        AnswerItem* answerItem = answerButton.answerItem;
        [self updateAssignedMediaListWith:[answerItem.sessionData unsignedIntegerValue] assigned:NO];
        answerItem.sessionData = [NSNumber numberWithUnsignedInteger:NOT_ASSIGNED_IDENTIFIER];
        [self adjustAssignedIndicator];
    } else {
        NSInteger identifierCurrentPage = [self->imageRibbon entryIdentifierForCurrentPage];
        AnswerItem* answerItemAlreadyAssigned = [self answerItemWithAssignedIdentifier:identifierCurrentPage];
        if(answerItemAlreadyAssigned) {
            // !!!Single mapping supported only!!!
            answerItemAlreadyAssigned.setByUser = [NSNumber numberWithBool:NO];;
            answerItemAlreadyAssigned.sessionData = [NSNumber numberWithUnsignedInteger:NOT_ASSIGNED_IDENTIFIER];
        }
        AnswerItem* answerItem = answerButton.answerItem;
        answerItem.sessionData = [NSNumber numberWithUnsignedInteger:identifierCurrentPage];
        [self updateAssignedMediaListWith:[answerItem.sessionData unsignedIntegerValue] assigned:YES];
        [self adjustAssignedIndicator];
    }
}

-(void)handleSwipeToCurrent:(LayAnswerButton*)answerButton {
    AnswerItem *answerItem = answerButton.answerItem;
    if([answerItem.setByUser boolValue]) {
        /*NSInteger assignedAnswerItemNumber = answerItem.sessionData;
        [self->imageRibbon showEntryWithIdentifier:assignedAnswerItemNumber];
        [self showAssignIndicator:YES:NO];*/
        [self adjustAssignedIndicator];
    } else {
        [self adjustAssignedIndicator];
        /*BOOL notAssignedMediaShown = [self showNotAssignedMediaItem];
        if( NO == notAssignedMediaShown  ) {
            [self adjustAssignedIndicator];
        }*/
    }
}

-(void)handleSwipeToCurrentEvaluated:(LayAnswerButton*)answerButton {
    AnswerItem *answerItem = answerButton.answerItem;
    AnswerMedia *answerMediaItem = [answerItem answerMedia];
    if(answerMediaItem) {
        NSInteger identifier = [answerItem.number unsignedIntegerValue];
        [self->imageRibbon showEntryWithIdentifier:identifier];
        [self showAssignIndicator:YES:NO];
    }
}

-(BOOL) showNotAssignedMediaItem {
    BOOL notAssignedMediaShown = NO;
    for (LayAssignedIdentPair* mediaIdentPair in self->listOfMediaIdentifiers) {
        if(!mediaIdentPair.assigned) {
            [self->imageRibbon showEntryWithIdentifier:mediaIdentPair.identifier];
            notAssignedMediaShown = YES;
            break;
        }
    }
    return notAssignedMediaShown;
}

-(void) updateMidPositionOfPageIncicatorForPage:(NSInteger)page {
    const CGPoint midPositionOfCurrentPageIndicatorRibbon = [self->imageRibbon midPositionOfPageIndicatorOfPage:page];
    const CGPoint midPositionOfCurrentPageIndicatorSelf =
    [self->imageRibbon convertPoint:midPositionOfCurrentPageIndicatorRibbon toView:self];
    self->assignIndicatorDelegate.midPosPageIndicator = midPositionOfCurrentPageIndicatorSelf;
}

-(void) syncAnswerItemWithMedia {
    NSInteger identfierOfMediaInPage = [self->imageRibbon entryIdentifierForCurrentPage];
    for (AnswerItem* answerItem in [self->answer answerItemListOrderedByNumber]) {
        if([answerItem.number unsignedIntegerValue] == identfierOfMediaInPage ) {
            [self showAssignIndicator:YES:NO];
            [self->answerItemView showButtonWith:answerItem];
        }
    }
}

-(void) adjustAssignedIndicator {
    BOOL mediaIsAssigned = NO;
    AnswerItem *answerItemMediaAssignedTo = nil;
    NSInteger identfierOfMediaInPage = [self->imageRibbon entryIdentifierForCurrentPage];
    for (AnswerItem* answerItem in [self->answer answerItemListOrderedByNumber]) {
        if([answerItem.setByUser boolValue] && [answerItem.sessionData unsignedIntegerValue] == identfierOfMediaInPage ) {
            answerItemMediaAssignedTo = answerItem;
            mediaIsAssigned = YES;
            break;
        }
    }
    AnswerItem *currentVisibleAnswerItem = [self->answerItemView currentVisibleAnswerItem];
    if(mediaIsAssigned) {
        if([currentVisibleAnswerItem.number unsignedIntegerValue] == [answerItemMediaAssignedTo.number unsignedIntegerValue]) {
            [self showAssignIndicator:YES:NO];
        } else {
            [self showAssignIndicator:YES:YES];
        }
    } else if([currentVisibleAnswerItem.setByUser boolValue]) {
        NSInteger pageAnswerItemAssignedTo =
                [self->imageRibbon pageNumberForEntry:[currentVisibleAnswerItem.sessionData unsignedIntegerValue]];
        [self showAssignIndicator:YES:YES:pageAnswerItemAssignedTo];
    } else {
        [self showAssignIndicator:NO:NO];
    }
}

-(void)showAssignIndicator:(BOOL)show :(BOOL)asHint {
    NSInteger currentPage = self->imageRibbon.currentPageNumber;
    [self showAssignIndicator:show:asHint:currentPage];
    
}
-(void)showAssignIndicator:(BOOL)show :(BOOL)asHint :(NSInteger)page {
    [self updateMidPositionOfPageIncicatorForPage:page];
    self->assignIndicatorDelegate.showAsHint = asHint;
    self->assignIndicatorDelegate.hidden = !show;
    [self->assignIndicator setNeedsDisplay];
}

-(void)updateAssignedMediaListWith:(NSInteger)identifier assigned:(BOOL)assigned {
    for (LayAssignedIdentPair* mediaIdentPair in self->listOfMediaIdentifiers) {
        if(mediaIdentPair.identifier == identifier) {
            mediaIdentPair.assigned = assigned;
        }
    }
}

//
// LayAnswerView
//
-(id<LayAnswerView>)initAnswerView {
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
}

-(CGSize)showAnswer:(Answer *)answer_ andSize:(CGSize)viewSize userCanSetAnswer:(BOOL)userCanSetAnswer{
    [self resetView];
    [LayFrame setSizeWith:viewSize toView:self];
    self->answer = answer_;
    [self showAnswerMedia:answer_];
    [self addAnswerItemViewWith:answer_];
    [self adjustAssignIndicatorLayer];
    [self adjustViewsHeight];
    return self.frame.size;
}

-(void)showSolution {
    if(self->evaluated) return;
    self->evaluated = YES;
    [self->answerItemView showSolution];
}

-(BOOL)isUserAnswerCorrect {
    BOOL corretAnswer = YES;
    return corretAnswer;
}

-(UIView*)answerView {
    return self;
}

-(BOOL)userSetAnswer {
    BOOL userSetAnAnswer = NO;
    //userSetAnAnswer = [self hasUserSelectedAButton];
    return userSetAnAnswer;
}

-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate {
    self->answerViewDelegate = delegate;
}

//
// LayAnswerItemViewDelegate
//
-(void)tapped:(LayAnswerButton*)answerButton_ wasSelected:(BOOL)wasSelected {
    if(!self->evaluated) {
        [self handleUserChoice:answerButton_ :wasSelected];
    }
}

-(void) swipedTo:(LayAnswerButton*)currentAnswerButton {
    if(self->evaluated) {
        [self handleSwipeToCurrentEvaluated:currentAnswerButton];
    } else {
        [self handleSwipeToCurrent:currentAnswerButton];
    }
}

-(void) resized {
    
}

-(void) minimizedButtonTapped {
    
}

//
// LayImageRibbonDelegate
//
-(void)scrolledToPage:(NSInteger)page {
    if(self->evaluated) {
        [self syncAnswerItemWithMedia];
    } else {
        [self adjustAssignedIndicator];
    }
}

-(void)entryTapped:(NSInteger)identifier {
    
}


//
// LayAnswerItemViewSolutionDelegate
//
-(BOOL)isAnswerItemCorrect:(AnswerItem*)answerItem {
    BOOL isCorrect = NO;
    AnswerMedia *answerMedia = [answerItem answerMedia];
    if(answerMedia) {
        if([answerItem.setByUser boolValue] && [answerItem.sessionData unsignedIntegerValue] == [answerItem.number unsignedIntegerValue]) {
            isCorrect = YES;
        } else {
            // not set by user
            isCorrect = YES;
        }
    }
    return isCorrect;
}

@end


//
// LayAssignIndicatorLayerDelegate
//
@implementation LayAssignIndicatorLayerDelegate

@synthesize hidden, midPosPageIndicator, showAsHint;

- (id)init
{
    self = [super init];
    if (self) {
        self.hidden = YES;
        self.showAsHint = NO;
    }
    return self;
}

-(void) drawLayer:(CALayer*)layer inContext:(CGContextRef)context {
    if(!self.hidden) {
        const CGFloat layerHeight = layer.frame.size.height;
        //const CGFloat radius = 20.0;
        const CGFloat width = 20.0f;
        
        const CGFloat xPosPageIndicator = midPosPageIndicator.x;
        CGContextMoveToPoint(context, xPosPageIndicator - width, layerHeight);
        CGContextAddLineToPoint(context, xPosPageIndicator, 0.0f);
        CGContextAddLineToPoint(context, xPosPageIndicator + width, layerHeight);
        CGContextAddLineToPoint(context, xPosPageIndicator - width, layerHeight);
        
        /*CGContextMoveToPoint(context, layerWidth/2, 0.0f);
         CGContextAddArcToPoint(context, layerWidth/2, layerHeight,(layerWidth/2)-layerHeight, layerHeight, radius);
         CGContextMoveToPoint(context, layerWidth/2, 0.0f);
         CGContextAddArcToPoint(context, layerWidth/2, layerHeight,(layerWidth/2)+layerHeight, layerHeight, radius);
         CGContextSetLineWidth(context, 2.0);
         CGContextStrokePath(context);*/
        if(self.showAsHint) {
            CGContextSetAlpha(context,0.3f);
        }
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        CGContextSetFillColorWithColor(context, [styleGuide getColor:ButtonBorderColor].CGColor );
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFill);
    }
}

@end

@implementation LayAssignedIdentPair
@synthesize assigned, identifier;

+(LayAssignedIdentPair*) makePair:(BOOL)assigned_ :(NSInteger)identifier_ {
    LayAssignedIdentPair *pair = [LayAssignedIdentPair new];
    pair.assigned = assigned_;
    pair.identifier = identifier_;
    return pair;
}
@end
