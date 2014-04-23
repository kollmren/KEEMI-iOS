//
//  LayTextField.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 23.04.14.
//  Copyright (c) 2014 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayTextField : UIView {
@public
    UITextField *textField;
    
@private
    CALayer *leftLayer;
    CALayer *correctIconLayer;
}

@property (nonatomic) BOOL isCorrect;

-(id)initWithPosition:(CGPoint)position andWidth:(CGFloat)width;

@end
