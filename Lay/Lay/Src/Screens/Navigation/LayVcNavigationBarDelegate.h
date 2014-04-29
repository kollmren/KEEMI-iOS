//
//  LayVcNavigationBarDelegate.h
//  Lay
//
//  Created by Rene Kollmorgen on 22.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LayVcNavigationBarDelegate <NSObject>

@optional
-(void) searchIconPressed;
-(void) searchFinished;
-(void) cancelPressed;
-(void) learnPressed;
-(void) queryPressed;
-(void) infoPressed;
-(void) backPressed;
-(void) addPressed;
@end
