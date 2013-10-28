//
//  LayImportStateViewHandler.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 02.09.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayImportStateView.h"
#import "LayImportProgressDelegate.h"

//
// LayImportStateViewHandlerDelegate
//
@protocol LayImportStateViewHandlerDelegate <NSObject>

@required
// returns an error-message if an error occurres otherwise nil
-(NSString*)startWork:(id<LayImportProgressDelegate>)progressDelegate;

-(void)buttonPressed;

-(void)closedStateView;

@end


//
// LayImportStateViewHandler
//
@interface LayImportStateViewHandler : NSObject<LayImportStateViewDelegate, LayImportProgressDelegate> {
    @private
    NSUInteger maxSteps;
    NSUInteger currentStep;
    UIView *superView;
    NSString *text;
    UIImage *icon;
    NSTimer *stepTimer;
}

@property (nonatomic) id<LayImportStateViewHandlerDelegate> delegate;
@property (nonatomic) BOOL startWorkInSeparateThread;
@property (nonatomic) BOOL useTimerForSteps;
@property (nonatomic) NSString* buttonText;
@property (nonatomic) BOOL busy;

-(id)initWithSuperView:(UIView*)superView icon:(UIImage*) icon andText:(NSString*)text;

-(void)startWork;

@end
