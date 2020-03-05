//
//  SlideSettingViewController.m
//  CamScan
//
//  Created by Alex Chang on 6/5/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "SlideSettingViewController1.h"
#import "PopViewControllerDelegate.h"
#import "UIViewController+MJPopupViewController.h"
#import "SelectDefaultProcessViewController.h"
#import "Preferences.h"
#import "DMPasscode.h"
#import "PasscodeOptionsViewController.h"
#import "FAQViewController.h"
#import "SWRevealViewController.h"
#import "CS_Upgrade1ViewController.h"
#import "AppDelegate.m"

#import <MessageUI/MessageUI.h>

@interface SlideSettingViewController () <PopViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contactView;
@property (weak, nonatomic) IBOutlet UIView *upgradeView;

@end

@implementation SlideSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.contactView.layer.cornerRadius = 10;
    self.upgradeView.layer.cornerRadius = 10;
    self.contactView.clipsToBounds = true;
    self.upgradeView.clipsToBounds = true;
    
    if ([CSAppDelegate.bundleId isEqualToString:@"com.pinnacleapps.scandex"]) {
        [self.upgradeView setHidden:YES];
    } else {
        [self.upgradeView setHidden:NO];
    }
}

- (IBAction)contactButtonTapped:(id)sender {
    [self.revealViewController rightRevealToggleAnimated:YES];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        [vc setToRecipients:@[@"pinnacleapps1@gmail.com"]];
        vc.mailComposeDelegate = self;
        [vc setSubject:@"Scanner feedback"];
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [self showErrorAlertWithMessage:@"Can not send email from this device. Please configure your mail application to send email."];
    }
}

- (IBAction)upgradeButtonTapped:(id)sender {
    [self.revealViewController rightRevealToggleAnimated:YES];
    
    CS_Upgrade1ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CS_Upgrade1ViewController"];
    [[self revealViewController] presentViewController:vc animated:YES completion:nil];
}

#pragma mark - message ui

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
