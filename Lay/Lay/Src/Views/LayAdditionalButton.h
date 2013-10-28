//
//  LayAdditionalButton.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 11.09.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGSize additionalButtonSize;

@interface LayAdditionalButton : UIView {
    @public
    UIButton* button;
}

- (id)initWithPosition:(CGPoint)position;

@end
