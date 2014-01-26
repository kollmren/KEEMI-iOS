//
//  LayCatalogAbstractListCell.h
//  Lay
//
//  Created by Rene Kollmorgen on 23.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UGCNote;
@protocol LayNoteCellDelegate <NSObject>

@required
-(void)editNote:(UGCNote*)note;

@end

//
//
//
extern const NSString* const noteCellIdentifier;

@interface LayNoteCell : UITableViewCell

@property (nonatomic, weak) id<LayNoteCellDelegate> delegate;

@property (nonatomic) BOOL canOpenLinkedQuestionsOrExplanations;

+(CGFloat) heightForNote:(UGCNote*)note;

@property (nonatomic) UGCNote* note;

-(CGPoint)imageNotePosition;

@end
