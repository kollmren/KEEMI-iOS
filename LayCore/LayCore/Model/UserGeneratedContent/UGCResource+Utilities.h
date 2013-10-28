//
//  UGCResource+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 09.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "UGCResource.h"
#import "LayResourceType.h"

@interface UGCResource (Utilities)

-(void)setResourceType:(NSUInteger)type;

-(LayResourceTypeIdentifier) resourceType;

-(BOOL)linkedWithExplanationWithName:(NSString*)nameOfExplanation;

-(BOOL)linkedWithQuestionWithName:(NSString*)nameOfQuestion;

-(NSArray*)questionList;

-(NSArray*)explanationList;

@end
