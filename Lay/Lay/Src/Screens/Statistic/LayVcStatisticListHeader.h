//
//  LayVcCatalogHeader.h
//  Lay
//
//  Created by Rene Kollmorgen on 18.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayStatisticListHeader.h"

@class Media;
@interface LayVcStatisticListHeader : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *catalogTitle;
@property (nonatomic, weak) id<LayStatisticListHeader> delegate;


-(void)setCover:(Media *)cover_;

@end
