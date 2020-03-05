//
//  MyStoreKitDelegate.m
//  CamScan
//
//  Created by Software Engineer on 4/24/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "MyStoreKitDelegate.h"

@implementation MyStoreKitDelegate

+(MyStoreKitDelegate*)sharedInstance {
    static MyStoreKitDelegate *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init {
    if(self=[super init]) {
        self.MONTHLY_SUB_ID = @"com.scandex.monthly";
        self.YEARLY_SUB_ID = @"com.scandex.yearly";
        self.monthlyPrice = @"";
        self.yearlyPrice = @"";
        
        self.products = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)fetchProducts {
    NSSet *productIDs = [[NSSet alloc]initWithObjects: self.MONTHLY_SUB_ID, self.YEARLY_SUB_ID, nil];
    SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:productIDs];
    request.delegate = self;
    [request start];
}
-(void)purchase: (NSString*) productID {
    SKProduct *product = self.products[productID];
    if(product) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}
-(void)restorePurchases {
    [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
}

#pragma MARK - SKProductsRequestDelegate
- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
    for(NSString *productId in response.invalidProductIdentifiers) {
        NSLog(@"Invalid: %@", productId);
    }
    
    for(SKProduct *product in response.products) {
        NSLog(@"Valid: %@", product.productIdentifier);
        [self.products setObject:product forKey:product.productIdentifier];
        if ([product.productIdentifier isEqualToString:self.MONTHLY_SUB_ID]) {
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            
            NSLocale *storeLocale = product.priceLocale;
            self.monthlyPrice = [numberFormatter stringFromNumber:product.price];
//            self.weeklyPrice = (NSString *)CFLocaleGetValue((CFLocaleRef)storeLocale, kCFLocaleCountryCode);
//            self.weeklyPrice = product.priceLocale;
        }else if ([product.productIdentifier isEqualToString:self.YEARLY_SUB_ID]) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            
            NSLocale *storeLocale = product.priceLocale;
            self.yearlyPrice = [numberFormatter stringFromNumber:product.price];
//            self.yearlyPrice = (NSString *)CFLocaleGetValue((CFLocaleRef)storeLocale, kCFLocaleCountryCode);
//            self.yearlyPrice = product.priceLocale;
        }
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error for request: %@", error.localizedDescription);
}

- (void)requestDidFinish:(SKRequest *)request {
    
}

@end
