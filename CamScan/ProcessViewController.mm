//
//  ProcessViewController.m
//  CamScan
//
//  Created by Amit Kulkarni on 19/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "ProcessViewController.h"
#import "MMOpenCVHelper.h"
#import "UIImage+Brightness.h"
#import "UIImage+Contrast.h"
#import "Document.h"

#ifdef PRO_VERSION
#import "CamScan_Pro-Swift.h"
#else
#import "CamScan-Swift.h"
#endif

@interface ProcessViewController ()<EPSignatureDelegate> {
    CGFloat _rotateSlider;
    CGRect _initialRect,final_Rect;
    BOOL filtersVisible;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageViewSignature;
@property (weak, nonatomic) IBOutlet UIStackView *stackButtons;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIStackView *stackOptions;
@property (weak, nonatomic) IBOutlet UIView *viewFilter;

@end

@implementation ProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Proccess Image";
    self.imageView.image = self.cropedImage;
    
    filtersVisible = NO;
    
//    float x = (self.view.frame.size.width / 2) - (self.viewFilter.frame.size.width / 2);
//    self.viewFilter.frame = CGRectMake(x, self.view.frame.size.height + self.viewFilter.frame.size.height, self.viewFilter.frame.size.width, self.viewFilter.frame.size.height);
    self.viewFilter.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    _initialRect = self.imageView.frame;
    final_Rect =self.imageView.frame;
    
    CGRect rect = self.stackButtons.frame;
    rect.origin.y = self.view.frame.size.height - (self.stackOptions.frame.size.height + self.stackButtons.frame.size.height);
    self.stackButtons.frame = rect;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)changeContrast:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.imageView.image = [self.imageView.image imageWithContrast:slider.value];
}

- (IBAction)changeBirghtness:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.imageView.image = [self.imageView.image imageWithBrightness:slider.value];
}

- (IBAction)showOriginal:(id)sender {
    self.imageView.image = self.originalImage;
    
}

- (IBAction)showMagicColor:(id)sender {
    self.imageView.image = [self magicColor:self.originalImage];
}

- (IBAction)showBW:(id)sender {
    self.imageView.image = [self convertToBW];
}

- (IBAction)showGray:(id)sender {
    self.imageView.image = [self convertToGray];
}

- (IBAction)signDocument:(id)sender {
    EPSignatureViewController *vc = [[EPSignatureViewController init] initWithSignatureDelegate:self showsDate:YES showsSaveSignatureOption:YES];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

- (void)epSignature:(EPSignatureViewController * _Nonnull)_ didCancel:(NSError * _Nonnull)error {
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
                                         recognizer.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.center = finalPoint;
        } completion:nil];
        
    }
    
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
    
}

- (void)epSignature:(EPSignatureViewController * _Nonnull)_ didSign:(UIImage * _Nonnull)signatureImage boundingRect:(CGRect)boundingRect {
    self.imageViewSignature.image = signatureImage;
    self.imageViewSignature.center = self.view.center;
}

- (UIImage *)convertToGray {
    cv::Mat grayImage = [MMOpenCVHelper cvMatGrayFromAdjustedUIImage:self.imageView.image];
    
    cv::GaussianBlur(grayImage, grayImage, cvSize(11,11), 0);
    cv::adaptiveThreshold(grayImage, grayImage, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 5, 2);
    
    UIImage *grayeditImage=[MMOpenCVHelper UIImageFromCVMat:grayImage];
    grayImage.release();
    
    return grayeditImage;
}

-(UIImage *)magicColor:(UIImage *)processedImage{
    cv::Mat  original = [MMOpenCVHelper cvMatFromAdjustedUIImage:processedImage];
    
    cv::Mat new_image = cv::Mat::zeros( original.size(), original.type() );
    
    original.convertTo(new_image, -1, 1.9, -80);
    
    original.release();
    UIImage *magicColorImage=[MMOpenCVHelper UIImageFromCVMat:new_image];
    new_image.release();
    return magicColorImage;
}

- (UIImage *)convertToBW {
    cv::Mat original = [MMOpenCVHelper cvMatGrayFromAdjustedUIImage:self.imageView.image];
    cv::Mat new_image = cv::Mat::zeros( original.size(), original.type());
    original.convertTo(new_image, -1, 1.4, -50);
    original.release();
    
    UIImage *blackWhiteImage=[MMOpenCVHelper UIImageFromCVMat:new_image];
    new_image.release();
    
    return blackWhiteImage;
}

- (CATransform3D)rotateTransform:(CATransform3D)initialTransform clockwise:(BOOL)clockwise
{
    CGFloat arg = _rotateSlider * M_PI;
    if(!clockwise){
        arg *= -1;
    }
    
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, arg, 0, 0, 1);
    transform = CATransform3DRotate(transform, 0*M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, 0*M_PI, 1, 0, 0);
    
    return transform;
}

- (IBAction)rotateImage:(id)sender {
    CGFloat value = (int)floorf((_rotateSlider + 1)*2) + 1;
    if (value > 4) { value -= 4; }
    _rotateSlider = value / 2 - 1;
    
    CATransform3D transform = [self rotateTransform:CATransform3DIdentity clockwise:YES];
    
    CGFloat arg = _rotateSlider*M_PI;
    CGFloat Wnew = fabs(_initialRect.size.width * cos(arg)) + fabs(_initialRect.size.height * sin(arg));
    CGFloat Hnew = fabs(_initialRect.size.width * sin(arg)) + fabs(_initialRect.size.height * cos(arg));
    
    CGFloat Rw = final_Rect.size.width / Wnew;
    CGFloat Rh = final_Rect.size.height / Hnew;
    CGFloat scale = MIN(Rw, Rh) * 1;
    transform = CATransform3DScale(transform, scale, scale, 1);
    self.imageView.layer.transform = transform;
    //_cropRect.layer.transform = transform;
}

- (IBAction)findOCR:(id)sender {
    [self showErrorAlertWithMessage:@"Under Progress"];
}

- (IBAction)applyFilters:(id)sender {
    if (filtersVisible) {
        filtersVisible = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.viewFilter.alpha = 0;
            float x = (self.view.frame.size.width / 2) - (self.viewFilter.frame.size.width / 2);
            self.viewFilter.frame = CGRectMake(x, self.view.frame.size.height + self.viewFilter.frame.size.height + self.stackOptions.frame.size.height, self.viewFilter.frame.size.width, self.viewFilter.frame.size.height);
            
            self.stackButtons.frame = CGRectMake(0, self.view.frame.size.height - (self.stackOptions.frame.size.height + self.stackButtons.frame.size.height), self.viewFilter.frame.size.width, self.stackButtons.frame.size.height);
        }];
    } else {
        filtersVisible = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.viewFilter.alpha = 1;
            float x = (self.view.frame.size.width / 2) - (self.viewFilter.frame.size.width / 2);
            self.viewFilter.frame = CGRectMake(x, self.view.frame.size.height - (self.viewFilter.frame.size.height + self.stackOptions.frame.size.height), self.viewFilter.frame.size.width, self.viewFilter.frame.size.height);
            
            self.stackButtons.frame = CGRectMake(0, self.view.frame.size.height + self.stackOptions.frame.size.height + self.stackButtons.frame.size.height, self.viewFilter.frame.size.width, self.stackButtons.frame.size.height);
        }];
    }
}

- (NSString *)saveImage:(UIImage *)image {
    NSData *originalData = UIImagePNGRepresentation(image);
    NSString *originalName = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
    NSString *originalPath = [NSString pathWithComponents:@[NSHomeDirectory(), @"Documents", originalName]];
    [originalData writeToFile:originalPath atomically:YES];
    
    return originalName;
}

- (UIImage*) mergeTwoImages: (UIImage*)topImage bottom:(UIImage*) bottomImage {
    int width = bottomImage.size.width;
    int height = bottomImage.size.height;
    
    CGSize newSize = CGSizeMake(width, height);
    static CGFloat scale = -1.0;
    
    if (scale<0.0)
    {
        UIScreen *screen = [UIScreen mainScreen];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
        {
            scale = [screen scale];
        }
        else
        {
            scale = 0.0;    // Use the standard API
        }
    }
    
    if (scale>0.0)
    {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    }
    else
    {
        UIGraphicsBeginImageContext(newSize);
    }
    
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    [topImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)done:(id)sender {
    
    if (self.imageViewSignature.image != nil) {
        self.imageView.image = [self mergeTwoImages:self.imageViewSignature.image bottom:self.imageView.image];
    }
    
    if (self.document) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        self.document.originalFile = [self saveImage:self.originalImage];
        self.document.modifiedFile = [self saveImage:self.imageView.image];
        [realm commitWriteTransaction];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            File *document = [[File alloc] init];
            document.originalFile = [self saveImage:self.originalImage];
            document.modifiedFile = [self saveImage:self.imageView.image];
            document.createdDateTime = [NSDate date];
            [self.delegate didDinishFlow:document];
        }];
    }
}

@end
