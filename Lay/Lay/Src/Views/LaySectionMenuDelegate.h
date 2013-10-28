//
//  LaySectionMenuDelegate.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 04.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LaySectionMenuDelegate <NSObject>
@required
-(void)sectionSelected:(NSUInteger)section;
-(void)scrollToTop;
-(BOOL)isOnTop;
@end
