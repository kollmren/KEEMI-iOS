//
//  LayVcSearchViewController.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 17.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayVcNavigationBarDelegate.h"

@class LayButton;
@interface LayVcSearchViewController : UITableViewController<UISearchDisplayDelegate, UISearchBarDelegate, LayVcNavigationBarDelegate> {
    LayButton *startSessionButton;
}

@end
