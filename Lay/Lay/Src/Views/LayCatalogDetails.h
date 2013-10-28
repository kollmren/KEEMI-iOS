//
//  LayCatalogDetails.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 13.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LayCatalogFileInfo;
@class Catalog;
@interface LayCatalogDetails : UIView

@property (nonatomic) BOOL showDetailTable;
@property (nonatomic) NSString* additionalInfo;

-(id)initWithCatalogFileInfo:(LayCatalogFileInfo*)catalogFileInfo_ andPositionY:(CGFloat)yPos;

-(id)initWithCatalog:(Catalog*)catalog andPositionY:(CGFloat)yPos;

-(void)showDescription;

-(void)hideDescription;

@end
