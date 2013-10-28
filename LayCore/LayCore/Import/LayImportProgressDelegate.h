//
//  LayImportProgressDelegate.h
//  LayCore
//
//  Created by Rene Kollmorgen on 28.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LayImportProgressDelegate <NSObject>

@required
-(void)setMaxSteps:(NSUInteger)maxSteps;

-(void)setStep:(NSUInteger)step;

-(void)startingNextProgressPartWithIdentifier:(NSInteger)identifiier;

@end
