//
//  LayCatalogAbstractListCell.h
//  Lay
//
//  Created by Rene Kollmorgen on 23.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Resource;
@protocol LayResourceCellDelegate <NSObject>

@required
-(void)editResource:(Resource*)resource;

@end

//
//
//
extern const NSString* const resourceCellIdentifier;

@interface LayResourceCell : UITableViewCell

@property (nonatomic, weak) id<LayResourceCellDelegate> delegate;

@property (nonatomic) BOOL canOpenLinkedQuestionsOrExplanations;

+(CGFloat) heightForResource:(Resource*)resource;

@property (nonatomic) Resource* resource;

@end
