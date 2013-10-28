//
//  LayVcCatalogDetail.h
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayVcNavigationBarDelegate.h"
#import "LayResourceCell.h"

@class Catalog;
@class Explanation;
@class Question;
@interface LayVcResource : UITableViewController<UITableViewDataSource, UITableViewDelegate, LayVcNavigationBarDelegate, UITextFieldDelegate, LayResourceCellDelegate>

-(id)initWithCatalog:(Catalog*)catalog;

-(id)initWithExplanation:(Explanation*)explanation;

-(id)initWithQuestion:(Question*)question;

@end
