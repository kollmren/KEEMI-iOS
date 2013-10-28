//
//  LayTwoColumnTable.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 20.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LayDetailsTable : UIView

@property (nonatomic, readonly) CGFloat hColumnSpace;
@property (nonatomic) CGFloat vRowSpace;

-(id) initWithDictionary:(NSDictionary*)tableData frame:(CGRect)frame andFont:(UIFont*)font;

// list of LayPair objects
-(id)initWithArray:(NSArray*)tableData frame:(CGRect)frame andFont:(UIFont*)font;

@end
