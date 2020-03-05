//
//  DocumentCollectionViewCell.h
//  CamScan
//
//  Created by Amit Kulkarni on 30/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *viewImageContainer;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *selectionView;

@end
