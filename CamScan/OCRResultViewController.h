//
//  OCRResultViewController.h
//  CamScan
//
//  Created by Amit Kulkarni on 27/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "BaseViewController.h"
#import "Document.h"
#import "Client.h"

@interface OCRResultViewController : BaseViewController<ClientDelegate>
@property (nonatomic) File *document;
@property (nonatomic) BOOL isImmediateTranslate;
@property (nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UITextView *textResult;
@property (weak, nonatomic) IBOutlet UIStackView *toolBarView;

@end
