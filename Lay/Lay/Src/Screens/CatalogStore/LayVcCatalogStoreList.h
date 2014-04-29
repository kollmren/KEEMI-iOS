//
//  LayViewController.h
//  Lay
//
//  Created by Rene on 29.10.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayVcNavigationBarDelegate.h"
#import "LayImportStateViewHandler.h"

@interface LayVcCatalogStoreList : UITableViewController<LayVcNavigationBarDelegate, LayImportStateViewHandlerDelegate>

@end