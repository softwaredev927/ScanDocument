//
//  DocumentCollectionViewCell.m
//  CamScan
//
//  Created by Amit Kulkarni on 30/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "DocumentCollectionViewCell.h"

@implementation DocumentCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

//    self.labelName.layer.borderWidth = 1;
//    self.labelName.layer.borderColor = [[UIColor colorWithRed:0.494  green:0.494  blue:0.494 alpha:1] CGColor];
    
    [self.viewImageContainer.layer setCornerRadius:15];
    [self.viewImageContainer.layer setBorderWidth:1.0];
    [self.viewImageContainer.layer setBorderColor: [[UIColor alloc] initWithWhite:0.3 alpha:1.0].CGColor];
    
    self.viewImageContainer.backgroundColor = [UIColor clearColor];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

@end
