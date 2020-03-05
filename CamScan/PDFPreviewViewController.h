//
//  PDFViewController.h
//  CamScan
//
//  Created by Amit Kulkarni on 23/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "BaseViewController.h"

@interface PDFPreviewViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) NSString *path;
@end
