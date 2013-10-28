//
//  UGCQuestion+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 01.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "UGCQuestion+Utilities.h"
#import "UGCCatalog+Utilities.h"
#import "LayUserDataStore.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"

#import "MWLogging.h"

@implementation UGCQuestion (Utilities)

-(UGCBoxCaseId)boxCaseId {
    UGCBoxCaseId boxCaseId = UGC_BOX_CASE_NOT_ANSWERED_QUESTION;
    if(self.case1Ref) {
        boxCaseId = UGC_BOX_CASE1;
    } else if(self.case2Ref) {
        boxCaseId = UGC_BOX_CASE2;
    } else if(self.case3Ref) {
        boxCaseId = UGC_BOX_CASE3;
    } else if(self.case4Ref) {
        boxCaseId = UGC_BOX_CASE4;
    } else if(self.case5Ref) {
        boxCaseId = UGC_BOX_CASE5;
    }
    return boxCaseId;
}

@end
