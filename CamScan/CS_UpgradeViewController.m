//
//  CS_UpgradeViewController.m
//  CamScan
//
//  Created by Software Engineer on 4/24/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "CS_UpgradeViewController.h"
#import "StoreKit/MyStoreKitDelegate.h"
#import <IAPShare.h>
#import "AppDelegate.h"

@interface CS_UpgradeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *m_btnSubscribeWeekly;
@property (weak, nonatomic) IBOutlet UIButton *m_btnSubscribeYearly;
@property (weak, nonatomic) IBOutlet UILabel *subscribedLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribButtonHeightConstrinat;
@property (weak, nonatomic) IBOutlet UIView *subscribeButtonContainerView;

@end

@implementation CS_UpgradeViewController
{
    SKProduct *monthlyProduct;
    SKProduct *yearlyProduct;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    monthlyProduct = NULL;
    yearlyProduct = NULL;
    
    [self refreshUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *weekly = @"Need Internet";
    NSString *yearly = @"Need Internet";
    
    if ([IAPShare sharedHelper].iap.products.count >= 2) {
        
        SKProduct *product1 = [IAPShare sharedHelper].iap.products[0];
        SKProduct *product2 = [IAPShare sharedHelper].iap.products[1];
        
        if ([product1.productIdentifier isEqualToString:PRODUCT_ID_MONTHLY]) {
            monthlyProduct = product1;
            yearlyProduct = product2;
        } else {
            monthlyProduct = product2;
            yearlyProduct = product1;
        }
            
        weekly = [NSString stringWithFormat:@"%@ Monthly", [[IAPShare sharedHelper].iap getLocalePrice:monthlyProduct]];
        yearly = [NSString stringWithFormat:@"%@ Yearly", [[IAPShare sharedHelper].iap getLocalePrice:yearlyProduct]];
    }
    
    UIFont *font1 = [UIFont boldSystemFontOfSize:30];
    UIFont *font2 = [UIFont boldSystemFontOfSize:15];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *dict1 = @{
                            NSFontAttributeName: font1,
                            NSForegroundColorAttributeName: UIColor.whiteColor,
                            NSParagraphStyleAttributeName: paragraphStyle
                            };
    NSDictionary *dict2 = @{
                            NSFontAttributeName: font2,
                            NSForegroundColorAttributeName: UIColor.whiteColor,
                            NSParagraphStyleAttributeName: paragraphStyle
                            };
    
    NSMutableAttributedString *attStringWeekly = [[NSMutableAttributedString alloc]init];
    NSMutableAttributedString *attStringYearly = [[NSMutableAttributedString alloc]init];
    NSAttributedString *attString1 = [[NSAttributedString alloc]initWithString:@"" attributes:dict1];
    NSAttributedString *attString2 = [[NSAttributedString alloc]initWithString:weekly attributes:dict2];
    NSAttributedString *attString3 = [[NSAttributedString alloc]initWithString:yearly attributes:dict2];
    
    [attStringWeekly appendAttributedString:attString1];
    [attStringWeekly appendAttributedString:attString2];
    
    [attStringYearly appendAttributedString:attString1];
    [attStringYearly appendAttributedString:attString3];
    
    [self.m_btnSubscribeWeekly.titleLabel setNumberOfLines:0];
    [self.m_btnSubscribeWeekly setAttributedTitle:attStringWeekly forState:UIControlStateNormal];
    
    [self.m_btnSubscribeYearly.titleLabel setNumberOfLines:0];
    [self.m_btnSubscribeYearly setAttributedTitle:attStringYearly forState:UIControlStateNormal];
    
    self.m_btnSubscribeWeekly.layer.cornerRadius = 10;
    self.m_btnSubscribeWeekly.clipsToBounds = YES;
    
    self.m_btnSubscribeYearly.layer.cornerRadius = 10;
    self.m_btnSubscribeYearly.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate.popupState isEqualToString:@"Popup"]) {
        [delegate reviewing:self];
    }
    delegate.popupState = @"";
}

- (IBAction)btnCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnWeeklySubscriptionClicked:(id)sender {
    if (monthlyProduct != NULL) {
        [self purchase:monthlyProduct];
    }
    
//    [CSStoreKitDelegate purchase:CSStoreKitDelegate.MONTHLY_SUB_ID];
}
- (IBAction)btnYearlySubscriptionClicked:(id)sender {
    if (yearlyProduct != NULL) {
        [self purchase:yearlyProduct];
    }
//    [CSStoreKitDelegate purchase:CSStoreKitDelegate.YEARLY_SUB_ID];
}

- (IBAction)btnLinkClicked:(UIButton *)sender {
    NSString *termsURL = @"https://pinnacleapps1.wixsite.com/vescoapps/terms-of-use";
    NSString *policyURL = @"https://pinnacleapps1.wixsite.com/vescoapps/privacy-policy";
    
    NSURL *url = [NSURL URLWithString:sender.tag == 1 ? termsURL : policyURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)restoreButtonTapped:(id)sender {
    [CSStoreKitDelegate restorePurchases];
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
                    NSArray *inAppArray = rec[@"receipt"][@"in_app"];
                    for (NSDictionary *inApp in inAppArray) {
                        double interval = [inApp[@"expires_date_ms"] doubleValue] / 1000;
                        double currentInterval = [NSDate date].timeIntervalSince1970;
                        if (interval >= currentInterval) {
                            isPurchased = YES;
                            CSAppDelegate.expireDate = [NSDate dateWithTimeIntervalSince1970:interval];
                            break;
                        }
                    }
                    
                    CSAppDelegate.isPurchased = isPurchased;
                    [[NSUserDefaults standardUserDefaults] setBool:isPurchased forKey:@"IS_PURCHASED"];
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
        [_subscribedLabel setHidden:NO];
        [_subscribeButtonContainerView setHidden:YES];
        _subscribButtonHeightConstrinat.constant = 48;
        
        if (CSAppDelegate.expireDate != NULL) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd, yyyy"];
            NSString *result = [formatter stringFromDate:CSAppDelegate.expireDate];
            NSString *string = [NSString stringWithFormat:@"Current subscription will be expired\nat %@", result];
            [_subscribedLabel setText:string];
        } else {
            [_subscribedLabel setText:@"You have already subscribed"];
        }
        
    } else {
        [_subscribedLabel setHidden:YES];
        [_subscribeButtonContainerView setHidden:NO];
        _subscribButtonHeightConstrinat.constant = 159;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
