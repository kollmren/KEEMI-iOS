//
//  LayDataFileDummy.h
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Catalog+Utilities.h"

// The data of an catalof-file hard coded.
@protocol LayDataFileDummy <NSObject>

@required

-(void)data:(Catalog*)catalog;

-(NSString*)titleOfCatalog;
-(NSString*)nameOfPublisher;
// The number of questions to generate
-(void)setNumberOfQuestions:(NSInteger)num;
-(NSInteger) numberOfQuestions;

@end
