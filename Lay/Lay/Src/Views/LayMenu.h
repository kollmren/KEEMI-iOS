//
//  LayCatalogMenu.h
//  Lay
//
//  Created by Rene Kollmorgen on 16.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayVBoxView.h"
#import "LayMenuDelegate.h"

typedef enum LayMenuOrientation_ {
    HORIZONTAL,
    VERTICAL
} LayMenuOrientation;

@class LayMediaData;
@interface LayMenu : UIView<LayVBoxView>

@property (nonatomic) CGRect frame;
// Specify the space between the entries(effects only in non page-mode)
@property (nonatomic) CGFloat space;
// The orientation of the menu
@property (nonatomic,readonly) LayMenuOrientation orientation;
//
@property (nonatomic) BOOL entriesInteractive;
//
@property (nonatomic) CGFloat entryHeight;
@property (nonatomic) UIColor* entryBackgroundColor;
// How much percent the icon uses from the size of the menu entry;
@property (nonatomic) NSInteger imageSizeRatio;
//
@property (nonatomic,weak) id<LayMenuDelegate> menuDelegate;

// Initializer
- (id)initWithFrame:(CGRect)frame entryHeight:(CGFloat)entryHeight andOrientation:(LayMenuOrientation) orientation;

-(void)removeEntry:(NSInteger)identifier;

-(BOOL)hasEntryWithIdentifier:(NSInteger)identifier;

-(void) addEntry:(LayMediaData*)data :(NSString*) label identifier:(NSInteger)identifier;

-(void) addEntry:(LayMediaData*)data :(NSString*) label identifier:(NSInteger)identifier nextTo:(NSInteger)identifier animated:(BOOL)animated;

-(void) addSubEntry:(LayMediaData*)data :(NSString*)label identifier:(NSInteger)identifier subIdentifier:(NSInteger)subIdentifier;

-(void) addEntryWithImage:(UIImage*)image :(NSString*) label identifier:(NSInteger)identifier;

-(void) addEntryWithImage:(UIImage*)image :(NSString*) label identifier:(NSInteger)identifier nextTo:(NSInteger)identifier animated:(BOOL)animated;

-(void) addSubEntryWithImage:(UIImage*)image :(NSString*) label identifier:(NSInteger)identifier subIdentifier:(NSInteger)subIdentifier;

-(void) collapseSubMenuEntries;

-(void)touch;
//
// protocol LayVBoxView
//
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;

@end
