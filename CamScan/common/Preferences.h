//
//  Preferences.h
//  PDFScanner
//
//  Created by Amit Kulkarni on 15/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject
@property (nonatomic) NSString *defaultProcess;
@property (nonatomic) BOOL passCodeEnabled;
@property (nonatomic) NSString *passcode;


+ (Preferences *)sharedInstance;
- (NSInteger)defaultProcessIndex;
- (NSString *)ocrPassword;
- (NSString *)ocrAppId;

@end
