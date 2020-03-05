//
//  PDFViewController.m
//  CamScan
//
//  Created by Amit Kulkarni on 23/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "PDFPreviewViewController.h"

@implementation PDFPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"PDF";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.path]]];
}

@end
