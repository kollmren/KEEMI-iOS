//
//  LayVcCatalogHeader.h
//  Lay
//
//  Created by Rene Kollmorgen on 18.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayMenu.h"

typedef enum MenuEntryIdentifiers_ {
    MENU_LEARN,
    MENU_QUERY,
    MENU_QUERY_BY_TOPIC,
    MENU_LEARN_BY_TOPIC,
    MENU_CREDITS,
    MENU_STATISTIC,
    MENU_RESOURCE
} MenuEntryIdentifiers;

@interface LayVcFavouriteListHeader : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *catalogTitle;
@property (nonatomic) UILabel *summaryLabel;

@end
