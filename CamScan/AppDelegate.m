//
//  AppDelegate.m
//  CamScan
//
//  Created by Amit Kulkarni on 19/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "AppDelegate.h"
//#import <DropboxSDK/DropboxSDK.h>
#import "HomeViewController.h"
#import "StoreKit/MyStoreKitDelegate.h"
#import "CS_Upgrade1ViewController.h"
//#import <GoogleAnalytics/GAI.h>
//#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "SWRevealViewController.h"
#import "SlideSettingViewController.h"
#import <IAPHelper.h>
#import <IAPShare.h>
#import <SAMKeychain.h>
#import <StoreKit/StoreKit.h>

@import Firebase;
@import GoogleMobileAds;

@interface AppDelegate () {
    ALAd *loadedAd;
}
@end

@implementation AppDelegate

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
//  sourceApplication:(NSString *)source annotation:(id)annotation {
//
//
//    if ([[DBSession sharedSession] handleOpenURL:url]) {
//        if ([[DBSession sharedSession] isLinked]) {
//            NSLog(@"App linked successfully!");
//            // At this point you can start making API calls
//        }
//        return YES;
//    }
//    // Add whatever other url handling code your app requires here
//    return NO;
//}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DROPBOX_SIGNIN_SUCCESS" object:nil];
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually cancelled by user!");
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
    }
    
    return NO;
}

- (void)startApp {
    UINavigationController * nav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"navigation"];
    SlideSettingViewController *slide = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SlideSettingViewController"];

    SWRevealViewController *revealController =  [[SWRevealViewController alloc] initWithRearViewController:nil frontViewController:nav];
    revealController.rightViewController = slide;
    revealController.rightViewRevealWidth = 200;
    
    self.window.rootViewController = revealController;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for(SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                [queue finishTransaction:transaction];
                NSLog(@"Transaction Failed: %@", transaction.debugDescription);
                break;
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [queue finishTransaction:transaction];
                NSLog(@"Transaction purchased or restored: %@", transaction.debugDescription);
                self.isPurchased = YES;
                self.purchasedProductId = transaction.payment.productIdentifier;
                break;
            case SKPaymentTransactionStateDeferred:
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Transaction in progress: %@", transaction.debugDescription);
                break;
            default:
                break;
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.bundleId = [[NSBundle mainBundle] bundleIdentifier];
    
    self.popupState = @"";
    self.shouldShowReviewing = NO;
    
    NSError *error = nil;
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    query.service = @"CamScan";
    query.account = @"Reviewing";
    [query fetch:&error];

    NSString *isReviewed = @"no";

    if ([error code] == errSecItemNotFound) {
        [SAMKeychain setPassword:@"no" forService:@"CamScan" account:@"Reviewing"];
    } else if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        isReviewed = [SAMKeychain passwordForService:@"CamScan" account:@"Reviewing"];
    }

    NSInteger runningCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"RUNNING_COUNT"];
    runningCount += 1;
    [[NSUserDefaults standardUserDefaults] setInteger:runningCount forKey:@"RUNNING_COUNT"];
    
    if ([isReviewed isEqualToString:@"no"] && runningCount % 5 == 0) {
        self.shouldShowReviewing = YES;
    } else {
        self.shouldShowReviewing = NO;
    }
    
    if ([self.bundleId isEqualToString:@"com.pinnacleapps.scandex"]) {
        self.isPurchased = YES;
    } else {
        //[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        self.isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_PURCHASED"];
        self.purchasedProductId = [[NSUserDefaults standardUserDefaults] stringForKey:@"PURCHASED_PRODUCT_ID"];
    }
    
    if (![IAPShare sharedHelper].iap) {
        NSSet *dataSet = [[NSSet alloc] initWithObjects: PRODUCT_ID_WEEKLY, PRODUCT_ID_MONTHLY, PRODUCT_ID_YEARLY, nil];
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    [IAPShare sharedHelper].iap.production = NO;
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest *request, SKProductsResponse *response) {
        if (response.products == NULL || response.products.count == 0) {
            return;
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSBundle mainBundle].appStoreReceiptURL];
        [[IAPShare sharedHelper].iap checkReceipt:data AndSharedSecret:@"2e79156883694df9af0daeef0be04ead" onCompletion:^(NSString *response, NSError *error) {
            if (error != NULL) {
                return;
            }
            
            NSDictionary* rec = [IAPShare toJSON:response];
            
            BOOL isPurchased = NO;
            NSString *purchasedProductId = @"";
            
            if([rec[@"status"] integerValue]==0)
            {
                NSArray *inAppArray = rec[@"receipt"][@"in_app"];
                for (NSDictionary *inApp in inAppArray) {
                    double interval = [inApp[@"expires_date_ms"] doubleValue] / 1000;
                    double currentInterval = [NSDate date].timeIntervalSince1970;
                    if (interval >= currentInterval) {
                        isPurchased = YES;
                        purchasedProductId = inApp[@"product_id"];
                        self.expireDate = [NSDate dateWithTimeIntervalSince1970:interval];
                        break;
                    }
                }
                
                self.isPurchased = isPurchased;
                self.purchasedProductId = purchasedProductId;
                [[NSUserDefaults standardUserDefaults] setBool:isPurchased forKey:@"IS_PURCHASED"];
                [[NSUserDefaults standardUserDefaults] setObject:self.purchasedProductId forKey:@"PURCHASED_PRODUCT_ID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else {
                NSLog(@"Fail");
            }
            
            NSLog(@"%@", response);
        }];
    }];
//    [[IAPShare sharedHelper].iap request];
    
//    self.isPurchased = NO;
//    [CSStoreKitDelegate fetchProducts];
    
    [ALSdk initializeSdk];
    [ALInterstitialAd shared].adLoadDelegate = self;
    [ALInterstitialAd shared].adDisplayDelegate = self;
    
    [self loadApplovinAd];
    
    self.needApplovinAd = NO;
//    [ALSdk shared].settings.isTestAdsEnabled = YES;
    
    // [START tracker_objc]
    // Configure tracker from GoogleService-Info.plist.
//    NSError *configureError;
//    [[GGLContext sharedInstance] configureWithError:&configureError];
//    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
//    
//    // Optional: configure GAI options.
//    GAI *gai = [GAI sharedInstance];
//    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
//    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
//    // [END tracker_objc]

    
    // Override point for customization after application launch.
    self.passcodeEntered = NO;
    
    [DBClientsManager setupWithAppKey:@"dcv6f4k359lk46j"];
    
//    DBSession *dbSession = [[DBSession alloc]
//                            initWithAppKey:@"dcv6f4k359lk46j"
//                            appSecret:@"kun5zh0906cq6ro"
//                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
//    [DBSession setSharedSession:dbSession];
    
    [FIRApp configure];
//    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    self.passcodeEntered = NO;
//    UINavigationController *nav = self.window.rootViewController;
//    HomeViewController *vc = [nav topViewController];
//    vc.showSplash = YES;
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "iMagic-Software.CamScan" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CamScan" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CamScan.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (void)presentViewWith:(UIViewController*) vc {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CS_Upgrade1ViewController *uvc = [storyboard instantiateViewControllerWithIdentifier:@"CS_Upgrade1ViewController"];
    [vc presentViewController:uvc animated:YES completion:nil];
}

#pragma MARK - AppLovin SDK integration

- (void)showApplovinAd {
    if (loadedAd != nil) {
        [[ALInterstitialAd shared]showAd:loadedAd];
    }
    self.needApplovinAd = NO;
    NSLog(@"--------------Showing AppLovin Ad---------------");
}

- (void)loadApplovinAd {
    [[ALSdk shared].adService loadNextAd:[ALAdSize sizeInterstitial] andNotify:self];
}

- (void)adService:(nonnull ALAdService *)adService didFailToLoadAdWithError:(int)code {
    NSLog(@">>> Applovin Ads fail to load with error code %d", code);
}

- (void)adService:(nonnull ALAdService *)adService didLoadAd:(nonnull ALAd *)ad {
    NSLog(@">>> Applovin Ads loaded successfully.");
    loadedAd = ad;
}

- (void)ad:(nonnull ALAd *)ad wasClickedIn:(nonnull UIView *)view {
    NSLog(@">>> Applovin Ads was clicked.");
}

- (void)ad:(nonnull ALAd *)ad wasDisplayedIn:(nonnull UIView *)view {
    NSLog(@">>> Applovin Ads was displayed in.");
    loadedAd = nil;
    [self loadApplovinAd];
}

- (void)ad:(nonnull ALAd *)ad wasHiddenIn:(nonnull UIView *)view {
    NSLog(@">>> Applovin Ads was hidden in.");
}

-(void)reviewing: (UIViewController*) vc {
    if (self.shouldShowReviewing == YES) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Do you like this app?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SKStoreReviewController requestReview];
            [SAMKeychain setPassword:@"yes" forService:@"CamScan" account:@"Reviewing"];
        }];
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [controller addAction:yes];
        [controller addAction:no];
        [vc presentViewController:controller animated:YES completion:nil];
    } else {
        
    }
}
@end
