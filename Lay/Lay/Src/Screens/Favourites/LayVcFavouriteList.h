//
//  LayVcCatalogDetail.h
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayVcNavigationBarDelegate.h"
#import "LayMenuDelegate.h"
#import "LaySectionMenuDelegate.h"

@interface LayVcFavouriteList : UITableViewController<LayVcNavigationBarDelegate,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (id)init;

@end
