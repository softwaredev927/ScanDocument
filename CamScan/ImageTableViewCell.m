//
//  ImageTableViewCell.m
//  CamScan
//
//  Created by Amit Kulkarni on 23/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "ImageTableViewCell.h"

@implementation ImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.viewFrame.layer setCornerRadius:20];
    [self.viewFrame.layer setBorderWidth:1.0];
    [self.viewFrame.layer setBorderColor: [[UIColor alloc] initWithWhite:0.3 alpha:1.0].CGColor];
    
    UIImage *ocrImage = [UIImage imageNamed:@"OCR"];
    UIImage *pencilImage = [UIImage imageNamed:@"pencil"];
    
    [self.buttonOCR setImage:ocrImage forState:UIControlStateNormal];
    [self.buttonOCR.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.buttonOCR setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 0)];
    [self.buttonOCR setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];

    [self.buttonEdit setImage:pencilImage forState:UIControlStateNormal];
    [self.buttonEdit.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.buttonEdit setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 0)];
    [self.buttonEdit setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)detectTextTapped:(id)sender {
    if (self.detectText) {
        self.detectText();
    }
}

- (IBAction)editTapped:(id)sender {
    if (self.edit) {
        self.edit();
    }
}
@end
