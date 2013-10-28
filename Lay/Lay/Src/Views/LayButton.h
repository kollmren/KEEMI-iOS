//
//  LayButton.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 15.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayButtonDelegate.h"

@class LayMediaData;
@interface LayButton : UIButton

@property (nonatomic) NSString* label;
@property (nonatomic) NSString* addionalDetailInfoText;
@property (nonatomic) BOOL isSelectable;
@property (nonatomic) BOOL showMediaWithBorder;
@property (nonatomic) BOOL topBottomLayer;
@property (nonatomic) id resource;
@property (nonatomic) id<LayButtonDelegate> delegate;
@property (nonatomic) UIColor *normalBackgroundColor;

-(id)initWithFrame:(CGRect)frame label:(NSString*)label font:(UIFont*)font andColor:(UIColor*)color;

-(id)initWithFrame:(CGRect)frame label:(NSString*)label_ mediaData:(LayMediaData*)mediaData font:(UIFont*)font_ andColor:(UIColor*)color;

-(void)fitToContent;

-(void)fitToHeight;

-(void)addAddionalInfo:(NSString*)text asBubble:(BOOL)asBubble;

-(void)addText:(NSString*)text;

-(void)showTopBorderOnly;

-(void)hiddeBorders:(BOOL)yesNo;

@end
