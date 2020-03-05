//
//  DocumentTableViewCell.m
//  CamScan
//
//  Created by Amit Kulkarni on 22/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "DocumentTableViewCell.h"

@implementation DocumentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onMore:(id)sender {
    if (self.moreAction) {
        self.moreAction();
    }
}

@end
