//
//  ViewController.m
//  IPDFCameraViewController
//
//  Created by Maximilian Mackh on 11/01/15.
//  Copyright (c) 2015 Maximilian Mackh. All rights reserved.
//

#import "ViewController.h"

#import "IPDFCameraViewController.h"
#import "ProcessViewController.h"
#import "CropViewController.h"
#import "Document.h"

#import "SVProgressHUD.h"
#import "UIImage+Thumbnail.h"

#import "PopViewControllerDelegate.h"

#import "SelectDefaultProcessViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "KxMenu.h"
#import <AppLovinSDK/ALInterstitialAd.h>
#import <sys/utsname.h>

#import "AppDelegate.h"

@import GoogleMobileAds;


@interface ViewController ()<PopViewControllerDelegate,GADInterstitialDelegate> {
    int processType;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonCrop;
@property (weak, nonatomic) IBOutlet UIButton *buttonFlash;
@property (weak, nonatomic) IBOutlet UISegmentedControl *optionModes;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;
@property (weak, nonatomic) IBOutlet IPDFCameraViewController *cameraViewController;
@property (weak, nonatomic) IBOutlet UIImageView *focusIndicator;

@property (weak, nonatomic) IBOutlet UIView *viewGrid;
@property (weak, nonatomic) IBOutlet UIButton *btnFlashOn;
@property (weak, nonatomic) IBOutlet UIButton *btnFlashOff;
@property (weak, nonatomic) IBOutlet UIButton *btnGrid;
@property (weak, nonatomic) IBOutlet UIImageView *imgAutoDetect;

@property (weak, nonatomic) IBOutlet UIButton *btnSingle;
@property (weak, nonatomic) IBOutlet UIButton *btnMulti;
@property (weak, nonatomic) IBOutlet UIView *viewSingleMulti;
@property (weak, nonatomic) IBOutlet UIButton *btnFinish;

@property (nonatomic) NSMutableArray *arrayImages;

@property(nonatomic, strong) GADInterstitial *interstitial;

- (IBAction)focusGesture:(id)sender;
- (IBAction)captureButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonProcessType;

@end

@implementation ViewController

#pragma mark -
#pragma mark View Lifecycle

- (IBAction)cancel:(id)sender {
//    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonClicked:(UIViewController *)secondDetailViewController {
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
}

- (void)selectNormal {
    processType = 0;
    [self.buttonProcessType setTitle:@"Normal" forState:UIControlStateNormal];
}

- (void)selectBW {
    processType = 1;
    [self.buttonProcessType setTitle:@"B & W" forState:UIControlStateNormal];
}

- (void)selectGray {
    processType = 2;
    [self.buttonProcessType setTitle:@"Gray" forState:UIControlStateNormal];
}

- (IBAction)selectProcess:(id)sender {
    [KxMenu showMenuInView:self.view
                  fromRect:[sender frame]
                 menuItems:@[
                             [KxMenuItem menuItem:@"Normal"
                                            image:nil
                                           target:self
                                           action:@selector(selectNormal)],
                             [KxMenuItem menuItem:@"B & W"
                                            image:nil
                                           target:self
                                           action:@selector(selectBW)],
                             [KxMenuItem menuItem:@"Gray"
                                            image:nil
                                           target:self
                                           action:@selector(selectGray)],
                             ]];
}

-(IBAction)changeMode {
    if (self.optionModes.selectedSegmentIndex == 1) {
        if(CSAppDelegate.isPurchased == FALSE) {
            self.optionModes.selectedSegmentIndex = 0;
                if (![self checkLimitIsOverArrayCount:MAX_NUM_FILE message:ALERT_PRO_VERSION]) {
                    return;
                }
            return;
        }
        self.labelCount.hidden = NO;
        self.buttonCrop.enabled = NO;
        self.cameraViewController.enableBorderDetection = NO;
        [self.buttonCrop setBackgroundImage:[UIImage imageNamed:@"crop_off.png"] forState:UIControlStateNormal];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finish"
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(finishWithTakingImages)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        self.cameraViewController.enableBorderDetection = YES;

        [self.buttonCrop setBackgroundImage:[UIImage imageNamed:@"crop_on.png"] forState:UIControlStateNormal];
        self.labelCount.hidden = YES;
        self.buttonCrop.enabled = YES;
    }
}

- (NSString *)saveImage:(UIImage *)image {
    NSData *originalData = UIImagePNGRepresentation(image);
    NSString *originalName = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
    NSString *originalPath = [NSString pathWithComponents:@[NSHomeDirectory(), @"Documents", originalName]];
    [originalData writeToFile:originalPath atomically:YES];
    return originalName;
}

- (void)finishWithTakingImages {
    if ([self.arrayImages count] > 0) {
        [SVProgressHUD show];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"Please click atleast one image"];
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if ([self.arrayImages count] > 0) {
            NSMutableArray *files = [[NSMutableArray alloc] init];
            for (UIImage *image in self.arrayImages) {
                File *file = [[File alloc] init];
                file.originalFile = [self saveImage:image];
                file.modifiedFile = [self saveImage:image];
                file.thumbnailFile = [self saveImage:[image imageWithThumbnailWidth:100]];
                file.createdDateTime = [NSDate date];
                [files addObject:file];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [SVProgressHUD dismiss];
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    [self.delegate imageEditor:nil didFinishEdittingWithImages:files];
                }];
            });
        }
    });
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Narola Dev
    if(CSAppDelegate.isPurchased == FALSE) {
        self.interstitial = [self createAndLoadInterstitial];
    }
    

    
    self.arrayImages = [[NSMutableArray alloc] init];
    self.labelCount.hidden = YES;
    
    self.navigationItem.title = @"Scanning";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    [self.cameraViewController setupCameraView];
    [self.cameraViewController setEnableBorderDetection:NO];
    [self updateTitleLabel];
    
    [self.cameraViewController setCameraViewType:IPDFCameraViewTypeNormal];
}


- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    [self btnFlashOffClicked:nil];
    [self btnSingleClicked:nil];
    self.cameraViewController.enableBorderDetection = !self.imgAutoDetect.isHidden;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self btnFlashOffClicked:nil];
    [self.cameraViewController stop];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.cameraViewController.rt = self.cameraViewController.bounds;
    [self.cameraViewController start];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark  Admod Creation
- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial =  [[GADInterstitial alloc] initWithAdUnitID:ADMOB_KEY];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    //    request.testDevices = @[ kGADSimulatorID, @"2077ef9a63d2b398840261c8221a0c9b" ];
    [interstitial loadRequest:request];
    return interstitial;
}

#pragma mark AdMob Delegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"%@", NSStringFromSelector(_cmd)); // Objective-C
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
    NSLog(@"%@", NSStringFromSelector(_cmd)); // Objective-C
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad{
    NSLog(@"%@", NSStringFromSelector(_cmd)); // Objective-C
}

- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad{
    NSLog(@"%@", NSStringFromSelector(_cmd)); // Objective-C
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad{
    NSLog(@"%@", NSStringFromSelector(_cmd)); // Objective-C
}
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    //Narola Dev
    if(CSAppDelegate.isPurchased == FALSE) {
        self.interstitial = [self createAndLoadInterstitial];
    }
    NSLog(@"%@", NSStringFromSelector(_cmd)); // Objective-C
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad{
    NSLog(@"%@", NSStringFromSelector(_cmd)); // Objective-C
}


#pragma mark -
#pragma mark CameraVC Actions

- (IBAction)focusGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [sender locationInView:self.cameraViewController];
        
        [self focusIndicatorAnimateToPoint:location];
        
        [self.cameraViewController focusAtPoint:location completionHandler:^
         {
             [self focusIndicatorAnimateToPoint:location];
         }];
    }
}

- (void)focusIndicatorAnimateToPoint:(CGPoint)targetPoint
{
    [self.focusIndicator setCenter:targetPoint];
    self.focusIndicator.alpha = 0.0;
    self.focusIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^
    {
         self.focusIndicator.alpha = 1.0;
    }
    completion:^(BOOL finished)
    {
         [UIView animateWithDuration:0.4 animations:^
         {
             self.focusIndicator.alpha = 0.0;
         }];
     }];
}

- (IBAction)borderDetectToggle:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    BOOL enable = !self.cameraViewController.isBorderDetectionEnabled;
    [button setBackgroundImage:[UIImage imageNamed:enable? @"crop_on.png" : @"crop_off.png"] forState:UIControlStateNormal];
    //[self changeButton:sender targetTitle:(enable) ? @"CROP On" : @"CROP Off" toStateEnabled:enable];
    self.cameraViewController.enableBorderDetection = enable;
    [self updateTitleLabel];
}

- (IBAction)filterToggle:(id)sender
{
    [self.cameraViewController setCameraViewType:(self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? IPDFCameraViewTypeNormal : IPDFCameraViewTypeBlackAndWhite];
    [self updateTitleLabel];
}

- (IBAction)torchToggle:(id)sender {
    UIButton *button = (UIButton *)sender;

    BOOL enable = !self.cameraViewController.isTorchEnabled;
    [button setBackgroundImage:[UIImage imageNamed:enable? @"flash_on.png" : @"flash_off.png"] forState:UIControlStateNormal];
    //[self changeButton:sender targetTitle:(enable) ? @"FLASH On" : @"FLASH Off" toStateEnabled:enable];
    self.cameraViewController.enableTorch = enable;
}
- (IBAction)btnFlashOnClicked:(id)sender {
    UIColor *selectedColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:114.0/255.0 alpha:1.0];
    UIColor *deselectedColor = UIColor.whiteColor;
    [self.btnFlashOn setTitleColor:selectedColor forState:UIControlStateNormal];
    [self.btnFlashOff setTitleColor:deselectedColor forState:UIControlStateNormal];
    self.cameraViewController.enableTorch = YES;
}
- (IBAction)btnFlashOffClicked:(id)sender {
    UIColor *selectedColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:114.0/255.0 alpha:1.0];
    UIColor *deselectedColor = UIColor.whiteColor;
    [self.btnFlashOn setTitleColor:deselectedColor forState:UIControlStateNormal];
    [self.btnFlashOff setTitleColor:selectedColor forState:UIControlStateNormal];
    self.cameraViewController.enableTorch = NO;
}
- (IBAction)btnGridClicked:(id)sender {
    [self.viewGrid setHidden:!self.viewGrid.isHidden];
}
- (IBAction)btnAutoDetectClicked:(id)sender {
    self.cameraViewController.enableBorderDetection = self.imgAutoDetect.isHidden;
    [self.imgAutoDetect setHidden:!self.imgAutoDetect.isHidden];
}
- (IBAction)btnSingleClicked:(id)sender {
    UIColor *selectedColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:114.0/255.0 alpha:1.0];
    UIColor *deselectedColor = UIColor.whiteColor;
    [self.btnSingle setTitleColor:selectedColor forState:UIControlStateNormal];
    [self.btnMulti setTitleColor:deselectedColor forState:UIControlStateNormal];
    
    CGPoint ptCenter = self.viewSingleMulti.center;
    ptCenter.x = self.btnSingle.center.x;
    self.viewSingleMulti.center = ptCenter;
    
    self.cameraViewController.enableBorderDetection = YES;
    self.labelCount.hidden = YES;
    [self.btnFinish setHidden: YES];
}
- (IBAction)btnMultiClicked:(id)sender {
    if(CSAppDelegate.isPurchased == FALSE) {
        if (![self checkLimitIsOverArrayCount:MAX_NUM_FILE message:ALERT_PRO_VERSION]) {
            return;
        }
        return;
    }
    
    UIColor *selectedColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:114.0/255.0 alpha:1.0];
    UIColor *deselectedColor = UIColor.whiteColor;
    [self.btnSingle setTitleColor:deselectedColor forState:UIControlStateNormal];
    [self.btnMulti setTitleColor:selectedColor forState:UIControlStateNormal];
    
    CGPoint ptCenter = self.viewSingleMulti.center;
    ptCenter.x = self.btnMulti.center.x;
    self.viewSingleMulti.center = ptCenter;
    
    self.labelCount.hidden = NO;
    self.cameraViewController.enableBorderDetection = NO;
    
    [self.btnFinish setHidden: NO];
}
- (IBAction)btnFinishClicked:(id)sender {
    [self finishWithTakingImages];
}


- (void)updateTitleLabel
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = 0.35;
    [self.titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    NSString *filterMode = (self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? @"TEXT FILTER" : @"COLOR FILTER";
    self.titleLabel.text = [filterMode stringByAppendingFormat:@" | %@",(self.cameraViewController.isBorderDetectionEnabled)?@"AUTOCROP On":@"AUTOCROP Off"];
}

- (void)changeButton:(UIButton *)button targetTitle:(NSString *)title toStateEnabled:(BOOL)enabled
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:(enabled) ? [UIColor colorWithRed:1 green:0.81 blue:0 alpha:1] : [UIColor whiteColor] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark CameraVC Capture Image

- (IBAction)captureButton:(id)sender
{
    __weak typeof(self) weakSelf = self;
//Narola Dev
    if(CSAppDelegate.isPurchased == FALSE) {
        if (self.labelCount.isHidden == FALSE) {
            if (![self checkLimitIsOverArrayCount:[self.arrayImages count] message:ALERT_LIMIT_CAPTURE_OVER]) {
                return;
            }
        }
        if(CSAppDelegate.needApplovinAd) {
            [CSAppDelegate showApplovinAd];
        }else{
            if (self.interstitial.isReady) {
                [self.interstitial presentFromRootViewController:self];
            } else {
                NSLog(@"Ad wasn't ready");
            }
//            CSAppDelegate.needApplovinAd = YES;
        }
    }

    [self.cameraViewController captureImageWithCompletionHander:^(NSString *imageFilePath)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
        
//        if(CSAppDelegate.isPurchased == FALSE) {
//            image = [self drawText:@"Scanned with Scandex" inImage:image];
//        }
//        if (self.cameraViewController.isBorderDetectionEnabled) {
//            ProcessViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProcessViewController"];
//            vc.originalImage = image;
//            vc.delegate = self.delegate;
//            [self.navigationController pushViewController:vc animated:YES];
//        } else {
        
        
        if (self.labelCount.isHidden == FALSE) {
            [self.arrayImages addObject:image];
            self.labelCount.text = [NSString stringWithFormat:@"%ld", [self.arrayImages count]];
        } else {
        
            CropViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CropViewController"];
            vc.adjustedImage = image;
            vc.delegate = self.delegate;
            [self.navigationController pushViewController:vc animated:YES];
        }

//        }
        
//        UIImageView *captureImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageFilePath]];
//        captureImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
//        captureImageView.frame = CGRectOffset(weakSelf.view.bounds, 0, -weakSelf.view.bounds.size.height);
//        captureImageView.alpha = 1.0;
//        captureImageView.contentMode = UIViewContentModeScaleAspectFit;
//        captureImageView.userInteractionEnabled = YES;
//        [weakSelf.view addSubview:captureImageView];
//        
//        UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dismissPreview:)];
//        [captureImageView addGestureRecognizer:dismissTap];
//        
//        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionAllowUserInteraction animations:^
//        {
//            captureImageView.frame = weakSelf.view.bounds;
//        } completion:nil];
    }];
}

- (UIImage*)drawText:(NSString*)text inImage:(UIImage*)image {
    UIFont *font = [UIFont boldSystemFontOfSize:150];
    CGFloat paddingX = 60, paddingY = 60;
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    [[UIColor whiteColor] setFill];
    
    NSDictionary *attr = @{NSFontAttributeName:font};
    CGSize textSize = [text sizeWithAttributes:attr];
    CGRect backRect = CGRectMake(0, image.size.height - textSize.height - 2 * paddingY, image.size.width, textSize.height + 2 * paddingY);
    CGRect textRect = CGRectMake(image.size.width - textSize.width - paddingX, image.size.height - textSize.height - paddingY, textSize.width, textSize.height);
    
    UIRectFill(backRect);
    [text drawInRect:CGRectIntegral(textRect) withAttributes:attr];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)dismissPreview:(UITapGestureRecognizer *)dismissTap {
    [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:^
    {
        dismissTap.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
    }
    completion:^(BOOL finished)
    {
        [dismissTap.view removeFromSuperview];
    }];
}

- (NSString*) deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}


@end
