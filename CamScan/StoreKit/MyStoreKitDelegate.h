//
//  MyStoreKitDelegate.h
//  CamScan
//
//  Created by Software Engineer on 4/24/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyStoreKitDelegate : NSObject<SKProductsRequestDelegate>

@property (nonatomic, retain) NSMutableDictionary *products;
@property (nonatomic, retain) NSString *MONTHLY_SUB_ID;
@property (nonatomic, retain) NSString *YEARLY_SUB_ID;

@property (nonatomic, retain) NSString *monthlyPrice;
@property (nonatomic, retain) NSString *yearlyPrice;

+(MyStoreKitDelegate*)sharedInstance;

-(void)fetchProducts;
-(void)purchase: (NSString*) productID;
-(void)restorePurchases;

@end


NS_ASSUME_NONNULL_END
