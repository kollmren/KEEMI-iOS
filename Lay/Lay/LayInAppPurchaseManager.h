//
//  LayInAppPurchaseManager.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 04.11.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString *productIdProVersion;

@interface LayInAppPurchaseManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    @private
    NSArray* products;
}

+(LayInAppPurchaseManager*) instance;

-(void)validateProductIdentifiers:(NSArray *)productIdentifiers;

@end
