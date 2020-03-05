//
//  DocumentAddPageCell.m
//  CamScan
//
//  Created by Liao Fang on 2019/5/14.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "DocumentAddPageCell.h"

@implementation DocumentAddPageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.viewFrame.layer setCornerRadius:20];
    [self.viewFrame.layer setBorderWidth:1.0];
    [self.viewFrame.layer setBorderColor: [[UIColor alloc] initWithWhite:0.3 alpha:1.0].CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
