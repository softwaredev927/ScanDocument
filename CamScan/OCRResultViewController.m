//
//  OCRResultViewController.m
//  CamScan
//
//  Created by Amit Kulkarni on 27/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "OCRResultViewController.h"
#import "SVProgressHUD.h"
#import "Preferences.h"
#import "TranslateViewController.h"

@interface OCRResultViewController () <UITextViewDelegate>
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomConstraint;
    
    @property (nonatomic) BOOL initFlag;
@end

@implementation OCRResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initFlag = YES;
    
    self.navigationItem.title = @"OCR";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"buttonBack.png"] style:UIBarButtonItemStyleDone  target:self action:@selector(done)];
    
    [self.textResult setDelegate:self];
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(textViewDoneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    
    [self.textResult setInputAccessoryView:keyboardToolbar];
}

- (IBAction)onEdit:(UIButton *)sender {
    [self.textResult setEditable:YES];
    [self.textResult setSelectable:YES];
    
    [self.textResult becomeFirstResponder];
}

- (IBAction)onCopy:(UIButton *)sender {
    [self.view endEditing:YES];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.textResult.text;
    
    [SVProgressHUD showSuccessWithStatus:@"Copied to clipboard"];
}

- (IBAction)onTranslate:(UIButton *)sender {
    [self navigateTranslateVC];
}

- (IBAction)onShare:(UIButton *)sender {
    [self share];
}

- (IBAction)onSave:(UIButton *)sender {
    
}

- (void)share {
    NSArray *items = @[self.textResult.text];
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)done {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (!self.image) {
        [super viewDidAppear:animated];
        return;
    }
    
    if (self.initFlag == YES) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD showWithStatus:@"Please wait.."];
        
        Client *client = [[Client alloc] initWithApplicationID:[[Preferences sharedInstance] ocrAppId] password:[[Preferences sharedInstance] ocrPassword]];
        [client setDelegate:self];
        
        ProcessingParams* params = [[ProcessingParams alloc] init];
        [client processImage:self.image withParams:params];
        
        self.initFlag = NO;
    }
    
    [super viewDidAppear:animated];
}
    
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navigateTranslateVC {
    TranslateViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TranslateViewController"];
    vc.text = self.textResult.text;
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

#pragma mark - ClientDelegate implementation

- (void)clientDidFinishUpload:(Client *)sender {
}

- (void)clientDidFinishProcessing:(Client *)sender {
}

- (void)client:(Client *)sender didFinishDownloadData:(NSData *)downloadedData {
    [SVProgressHUD dismiss];
    NSString* result = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
    self.textResult.text = result;
    
    [UIView animateWithDuration:0.4 animations:^
     {
         [self.toolBarView setHidden:NO];
     }];
    
    if (self.isImmediateTranslate == YES) {
        [self navigateTranslateVC];
    }
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
}

- (void)client:(Client *)sender didFailedWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    [self showErrorAlertWithMessage:[error localizedDescription]];
}

    
#pragma mark - textView

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    
    [textView setEditable:NO];
    [textView setSelectable:NO];
    
    return YES;
}
    
-(void)textViewDoneButtonPressed {
    [self textViewShouldEndEditing:self.textResult];
}
    
#pragma mark - keyboard
-(void)keyboardWillShow:(NSNotification*) notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat distanceToBottom = self.view.frame.size.height - (self.textResult.frame.origin.y + self.textResult.frame.size.height);
    
    CGFloat collapseSpace = keyboardRect.size.height - distanceToBottom;
    if (collapseSpace > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.textBottomConstraint.constant += collapseSpace;
        }];
    }
}
    
-(void)keyboardWillHide:(NSNotification*) notification {
    [UIView animateWithDuration:0.3 animations:^{
        self.textBottomConstraint.constant = 5;
    }];
}
    
#pragma mark - tap gesture
    
- (IBAction)onTappedView:(UITapGestureRecognizer *)sender {
    [self textViewDoneButtonPressed];
}
    
@end
