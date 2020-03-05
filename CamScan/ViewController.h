//
//  ViewController.h
//  IPDFCameraViewController
//
//  Created by Maximilian Mackh on 11/01/15.
//  Copyright (c) 2015 Maximilian Mackh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CLImageEditor.h"
@class Document;

@interface ViewController : BaseViewController
@property (nonatomic) id<CLImageEditorDelegate> delegate;
@property (nonatomic) Document *document;

-(IBAction)changeMode;
@end

