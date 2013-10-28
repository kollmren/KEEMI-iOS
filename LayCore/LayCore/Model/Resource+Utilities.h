//
//  Resource+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 17.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Resource.h"
#import "LayResourceType.h"

@interface Resource (Utilities)

-(NSNumber*)resourceNumber;

-(NSUInteger)numberAsPrimitive;

-(void)setResourceNumber:(NSUInteger)number;

-(void)setResourceType:(NSUInteger)type;

-(LayResourceTypeIdentifier) resourceType;

-(NSArray*)questionList;

-(NSArray*)explanationList;

@end
