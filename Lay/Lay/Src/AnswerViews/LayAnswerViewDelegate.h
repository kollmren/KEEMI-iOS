//
//  LayAnswerViewDelegate.h
//  Lay
//
//  Created by Rene Kollmorgen on 15.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LayAnswerViewDelegate <NSObject>
@required
-(void)resizedToSize:(CGSize)newAnswerViewSize;
-(void)evaluate;

@optional
-(void)scrollToPoint:(CGPoint)point showingHeight:(CGFloat)height;

-(void)scrollToTop;

@end
