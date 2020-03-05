//
//  ImageTableViewCell.h
//  CamScan
//
//  Created by Amit Kulkarni on 23/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewFrame;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDoc;
@property (copy, nonatomic) void (^detectText)();
@property (copy, nonatomic) void (^edit)();
@property (weak, nonatomic) IBOutlet UIButton *buttonOCR;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;


- (IBAction)detectTextTapped:(id)sender;
- (IBAction)editTapped:(id)sender;
@end
