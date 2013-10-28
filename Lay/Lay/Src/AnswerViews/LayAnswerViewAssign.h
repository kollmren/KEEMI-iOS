//
//  LayAnswerViewMultipleChoice.h
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayAnswerView.h"
#import "LayAnswerItemView.h"
#import "LayImageRibbonDelegate.h"

@interface LayAnswerViewAssign : UIView<LayAnswerView, LayAnswerItemViewDelegate, LayAnswerItemViewSolutionDelegate, LayImageRibbonDelegate>

@end
