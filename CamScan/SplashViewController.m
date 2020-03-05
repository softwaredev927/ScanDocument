//
//  SplashViewController.m
//  CamScan
//
//  Created by Amit Kulkarni on 21/09/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(removeImage) userInfo:nil repeats:NO];
}

- (void)removeImage {
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    [app startApp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
