//
//  LayVcCatalogDetail.h
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayVcNavigationBarDelegate.h"
#import "LayStatisticListHeader.h"
#import "LaySectionMenuDelegate.h"

extern const NSString* const abstractCellIdentifier;
extern const NSString* const abstractCellIntroQuestionIdentifier;

@class LayStatisticFetchedResultsController;
@interface LayVcStatisticList : UITableViewController<LayVcNavigationBarDelegate,
    UITableViewDelegate,
    NSFetchedResultsControllerDelegate,
    LayStatisticListHeader,
    LaySectionMenuDelegate>

@property (nonatomic, strong) LayStatisticFetchedResultsController *fetchedResultsController;

- (id)init;

@end
