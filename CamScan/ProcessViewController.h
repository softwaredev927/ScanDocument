//
//  ProcessViewController.h
//  CamScan
//
//  Created by Amit Kulkarni on 19/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DidFinishPickingImageDelegate.h"

@class Document, File;

@interface ProcessViewController : BaseViewController

@property (nonatomic) UIImage *originalImage;
@property (nonatomic) UIImage *cropedImage;
@property (nonatomic) File *document;
@property (nonatomic) id<DidFinishPickingImageDelegate> delegate;

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer;
- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer;

@end
