//
//  RenameDocumentViewController.h
//  CamScan
//
//  Created by Amit Kulkarni on 23/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "BaseViewController.h"
#import "PopViewControllerDelegate.h"

@class File;

@interface RenameDocumentViewController : BaseViewController<UITextFieldDelegate>
@property (nonatomic) id<PopViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UITextField *editName;
@property File *file;
@property (nonatomic) NSArray *array;
@end
