//
//  LayImportStateView.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 29.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LayImportStateViewDelegate <NSObject>

@optional
-(void) buttonPressed;

@end

@interface LayImportStateView : UIView {
    @private
    CGFloat imgLabelHspace;
    CGFloat unzipStateViewLabelWidth;
}

@property (nonatomic, weak) id<LayImportStateViewDelegate> delegate;
@property (nonatomic, readonly) UIProgressView* progressView;

- (id)initWithWidth:(CGFloat)width icon:(UIImage*)icon andButtonText:(NSString*)buttonText;

-(void)setLabelText:(NSString*)text;

-(void)setIcon:(UIImage *)icon;

-(void)showErrorStateWithText:(NSString*)text;

@end
