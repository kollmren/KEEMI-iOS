//
//  LayScrollMenuDelegate.h
//  Lay
//
//  Created by Rene Kollmorgen on 17.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//
//
@protocol LayImageRibbonDelegate <NSObject>

@optional

-(void)entryTapped:(NSInteger)identifier;

-(void)scrolledToPage:(NSInteger)page;

@end
