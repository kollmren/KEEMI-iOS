//
//  LayCatalogListItem.h
//  Lay
//
//  Created by Rene Kollmorgen on 07.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat LABEL_V_SPACE;
extern const NSInteger MAX_NUMBER_OF_LINES_TITLE;

@class Media;
@class LayMediaView;
@interface LayMyCatalogListItem : UITableViewCell {
    UILabel *catalogPublisher;
    UILabel *importDate;
}

@property (weak, nonatomic) IBOutlet UILabel *catalogTitle;

-(void)setCover:(Media *)cover title:(NSString *)title publisher:(NSString *)publisher andNumberOfQuestions:(NSString*)numberOfQuestions;

@end
