//
//  AppDelegate.h
//  CamScan
//
//  Created by Amit Kulkarni on 19/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <StoreKit/StoreKit.h>
#import <AppLovinSDK/ALInterstitialAd.h>
#import <AppLovinSDK/ALSdk.h>
#import <AppLovinSDK/ALIncentivizedInterstitialAd.h>
#import "OIDAuthorizationService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SKPaymentTransactionObserver, ALAdLoadDelegate, ALAdDisplayDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) BOOL passcodeEntered;

@property (assign) BOOL isPurchased;
@property (assign) BOOL shouldShowReviewing;
@property (assign) BOOL needApplovinAd;
@property (nonatomic) NSDate *expireDate;
@property (nonatomic) NSString *purchasedProductId;
@property (nonatomic) NSString *popupState;
@property (nonatomic) NSString *bundleId;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Represents an in-flight authorization flow session.
@property(nonatomic, strong, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)startApp;
- (void)presentViewWith:(UIViewController*) vc;
- (void)showApplovinAd;
- (void)reviewing: (UIViewController*) vc;
@end

