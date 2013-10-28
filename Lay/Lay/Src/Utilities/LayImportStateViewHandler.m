//
//  LayImportStateViewHandler.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 02.09.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayImportStateViewHandler.h"
#import "LayImportStateView.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"

#import "MWLogging.h"

static const NSInteger TAG_STATE_VIEW = 7001;
static const NSInteger TAG_BACKGROUND_STATE_VIEW = 7002;


@implementation LayImportStateViewHandler

@synthesize delegate, startWorkInSeparateThread, buttonText, useTimerForSteps, busy;

-(id)initWithSuperView:(UIView*)superView_ icon:(UIImage*)icon_ andText:(NSString*)text_ {
    self = [super init];
    if(self) {
        self->superView = superView_;
        self->icon = icon_;
        self->text = text_;
        self.startWorkInSeparateThread = YES;
        self.busy = NO;
    }
    return self;
}

-(void)startWork {
    self->maxSteps = 0;
    self->currentStep = 0;
    [self setupStateViewWithView:self->superView text:self->text andIcon:self->icon];
    if(self.delegate) {
        if(self.startWorkInSeparateThread) {
            MWLogDebug([LayImportStateViewHandler class], @"Start delegate in separate thread!");
            [self performSelectorInBackground:@selector(executeDelegate) withObject:nil];
            if(self.useTimerForSteps) {
                self->stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateStep) userInfo:nil repeats:YES];
            }
        } else {
            
        }
    } else {
        MWLogError([LayImportStateViewHandler class], @"Delegete is not set!");
    }
}

//
// LayImportStateViewDelegate
//
-(void) buttonPressed {
    if(self.delegate) {
        [self.delegate buttonPressed];
    }
}

//
// LayImportProgressDelegate
//
-(void)setMaxSteps:(NSUInteger)maxSteps_ {
    self->maxSteps = maxSteps_;
}

-(void)setStep:(NSUInteger)step {
    self->currentStep = step;
    [self performSelectorOnMainThread:@selector(updateProgressView) withObject:nil waitUntilDone:NO];
}

-(void)startingNextProgressPartWithIdentifier:(NSInteger)identifiier {
    
}

//
// Private
//
-(void)executeDelegate {
    self.busy = YES;
    NSString * errorMessage = [self.delegate startWork:self];
    if(self.useTimerForSteps && self->stepTimer) {
        [self->stepTimer invalidate];
        self->stepTimer = nil;
    }
    if(errorMessage) {
        [self performSelectorOnMainThread:@selector(setErrorStateOfProgressViewWith) withObject:errorMessage waitUntilDone:NO]; 
    } else {
        [self performSelectorOnMainThread:@selector(setProgressViewComplete) withObject:nil waitUntilDone:NO];
        [NSThread sleepForTimeInterval:1.5];
        [self performSelectorOnMainThread:@selector(closeStateView) withObject:nil waitUntilDone:NO];
    }
   
}

-(void)updateStep {
    self->currentStep++;
    [self setStep:self->currentStep];
}

-(void)setupStateViewWithView:(UIView*)view text:(NSString*)text_ andIcon:(UIImage*)icon_ {
    const CGRect backgroundFrame = view.frame;
    UIView *backgroundView = [[UIView alloc]initWithFrame:backgroundFrame];
    backgroundView.tag = TAG_BACKGROUND_STATE_VIEW;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    backgroundView.backgroundColor = [styleGuide getColor:GrayTransparentBackground];
    NSString *buttonText_ = @"OK";
    LayImportStateView *importStateView = [[LayImportStateView alloc]initWithWidth:backgroundFrame.size.width icon:icon_ andButtonText:buttonText_];
    importStateView.backgroundColor = [styleGuide getColor:WhiteBackground];
    importStateView.delegate = self;
    [importStateView setLabelText:text_];
    importStateView.tag = TAG_STATE_VIEW;
    const CGFloat vSpace = 20.0f;
    const CGFloat heightStateViewContainer = importStateView.frame.size.height + 2 * vSpace;
    const CGRect stateViewContainerRect = CGRectMake(0.0f, 0.0f, backgroundFrame.size.width, heightStateViewContainer);
    UIView *importStateViewContainer = [[UIView alloc]initWithFrame:stateViewContainerRect];
    importStateViewContainer.backgroundColor = [styleGuide getColor:WhiteBackground];
    importStateView.center = importStateViewContainer.center;
    [importStateViewContainer addSubview:importStateView];
    // prepare animation
    importStateViewContainer.center = backgroundView.center;
    importStateViewContainer.clipsToBounds = YES;
    const CGFloat heightImportStateView = importStateViewContainer.frame.size.height;
    [LayFrame setHeightWith:0.0f toView:importStateViewContainer animated:NO];
    [backgroundView addSubview:importStateViewContainer];
    [view addSubview:backgroundView];
    // animation
    const CGFloat widthImportStateView = importStateViewContainer.frame.size.width;
    CALayer *importStateViewLayer = importStateViewContainer.layer;
    importStateViewLayer.position = view.layer.position;
    [UIView animateWithDuration:0.4 animations:^{
        importStateViewLayer.position = view.layer.position;
        importStateViewLayer.bounds = CGRectMake(0.0f, 0.0f, widthImportStateView, heightImportStateView);
    }];
}

-(void)updateProgressView {
    LayImportStateView *importStateView = (LayImportStateView *)[self->superView viewWithTag:TAG_STATE_VIEW];
    CGFloat stepProgress = (CGFloat)self->currentStep / (CGFloat)self->maxSteps;
    UIProgressView *progressView = importStateView.progressView;
    if(progressView) {
        [progressView setProgress:stepProgress animated:YES];
    }
}

-(void)updateLabelTextOfProgressView:(NSString*)text_ {
    self->text = text_;
    LayImportStateView *importStateView = (LayImportStateView *)[self->superView viewWithTag:TAG_STATE_VIEW];
    if(importStateView) {
        [importStateView setLabelText:text_];
    }
}

-(void)setErrorStateOfProgressViewWith:(NSString*)text_ {
    self->text = text_;
    LayImportStateView *importStateView = (LayImportStateView *)[self->superView viewWithTag:TAG_STATE_VIEW];
    if(importStateView) {
        [importStateView showErrorStateWithText:text_];
    }
}

-(void)setProgressViewComplete {
    LayImportStateView *importStateView = (LayImportStateView *)[self->superView viewWithTag:TAG_STATE_VIEW];
    [importStateView.progressView setProgress:1.0f animated:YES];
}

-(void)closeStateView {
    UIView *backgroundView = [self->superView viewWithTag:TAG_BACKGROUND_STATE_VIEW];
    if(backgroundView) {
        [backgroundView removeFromSuperview];
    }
    self.busy = NO;
    if(self.delegate) {
        [self.delegate closedStateView];
    }
}


@end
