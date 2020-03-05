//
//  UploadViewController.h
//  CamScan
//
//  Created by Alex Chang on 6/4/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDrive.h"


NS_ASSUME_NONNULL_BEGIN

@class OIDAuthState;
@class GTMAppAuthFetcherAuthorization;
@class OIDServiceConfiguration;

@interface UploadViewController : UIViewController

@property (nonatomic) NSString *filePath;
@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;
@property (nonatomic, strong) GTLServiceDrive *driveService;


@end

NS_ASSUME_NONNULL_END
