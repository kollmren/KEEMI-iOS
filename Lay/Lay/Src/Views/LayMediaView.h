//
//  LayMediaView.h
//  Lay
//
//  Created by Rene Kollmorgen on 07.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayMediaData.h"

@interface LayMediaView : UIView<UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic) BOOL scaleToFrame;

@property (nonatomic) BOOL border;

@property (nonatomic) CGFloat borderWidth;

@property (nonatomic) BOOL fitToContent;

@property (nonatomic) BOOL showLabel;

@property (nonatomic) BOOL ignoreEvents;

@property (nonatomic) BOOL zoomable;

@property (nonatomic) BOOL showFullscreen;

@property (nonatomic) BOOL fitLabelToFitContent;

- (id)initWithFrame:(CGRect)frame_ andMediaData:(LayMediaData*)mediaData_;

// if any property is set this method must be called
-(void)layoutMediaView;

@end
