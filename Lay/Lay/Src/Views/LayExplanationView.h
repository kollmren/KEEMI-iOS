//
//  LayExplanationView.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 19.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Explanation, Introduction;
@interface LayExplanationView : UIView

-(id)initWithFrame:(CGRect)frame andExplanation:(Explanation*)explanation;

-(id)initWithFrame:(CGRect)frame andIntroduction:(Introduction*)introduction;

@end
