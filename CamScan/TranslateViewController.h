//
//  TranslateViewController.h
//  CamScan
//
//  Created by Liao Fang on 5/8/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TranslateViewController : BaseViewController
@property (nonatomic) NSString* text;
@property (nonatomic, retain) NSMutableArray* supportedLanguages;
@end

NS_ASSUME_NONNULL_END
