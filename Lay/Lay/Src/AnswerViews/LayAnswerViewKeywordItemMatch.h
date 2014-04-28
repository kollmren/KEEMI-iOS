//
//  LayAnswerViewCard.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 05.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayAnswerView.h"
#import "LayAnswerViewDelegate.h"

@interface LayAnswerViewKeywordItemMatch : UIView<LayAnswerView, UITextFieldDelegate>

@property (nonatomic,weak) id<LayAnswerViewDelegate> answerViewDelegate;

@end
