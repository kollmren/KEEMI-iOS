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
    MENU_LEARN = 1,
    MENU_QUERY,
    MENU_QUERY_BY_TOPIC,
    MENU_LEARN_BY_TOPIC,
    MENU_CREDITS,
    MENU_FAVOURITES,
    MENU_NOTES,
    MENU_STATISTIC,
    MENU_RESOURCE,
    MENU_SHARE
} MenuEntryIdentifiers;

@interface LayVcCatalogListHeader : UIViewController {
    @private
    BOOL appearsFirstTime;
    BOOL userBoughtProVersion;
}

@property (weak, nonatomic) IBOutlet UILabel *catalogTitle;
@property (nonatomic, readonly) LayMenu* menu;

@end
