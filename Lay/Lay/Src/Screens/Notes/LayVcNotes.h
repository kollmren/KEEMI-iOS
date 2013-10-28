//
//  LayVcCatalogDetail.h
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayVcNavigationBarDelegate.h"
#import "LayNoteCell.h"

@class Catalog;
@class Explanation;
@class Question;
@interface LayVcNotes : UITableViewController<UITableViewDataSource, UITableViewDelegate, LayVcNavigationBarDelegate, UITextViewDelegate, LayNoteCellDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate>

-(id)initWithCatalog:(Catalog*)catalog;

-(id)initWithExplanation:(Explanation*)explanation;

-(id)initWithQuestion:(Question*)question;

@end
