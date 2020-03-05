//
//  LanguageViewController.h
//  CamScan
//
//  Created by Liao Fang on 5/8/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LanguageViewController : BaseViewController
@property NSMutableArray* supportedLanguages;
@property (nonatomic) NSString* selectedLanguage;
@property (nonatomic) NSString* selectedLangCode;

@property (nonatomic, copy) void (^didDismiss)(NSString *name, NSString *code);
@end

NS_ASSUME_NONNULL_END
