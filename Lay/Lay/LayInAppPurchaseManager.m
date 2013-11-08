//
//  LayInAppPurchaseManager.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 04.11.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayInAppPurchaseManager.h"
#import "LayUserDefaults.h"

#import "MWLogging.h"

const NSString *productIdProVersion = @"com.paasq.keemi.keemiproversion";

@implementation LayInAppPurchaseManager

+(LayInAppPurchaseManager*) instance {
    static LayInAppPurchaseManager* instance_ = nil;
    @synchronized(self)
    {
        if (instance_ == NULL) {
            instance_= [[self alloc] init];
        }
    }
    return(instance_);
}

-(void)validateProductIdentifiers:(NSArray *)productIdentifiers {
    self->currentProductsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    self->currentProductsRequest.delegate = self;
    MWLogInfo([LayInAppPurchaseManager class], @"Starting product request...");
    [self->currentProductsRequest start];
}

-(void) restoreTransaction {
    SKPaymentQueue *defaultQueue = [SKPaymentQueue defaultQueue];
    MWLogInfo([LayInAppPurchaseManager class], @"Restore transaction...");
    [defaultQueue restoreCompletedTransactions];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    MWLogError([LayInAppPurchaseManager class], @"Product request failed:%@, Debug:%@", [error description], [error debugDescription] );
    NSString *message = NSLocalizedString(@"InfoBuyProVersionNoConnection", nil);
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}

- (void)requestDidFinish:(SKRequest *)request {
    MWLogDebug([LayInAppPurchaseManager class], @"Product request finished.");
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    MWLogInfo([LayInAppPurchaseManager class], @"Have got product informations.");
    self->products = response.products; // valid products
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        MWLogWarning([LayInAppPurchaseManager class], @"Found invalid product identifier:%@", invalidIdentifier);
    }
    self->currentProductsRequest = nil;
    [self displayStoreUI]; // Custom method
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

-(void)finishTransaction {
    SKPaymentQueue *defaultQueue = [SKPaymentQueue defaultQueue];
    NSArray *pendingTransactions = defaultQueue.transactions;
    for (SKPaymentTransaction *transaction in pendingTransactions) {
        MWLogInfo([LayInAppPurchaseManager class], @"Finish transaction:%@ from:%@.", transaction.transactionIdentifier, [transaction.transactionDate description]);
        [defaultQueue finishTransaction:transaction];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    MWLogError([LayInAppPurchaseManager class], @"User failed buying Pro-Version. Details:%@", [error description]);
    NSString *message = NSLocalizedString(@"InfoBuyProVersionFailed", nil);
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    MWLogInfo([LayInAppPurchaseManager class], @"User restored bought Pro-Version!");
}

-(void)completeTransaction:(SKPaymentTransaction*)transaction {
    //NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    //NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    MWLogInfo([LayInAppPurchaseManager class], @"User bought Pro-Version successfully.");
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:YES forKey:(NSString*)userDidBuyProVersion];
    
    NSString *message = NSLocalizedString(@"InfoBuyProVersionSuccessfully", nil);
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
    [self finishTransaction];
    
}

-(void)failedTransaction:(SKPaymentTransaction*)transaction {
    MWLogError([LayInAppPurchaseManager class], @"User failed buying Pro-Version. Details:%@", [transaction.error debugDescription]);
    NSString *message = NSLocalizedString(@"InfoBuyProVersionFailed", nil);
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
    [self finishTransaction];
}

-(void)restoreTransaction:(SKPaymentTransaction*)transaction {
    MWLogInfo([LayInAppPurchaseManager class], @"User restored bought Pro-Version.");
    if(transaction.originalTransaction) {
        MWLogInfo([LayInAppPurchaseManager class], @"User has already bought the Pro-Version.");
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setBool:YES forKey:(NSString*)userDidBuyProVersion];
        NSString *message = NSLocalizedString(@"InfoBuyProVersionSuccessfully", nil);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    } else {
         MWLogWarning([LayInAppPurchaseManager class], @"User has not bought the Pro-Version yet.");
    }
    
    [self finishTransaction];
}

-(void)displayStoreUI {
    BOOL userCanMakePayments = YES;
    if(![SKPaymentQueue canMakePayments]) {
        userCanMakePayments = NO;
    }
    if([self->products count] == 1) {
        if(userCanMakePayments) {
            MWLogInfo([LayInAppPurchaseManager class], @"User is authorized to make payments!");
            SKProduct *product = [self->products objectAtIndex:0];
            if([product.productIdentifier isEqualToString:(NSString*)productIdProVersion]) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:product.priceLocale];
                NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
                NSString *title = product.localizedTitle;
                NSString *description = product.localizedDescription;
                
                NSString *buyButtonFormat = NSLocalizedString(@"InfoBuyButton", nil);
                NSString *buyButtonText = [NSString stringWithFormat:buyButtonFormat, formattedPrice];
                NSString *cancelButtonTitle = NSLocalizedString(@"MailCancelButton", nil);
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                             message:description
                                                            delegate:self
                                                   cancelButtonTitle:cancelButtonTitle
                                                   otherButtonTitles:buyButtonText,nil];
                [av show];
            } else {
                MWLogError([LayInAppPurchaseManager class], @"Unknown product-ID!!!!!");
                NSString *message = NSLocalizedString(@"InfoBuyCanMakeNoPayments", nil);
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            }
            
        } else {
            MWLogInfo([LayInAppPurchaseManager class], @"User is not authorized to make payments!");
            NSString *message = NSLocalizedString(@"InfoBuyCanMakeNoPayments", nil);
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    } else if([self->products count] == 0) {
        MWLogError([LayInAppPurchaseManager class], @"No valid In-App purchase product found. The Pro version can not be bought by the user!");
    } else {
        MWLogError([LayInAppPurchaseManager class], @"More than one valid In-App purchase products found!");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        MWLogInfo([LayInAppPurchaseManager class], @"Starting payment process of the KEEMI-Pro-Version");
        SKProduct *product = [self->products objectAtIndex:0];
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        payment.quantity = 1;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

@end
