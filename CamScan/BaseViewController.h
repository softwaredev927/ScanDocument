//
//  BaseViewController.h
//  CamScan
//
//  Created by Amit Kulkarni on 19/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
- (void) showSuccessMessage:(NSString *)message;
- (void) showErrorAlertWithMessage:(NSString *)message;

#pragma mark - For Free Verison
-(BOOL)checkLimitIsOverArrayCount:(NSInteger)count message:(NSString *)message;

@end
