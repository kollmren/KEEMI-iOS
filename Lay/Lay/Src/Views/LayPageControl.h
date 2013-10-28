//
//  LayPageControl.h
//  Lay
//
//  Created by Rene Kollmorgen on 05.04.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LayPageControl : UIView

+(CGFloat)requiredWidthFor:(NSInteger)numberOfPages height:(CGFloat)heightOfPageControl andSpace:(CGFloat)hSpace;

@property (nonatomic) NSInteger numberOfPages;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) CGFloat hSpace;
@property (nonatomic) BOOL hidesForSinglePage;

-(id)initWithPosition:(CGPoint)position height:(CGFloat)height andNumberOfPages:(NSInteger)numberOfPages;

-(CGPoint)midPositionOfPageIndicatorOfPage:(NSInteger)pageNumber;

@end
