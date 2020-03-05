//
//  PopViewControllerDelegate.h
//  Cavaratmall
//
//  Created by Amit Kulkarni on 30/07/15.
//  Copyright (c) 2015 iMagicsoftware. All rights reserved.
//

#ifndef Cavaratmall_PopViewControllerDelegate_h
#define Cavaratmall_PopViewControllerDelegate_h

@class Document;
@protocol PopViewControllerDelegate<NSObject>
@optional
- (void)cancelButtonClicked:(UIViewController *)secondDetailViewController;
- (void)cancelWithSelectingDocument:(Document *)doc withVC:(UIViewController *)vc;
@end

#endif
