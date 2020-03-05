//
//  PasscodeOptionsViewController.m
//  PDFScanner
//
//  Created by Amit Kulkarni on 15/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "PasscodeOptionsViewController.h"
#import "Preferences.h"
#import "DMPasscode.h"

@interface PasscodeOptionsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSArray *options;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation PasscodeOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Passcode Options";
    
    self.options = @[@"Turn Off Passcode", @"Change Passcode"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    
    cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        [DMPasscode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
            if (success) {
                [DMPasscode setupPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
                    [[Preferences sharedInstance] setPassCodeEnabled:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } else {
                if (error) {
                    [self showErrorAlertWithMessage:@"Passcode did not match"];
                }
            }
        }];
    } else if (indexPath.row == 0) {
        [DMPasscode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
            if (success) {
                [[Preferences sharedInstance] setPassCodeEnabled:NO];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                if (error) {
                    [self showErrorAlertWithMessage:@"Passcode did not match"];
                }
            }
            
        }];
    }
}



@end
