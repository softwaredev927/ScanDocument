//
//  BaseViewController.m
//  CamScan
//
//  Created by Amit Kulkarni on 19/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "BaseViewController.h"
#import "UIAlertController+Blocks.h"
#import "AppDelegate.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.075  green:0.603  blue:0.724 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,  nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Alerts

- (void) showSuccessMessage:(NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) showErrorAlertWithMessage:(NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

//Narola Dev
#pragma mark - For Free Verison 
-(BOOL)checkLimitIsOverArrayCount:(NSInteger)count message:(NSString *)message
{
        if (count >= MAX_NUM_FILE && CSAppDelegate.isPurchased == NO) {
            [self performSegueWithIdentifier:@"showUpgradeVC" sender:nil];
//            [UIAlertController showAlertInViewController:self withTitle:APP_NAME
//                                                 message:message cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@[@"Purchase"] tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
//                                                     if (buttonIndex == controller.destructiveButtonIndex){
//
//                                                     }
//                                                     else{
////                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPLE_LINK]];
//                                                         [self performSegueWithIdentifier:@"showUpgradeVC" sender:nil];
//                                                     }
//                                                 } ];
            return NO;
        }
        return YES;

}

@end
