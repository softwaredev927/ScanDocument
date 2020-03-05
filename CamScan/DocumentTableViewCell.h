//
//  DocumentTableViewCell.h
//  CamScan
//
//  Created by Amit Kulkarni on 22/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewThumbnail;

@property (copy, nonatomic) void (^moreAction)();
- (IBAction)onMore:(id)sender;

@end
