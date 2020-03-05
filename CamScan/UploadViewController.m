//
//  UploadViewController.m
//  CamScan
//
//  Created by Alex Chang on 6/4/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "UploadViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"

#import "AppDelegate.h"
#import "GTLQueryDrive.h"
#import "GTLObject.h"
#import "GTLDrive.h"

#import "GTLService.h"
#import "GTLDrive.h"
#import "GTLDriveFile.h"


#pragma  mark GoogleDrive
#define kIssuer @"https://accounts.google.com"
#define kRedirectURI @"com.googleusercontent.apps.358071974996-thcek9isn3l0kthris58qvlhcgoq3b3m:/oauthredirect"
#define kClientID @"358071974996-thcek9isn3l0kthris58qvlhcgoq3b3m.apps.googleusercontent.com"

static NSString *const kExampleAuthorizerKey = @"Drive API";


@interface UploadViewController ()

@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxDidSignIn) name:@"DROPBOX_SIGNIN_SUCCESS" object:nil];
}

- (IBAction)boxButtonTapped:(id)sender {
    
}

- (IBAction)dropboxButtonTapped:(id)sender {
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    if (client == nil) {
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication] controller:[[self class] topMostController] openURL:^(NSURL * url) {
            [[UIApplication sharedApplication] openURL:url];
        }];
    } else {
        [self uploadToDropbox:self.filePath];
    }
}

- (IBAction)googleDriveButtonTapped:(id)sender {
    
}

- (IBAction)onedriveButtonTapped:(id)sender {
    
}

- (IBAction)evernoteButtonTapped:(id)sender {
    
}

- (IBAction)onenoteButtonTapped:(id)sender {
    
}

- (void)dropboxDidSignIn {
    [self uploadToDropbox:self.filePath];
}

-(void)uploadToDropbox:(NSString*)path {
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    if (client == NULL) {
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    [[[client.filesRoutes uploadUrl:[url lastPathComponent] mode:mode autorename:@(YES) clientModified:nil mute:@(NO) propertyGroups:nil strictConflict:nil inputUrl:path] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        if (result) {
            NSLog(@"%@\n", result);
        } else {
            NSLog(@"%@\n%@\n", routeError, networkError);
        }
    }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"\n%lld\n%lld\n%lld\n", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }];
}

+ (UIViewController*)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

/*! @brief Saves the @c GTMAppAuthFetcherAuthorization to @c NSUSerDefaults.
 */
- (void)googleAuth {
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    
    
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
                                                            NSLog(@"%@",configuration);
                                                            if (!configuration)
                                                            {
                                                                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Google error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                                                                
                                                                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                                    
                                                                }];
                                                                
                                                                [alertC addAction:actionOk];
                                                                
                                                                [self presentViewController:alertC animated:YES completion:^{
                                                                    
                                                                }];
                                                                
                                                                return;
                                                            }
                                                            
                                                            [self performSelector:@selector(prepareUploadingGoogleDrive:) withObject:configuration afterDelay:0.5];
                                                            
                                                        }];
}

-(void)prepareUploadingGoogleDrive:(OIDServiceConfiguration *)configuration
{
    // builds authentication request
    
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    OIDAuthorizationRequest *request =
    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                  clientId:kClientID
                                                    scopes:@[OIDScopeOpenID, OIDScopeProfile,kGTLAuthScopeDriveMetadataReadonly,kGTLAuthScopeDrive,kGTLAuthScopeDriveAppdata,kGTLAuthScopeDrive]
                                               redirectURL:redirectURI
                                              responseType:OIDResponseTypeCode
                                      additionalParameters:nil];
    // performs authentication request
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.currentAuthorizationFlow =
    [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                   presentingViewController:self
                                                   callback:^(OIDAuthState *_Nullable authState,
                                                              NSError *_Nullable error)
     {
         
         if (authState)
         {
//             [googlenfVC setGTMAuth:authState];
//             [self loadFolderView];
             //[googleVC fetchFiles];
             
         }
         else
         {
         }
     }];
    
}
@end
