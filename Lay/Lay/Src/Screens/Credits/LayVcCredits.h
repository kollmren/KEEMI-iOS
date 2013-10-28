//
//  LayVcImport.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 13.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayCatalogDetails.h"
#import "LayVcNavigationBarDelegate.h"

@class Catalog;
@interface LayVcCredits : UIViewController<LayVcNavigationBarDelegate>

-(id)initWithCatalog:(Catalog*)catalog;

@end
