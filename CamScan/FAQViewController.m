//
//  FAQViewController.m
//  PDFScanner
//
//  Created by Amit Kulkarni on 15/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "FAQViewController.h"

@interface FAQViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation FAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"FAQ";
    [self.webView loadHTMLString:@"<p>FAQ HERE<p>" baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
