//
//  SettingsViewController.m
//  PDFScanner
//
//  Created by Amit Kulkarni on 15/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "SettingsViewController.h"
#import "PopViewControllerDelegate.h"
#import "UIViewController+MJPopupViewController.h"
#import "SelectDefaultProcessViewController.h"
#import "Preferences.h"
#import "DMPasscode.h"
#import "PasscodeOptionsViewController.h"
#import "FAQViewController.h"

#import <MessageUI/MessageUI.h>

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, PopViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *options;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    self.options = @[@"Contact Us", @"Upgrade"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cancelButtonClicked:(UIViewController *)secondDetailViewController {
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
//    if (indexPath.row == 1) {
//        cell.detailTextLabel.text = [[Preferences sharedInstance] passCodeEnabled] ? @"ON" : @"OFF";
//    }
    
    cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*if (indexPath.row == 0) {
        SelectDefaultProcessViewController *vc = [[SelectDefaultProcessViewController alloc] initWithNibName:@"SelectDefaultProcessViewController" bundle:nil];
        vc.completionBlock = ^(int index) {
            
        };
        vc.delegate = self;
        [self presentPopupViewController:vc animationType:MJPopupViewAnimationSlideTopBottom];
    } else  if (indexPath.row == 0) {
        if (![DMPasscode isPasscodeSet]) {
            [DMPasscode setupPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
                if (success) {
                    [[Preferences sharedInstance] setPassCodeEnabled:YES];
                }
                [self.tableView reloadData];
            }];
        } else {
            if ([[Preferences sharedInstance] passCodeEnabled]) {
                PasscodeOptionsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PasscodeOptionsViewController"];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [DMPasscode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
                    if (success) {
                        [[Preferences sharedInstance] setPassCodeEnabled:YES];
                        [self.tableView reloadData];
                    } else {
                        if (error) {
                            [self showErrorAlertWithMessage:@"Passcode did not match"];
                        }
                    }
                }];
            }
        }
    } else if (indexPath.row == 1) {
        FAQViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FAQViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }*/
    if (indexPath.row == 0) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            [vc setToRecipients:@[@"pinnacleapps1@gmail.com"]];
            vc.mailComposeDelegate = self;
            [vc setSubject:@"Scanner feedback"];
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            [self showErrorAlertWithMessage:@"Can not send email from this device. Please configure your mail application to send email."];
        }
    } else if (indexPath.row == 1) {
        [self checkLimitIsOverArrayCount:MAX_NUM_FILE message:ALERT_LIMIT_OVER];
    }
}

#pragma mark - message ui

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
