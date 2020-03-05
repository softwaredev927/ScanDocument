//
//  SelectDefaultProcessViewController.h
//  PDFScanner
//
//  Created by Amit Kulkarni on 15/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopViewControllerDelegate.h"

@interface SelectDefaultProcessViewController : UIViewController
@property (nonatomic) id<PopViewControllerDelegate> delegate;
@property (nonatomic, copy) void (^completionBlock)(int index);
@end
