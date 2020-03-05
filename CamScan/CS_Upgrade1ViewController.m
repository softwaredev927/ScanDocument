//
//  CS_Upgrade1ViewController.m
//  CamScan
//
//  Created by Alex Chang on 7/11/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "CS_Upgrade1ViewController.h"
#import "StoreKit/MyStoreKitDelegate.h"
#import <IAPShare.h>
#import "AppDelegate.h"

@interface CS_Upgrade1ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *weeklyContainerView;
@property (weak, nonatomic) IBOutlet UIView *monthlyContainerView;
@property (weak, nonatomic) IBOutlet UIView *yearlyContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *weeklyCheckImageview;
@property (weak, nonatomic) IBOutlet UIImageView *monthlyCheckImageView;
@property (weak, nonatomic) IBOutlet UIImageView *yearlyCheckImageView;
@property (weak, nonatomic) IBOutlet UIButton *weeklyButton;
@property (weak, nonatomic) IBOutlet UIButton *monthlyButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UIButton *yearlyButton;
@property (weak, nonatomic) IBOutlet UIButton *coninueFreeVersionButton;
@property (weak, nonatomic) IBOutlet UILabel *continueFreeVersionUnderLabel;
@property (weak, nonatomic) IBOutlet UILabel *weeklyPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthlyPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearlyPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *needInternetLabel;
@property (weak, nonatomic) IBOutlet UILabel *weeklySubLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthlySubLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearlySubLabel;

@end

@implementation CS_Upgrade1ViewController
{
    NSInteger selectedIndex;
    SKProduct *monthlyProduct;
    SKProduct *weeklyProduct;
    SKProduct *yearlyProduct;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    selectedIndex = 0;
    
    _weeklyContainerView.layer.borderWidth = 1;
    _weeklyContainerView.layer.borderColor = UIColorFromRGB(0x0daacd).CGColor;
    _weeklyContainerView.layer.cornerRadius = 25;
    _monthlyContainerView.layer.borderWidth = 1;
    _monthlyContainerView.layer.borderColor = UIColorFromRGB(0x0daacd).CGColor;
    _monthlyContainerView.layer.cornerRadius = 25;
    _yearlyContainerView.layer.borderWidth = 1;
    _yearlyContainerView.layer.borderColor = UIColorFromRGB(0x0daacd).CGColor;
    _yearlyContainerView.layer.cornerRadius = 25;
    
    [_weeklyButton setEnabled: YES];
    [_monthlyButton setEnabled: YES];
    [_yearlyButton setEnabled: YES];
    
    [self updateCheckBox];
    [self refreshUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initIAP];
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options: UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
                     animations: ^(void){
                         _continueButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     }
                     completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate.popupState isEqualToString:@"Popup"]) {
        [delegate reviewing:self];
    }
    delegate.popupState = @"";
}

- (void)initIAP {
    NSString *weekly = @" ";
    NSString *monthly = @" ";
    NSString *yearly = @" ";
    
    if ([IAPShare sharedHelper].iap.products.count >= 3) {
        
        SKProduct *product1 = [IAPShare sharedHelper].iap.products[0];
        SKProduct *product2 = [IAPShare sharedHelper].iap.products[1];
        SKProduct *product3 = [IAPShare sharedHelper].iap.products[2];
        
        if ([product1.productIdentifier isEqualToString:PRODUCT_ID_WEEKLY]) {
            weeklyProduct = product1;
        } else if ([product1.productIdentifier isEqualToString:PRODUCT_ID_MONTHLY]) {
            monthlyProduct = product1;
        } else {
            yearlyProduct = product1;
        }
        
        if ([product2.productIdentifier isEqualToString:PRODUCT_ID_WEEKLY]) {
            weeklyProduct = product2;
        } else if ([product2.productIdentifier isEqualToString:PRODUCT_ID_MONTHLY]) {
            monthlyProduct = product2;
        } else {
            yearlyProduct = product3;
        }
        
        if ([product3.productIdentifier isEqualToString:PRODUCT_ID_WEEKLY]) {
            weeklyProduct = product3;
        } else if ([product3.productIdentifier isEqualToString:PRODUCT_ID_MONTHLY]) {
            monthlyProduct = product3;
        } else {
            yearlyProduct = product3;
        }
        
        weekly = [NSString stringWithFormat:@"%@", [[IAPShare sharedHelper].iap getLocalePrice:weeklyProduct]];
        monthly = [NSString stringWithFormat:@"%@", [[IAPShare sharedHelper].iap getLocalePrice:monthlyProduct]];
        yearly = [NSString stringWithFormat:@"%@", [[IAPShare sharedHelper].iap getLocalePrice:yearlyProduct]];
        
        [_weeklySubLabel setText:@"/ WEEKLY"];
        [_monthlySubLabel setText:@"/ MONTHLY"];
        [_yearlySubLabel setText:@"/ YEARLY"];
    } else {
        [_weeklySubLabel setText:@"Internet Required"];
        [_monthlySubLabel setText:@"Internet Required"];
        [_yearlySubLabel setText:@"Internet Required"];
    }
    
    [_weeklyPriceLabel setText:weekly];
    [_monthlyPriceLabel setText:monthly];
    [_yearlyPriceLabel setText:yearly];
    
    [self refreshUI];
}

- (void)updateCheckBox {
    _weeklyContainerView.backgroundColor = UIColor.clearColor;
    _monthlyContainerView.backgroundColor = UIColor.clearColor;
    _yearlyContainerView.backgroundColor = UIColor.clearColor;
    [_weeklyCheckImageview setHidden: YES];
    [_monthlyCheckImageView setHidden: YES];
    [_yearlyCheckImageView setHidden: YES];
    
    if (selectedIndex == 0) {
        _weeklyContainerView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent: 0.3];
        [_weeklyCheckImageview setHidden: NO];
    } else if (selectedIndex == 1) {
        _monthlyContainerView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent: 0.3];
        [_monthlyCheckImageView setHidden: NO];
    } else if (selectedIndex == 2) {
        _yearlyContainerView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent: 0.3];
        [_yearlyCheckImageView setHidden: NO];
    }
}

- (IBAction)weeklyButtonTapped:(id)sender {
    selectedIndex = 0;
    [self updateCheckBox];
}

- (IBAction)monthlyButtonTapped:(id)sender {
    selectedIndex = 1;
    [self updateCheckBox];
}

- (IBAction)yearlyButtonTapped:(id)sender {
    selectedIndex = 2;
    [self updateCheckBox];
}

- (IBAction)continueButtonTapped:(id)sender {
    if (CSAppDelegate.isPurchased) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (selectedIndex == -1) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Please select subscription plan" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [controller addAction:yes];
            [self presentViewController:controller animated:YES completion:nil];
        } else if (selectedIndex == 0) {
            [self purchase: weeklyProduct];
        } else if (selectedIndex == 1) {
            [self purchase: yearlyProduct];
        } else if (selectedIndex == 2) {
            [self purchase: yearlyProduct];
        }
    }
}

- (IBAction)continueWithLimitButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)purchaseButtonTapped:(id)sender {
    [CSStoreKitDelegate restorePurchases];
}

- (IBAction)termsButtonTapped:(id)sender {\
    NSString *termsURL = @"https://pinnacleapps1.wixsite.com/vescoapps/terms-of-use";
    
    NSURL *url = [NSURL URLWithString:termsURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)privacyPolicyButtonTapped:(id)sender {
    NSString *policyURL = @"https://pinnacleapps1.wixsite.com/vescoapps/privacy-policy";
    
    NSURL *url = [NSURL URLWithString:policyURL];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)purchase:(SKProduct*) product {
    [[IAPShare sharedHelper].iap buyProduct:product onCompletion:^(SKPaymentTransaction *transcation) {
        if (transcation.error) {
            NSLog(@"Failed: %@", [transcation.error localizedDescription]);
        } else if (transcation.transactionState == SKPaymentTransactionStatePurchased){
            CSAppDelegate.isPurchased = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_PURCHASED"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[IAPShare sharedHelper].iap checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] AndSharedSecret:@"2e79156883694df9af0daeef0be04ead" onCompletion:^(NSString *response, NSError *error) {
                
                //Convert JSON String to NSDictionary
                NSDictionary* rec = [IAPShare toJSON:response];
                
                if([rec[@"status"] integerValue]==0)
                {
                    
                    [[IAPShare sharedHelper].iap provideContentWithTransaction:transcation];
                    
                    BOOL isPurchased = NO;
                    NSString *purchasedProductId = @"";
                    NSArray *inAppArray = rec[@"receipt"][@"in_app"];
                    for (NSDictionary *inApp in inAppArray) {
                        double interval = [inApp[@"expires_date_ms"] doubleValue] / 1000;
                        double currentInterval = [NSDate date].timeIntervalSince1970;
                        if (interval >= currentInterval) {
                            isPurchased = YES;
                            purchasedProductId = inApp[@"product_id"];
                            CSAppDelegate.expireDate = [NSDate dateWithTimeIntervalSince1970:interval];
                            break;
                        }
                    }
                    
                    CSAppDelegate.isPurchased = isPurchased;
                    CSAppDelegate.purchasedProductId = purchasedProductId;
                    [[NSUserDefaults standardUserDefaults] setBool:isPurchased forKey:@"IS_PURCHASED"];
                    [[NSUserDefaults standardUserDefaults] setObject:CSAppDelegate.purchasedProductId forKey:@"PURCHASED_PRODUCT_ID"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else {
                    NSLog(@"Fail");
                }
                
                [self refreshUI];
            }];
        } else {
            NSLog(@"Failed");
        }
    }];
}

-(void)refreshUI {
    if (CSAppDelegate.isPurchased) {
        [_continueButton setHidden:NO];
        [_expirationLabel setHidden:NO];
        [_coninueFreeVersionButton setHidden:YES];
        [_continueFreeVersionUnderLabel setHidden:YES];
        [_restoreButton setHidden:YES];
        [_needInternetLabel setHidden:YES];
        
        if (CSAppDelegate.expireDate != NULL) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd, yyyy"];
            NSString *result = [formatter stringFromDate:CSAppDelegate.expireDate];
            NSString *string = [NSString stringWithFormat:@"Current subscription will be expired\nat %@", result];
            [_expirationLabel setText:string];
        } else {
            [_expirationLabel setText:@"You have already subscribed"];
        }
        
        [_weeklyButton setEnabled:NO];
        [_monthlyButton setEnabled:NO];
        [_yearlyButton setEnabled:NO];
        
        if (CSAppDelegate.purchasedProductId == PRODUCT_ID_WEEKLY) {
            selectedIndex = 0;
        } else if (CSAppDelegate.purchasedProductId == PRODUCT_ID_MONTHLY) {
            selectedIndex = 1;
        } else if (CSAppDelegate.purchasedProductId == PRODUCT_ID_YEARLY) {
            selectedIndex = 2;
        }
    } else {
        if (weeklyProduct == NULL) {
            [_expirationLabel setHidden:YES];
            [_needInternetLabel setHidden:NO];
            [_continueButton setHidden:YES];
            [_restoreButton setHidden:YES];
            [_coninueFreeVersionButton setHidden:NO];
            [_continueFreeVersionUnderLabel setHidden:NO];
            [_coninueFreeVersionButton setTitle:@"Continue with limited version" forState:UIControlStateNormal];
        } else {
            [_expirationLabel setHidden:YES];
            [_needInternetLabel setHidden:YES];
            [_continueButton setHidden:NO];
            [_restoreButton setHidden:NO];
            [_coninueFreeVersionButton setHidden:NO];
            [_continueFreeVersionUnderLabel setHidden:NO];
            [_coninueFreeVersionButton setTitle:@"Or continue with limited version" forState:UIControlStateNormal];
        }
        
        [_weeklyButton setEnabled:YES];
        [_monthlyButton setEnabled:YES];
        [_yearlyButton setEnabled:YES];
    }
    
    [self updateCheckBox];
}

@end
