//
//  LayVcQuestion.h
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayQuestionViewDelegate.h"
#import "LayQuestionDatasource.h"
#import "LayAnswerViewManager.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"

@interface LayVcQuestion : UIViewController<LayQuestionViewDelegate, UIActionSheetDelegate>

-(void)stopQuestionSessionToImportCatalog;

@end
