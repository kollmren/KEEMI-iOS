//
//  LayCatalogMenu.h
//  Lay
//
//  Created by Rene Kollmorgen on 16.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayVBoxView.h"
#import "LayImageRibbonDelegate.h"

typedef enum RibbonOrientation_ {
    HORIZONTAL,
    VERTICAL
} RibbonOrientation;

@class LayMediaData;
@interface LayImageRibbon : UIView<LayVBoxView>

@property (nonatomic) CGRect frame;
// default is NO, if yes entries are centered and moved in page-mode of
// the scrollview
@property (nonatomic) BOOL pageMode;
// Specify the space between the entries(effects only in non page-mode)
@property (nonatomic) CGFloat space;
// The orientation of the menu
@property (nonatomic,readonly) RibbonOrientation orientation;
//
@property (nonatomic) BOOL entriesInteractive;
@property (nonatomic) BOOL animateTap;
//
@property (nonatomic) CGSize entrySize;
@property (nonatomic) UIColor* entryBackgroundColor;
// How much percent the icon uses from the size of the menu entry;
@property (nonatomic) NSInteger imageSizeRatio;
//
@property (nonatomic,weak) id<LayImageRibbonDelegate> ribbonDelegate;

// Initializer
- (id)initWithFrame:(CGRect)frame entrySize:(CGSize)entrySize andOrientation:(RibbonOrientation) orientation;

-(void) addEntry:(LayMediaData*)data withIdentifier:(NSInteger)identifier;

-(void)layoutRibbon;

-(void)fitHeightOfRibbonToEntryContent;

-(void) addEntryWithImage:(UIImage*)image withIdentifier:(NSInteger)identifier;

-(void) removeAllEntries;
//
-(NSUInteger) numberOfEntries;
// methods which can be uses in PageMode
// Returns YES if there are more pages available.
-(BOOL)nextPage;
-(BOOL)previousPage;
-(void) showEntryWithIdentifier:(NSUInteger)identfier;
-(void)showPage:(NSUInteger)pageNumber;
-(NSInteger)currentPageNumber;
-(NSInteger)entryIdentifierForCurrentPage;
-(NSUInteger)pageNumberForEntry:(NSInteger)entryIdentifier;
-(CGPoint)midPositionOfPageIndicatorOfPage:(NSInteger)pageNumber;
//
// protocol LayVBoxView
//
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;

@end
