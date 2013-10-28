//
//  LayAnswerButtonDelegate.h
//  Lay
//
//  Created by Rene Kollmorgen on 11.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LayAnswerButton;
@protocol LayAnswerButtonDelegate <NSObject>

@required
-(void)tapped:(LayAnswerButton*)answerButtonn wasSelected:(BOOL)wasSelected;

// Is called when the button changed its size e.g. when the info-icon is shown. 
-(void) resized;

@end
