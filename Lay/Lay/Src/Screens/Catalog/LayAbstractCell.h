//
//  LayCatalogAbstractListCell.h
//  Lay
//
//  Created by Rene Kollmorgen on 23.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSString* const abstractCellIdentifier;
extern const NSString* const abstractCellIntroQuestionIdentifier;

@class Question, Explanation;
@interface LayAbstractCell : UITableViewCell

+(CGFloat) heightForQuestion:(Question*)question;

+(CGFloat) heightForExplanation:(Explanation*)explanation;

@property (nonatomic) Question* question;

@property (nonatomic) Explanation* explanation;

@end
