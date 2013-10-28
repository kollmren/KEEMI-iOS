//
//  LayExplanationView.h
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayExplanationViewDelegate.h"
#import "LayExplanationDatasource.h"
#import "LayExplanationViewDelegate.h"

@interface LayExplanationSessionView : UIView {
    Explanation* currentExplanation;
}

-(void)viewCanAppear;

@property (nonatomic,weak) id<LayExplanationViewDelegate> explanationViewDelegate;

@property (nonatomic,weak) id<LayExplanationDatasource> explanationDatasource;

@property (nonatomic,readonly) UIToolbar* toolbar;

-(void)showMiniIconsForExplanation;

-(void)viewWillAppear;

@end
