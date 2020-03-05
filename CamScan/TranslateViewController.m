//
//  TranslateViewController.m
//  CamScan
//
//  Created by Liao Fang on 5/8/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "TranslateViewController.h"
#import "LanguageViewController.h"
#import "SVProgressHUD.h"
#import "QBPlasticPopupMenu.h"

#import <AVFoundation/AVFoundation.h>

NSString* const API_KEY = @"AIzaSyCRes9mM3Btcw01_yPoWL2-P3tOjzxFMlw";

@interface TranslateViewController () <UITextViewDelegate, AVAudioPlayerDelegate>
    
@property (weak, nonatomic) IBOutlet UIImageView *swapButton;
@property (weak, nonatomic) IBOutlet UIView *leftFrame;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UIView *rightFrame;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIButton *cpButton1;
@property (weak, nonatomic) IBOutlet UIButton *soundButton1;
@property (weak, nonatomic) IBOutlet UIButton *moreButton1;
@property (weak, nonatomic) IBOutlet UITextView *textView1;
@property (weak, nonatomic) IBOutlet UIButton *cpButton2;
@property (weak, nonatomic) IBOutlet UIButton *soundButton2;
@property (weak, nonatomic) IBOutlet UIButton *moreButton2;
@property (weak, nonatomic) IBOutlet UITextView *textView2;
    
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomConstraint;
    
@property (nonatomic) UITextView* activeTextView;
    
@property (nonatomic, strong) QBPlasticPopupMenu *plasticPopupMenu1;
@property (nonatomic, strong) QBPlasticPopupMenu *plasticPopupMenu2;

@property (nonatomic) NSString* selectedLanguage1;
@property (nonatomic) NSString* selectedLangCode1;
@property (nonatomic) NSString* selectedLanguage2;
@property (nonatomic) NSString* selectedLangCode2;
    
@property (nonatomic, strong) AVAudioPlayer* player;

@property (nonatomic) BOOL isOk;
@end

@implementation TranslateViewController
    


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Translate";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"buttonBack.png"] style:UIBarButtonItemStyleDone  target:self action:@selector(done)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSwapLanguage)];
    [tap setNumberOfTapsRequired:1];
    [self.swapButton addGestureRecognizer:tap];
    
    [self.leftFrame.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.leftFrame.layer setBorderWidth:1.0];
    [self.rightFrame.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.rightFrame.layer setBorderWidth:1.0];
   
    [self.textView1.layer setCornerRadius:15.0];
    [self.textView2.layer setCornerRadius:15.0];
     
    self.textView1.text = self.text;
     
    [self.textView1 setDelegate:self];
    [self.textView2 setDelegate:self];
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(textViewDoneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    
    [self.textView1 setInputAccessoryView:keyboardToolbar];
    [self.textView2 setInputAccessoryView:keyboardToolbar];
    
    
    QBPopupMenuItem *item = [QBPopupMenuItem itemWithTitle:@"Edit Text" target:self action:@selector(editText1)];
    QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:@"Share" target:self action:@selector(share1)];
    QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:@"Delete" target:self action:@selector(delete1)];
    NSArray *items1 = @[item, item2, item3];
    QBPlasticPopupMenu *plasticPopupMenu1 = [[QBPlasticPopupMenu alloc] initWithItems:items1];
    plasticPopupMenu1.height = 40;
    self.plasticPopupMenu1 = plasticPopupMenu1;
    
    QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:@"Edit Text" target:self action:@selector(editText2)];
    QBPopupMenuItem *item5 = [QBPopupMenuItem itemWithTitle:@"Share" target:self action:@selector(share2)];
    QBPopupMenuItem *item6 = [QBPopupMenuItem itemWithTitle:@"Delete" target:self action:@selector(delete2)];
    NSArray *items2 = @[item4, item5, item6];
    QBPlasticPopupMenu *plasticPopupMenu2 = [[QBPlasticPopupMenu alloc] initWithItems:items2];
    plasticPopupMenu2.height = 40;
    self.plasticPopupMenu2 = plasticPopupMenu2;
    
    
    self.selectedLanguage1 = @"Auto Detect";
    self.selectedLangCode1 = @"adt";
    self.selectedLanguage2 = @"English";
    self.selectedLangCode2 = @"en";
    
    [self translate];
}
    
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
    
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)done {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
    
- (void) onSwapLanguage {
    NSString *temp = self.selectedLanguage1;
    self.selectedLanguage1 = self.selectedLanguage2;
    self.selectedLanguage2 = temp;
    
    temp = self.selectedLangCode1;
    self.selectedLangCode1 = self.selectedLangCode2;
    self.selectedLangCode2 = temp;
    
    if ([self.selectedLangCode2 isEqualToString:@"adt"]) {
        self.selectedLanguage2 = @"English";
        self.selectedLangCode2 = @"en";
    }
    
    [self.leftLabel setText:self.selectedLanguage1];
    [self.rightLabel setText:self.selectedLanguage2];
    
    [self translate];
}

- (IBAction)onSelectLang:(UIButton *)sender {
    [self fetchLanguages:sender.tag];
}

- (void)navigateLanguageVC:(NSInteger)idx {
    LanguageViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LanguageViewController"];
    
    vc.didDismiss = ^(NSString *name, NSString *code) {
        if (idx == 1) {
            self.leftLabel.text = name;
            self.selectedLanguage1 = name;
            self.selectedLangCode1 = code;
        } else {
            self.rightLabel.text = name;
            self.selectedLanguage2 = name;
            self.selectedLangCode2 = code;
        }
        
        [self translate];
    };
    
    //vc.supportedLanguages = [NSMutableArray mutableCopy];
    //[vc.supportedLanguages addObjectsFromArray:self.supportedLanguages];
    vc.supportedLanguages = self.supportedLanguages; //  NSMutableArray mutableCopy];
    
    if (idx == 1) {
        vc.selectedLanguage = self.selectedLanguage1;
        vc.selectedLangCode = self.selectedLangCode1;
        
        NSMutableDictionary *autoD = [NSMutableDictionary dictionary];
        [autoD setObject:@"adt" forKey:@"language"];
        [autoD setObject:@"Auto Detect" forKey:@"name"];
        
        [vc.supportedLanguages insertObject:autoD atIndex:0];
        
    } else {
        vc.selectedLanguage = self.selectedLanguage2;
        vc.selectedLangCode = self.selectedLangCode2;
    }
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

- (void)fetchLanguages:(NSInteger)idx {
    
    if (self.supportedLanguages != nil) {
        [self navigateLanguageVC:idx];
    } else {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD showWithStatus:@"Fetching Languages..."];
        
        //Init the NSURLSession with a configuration
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        
        NSString* targetLanguage = [[NSLocale currentLocale] languageCode];
        if (targetLanguage == nil) {
            targetLanguage = @"en";
        }
        
        //Create an URLRequest
        NSString *params = [NSString stringWithFormat:@"key=%@&target=%@",API_KEY, targetLanguage];
        NSString *targetUrl = [NSString stringWithFormat:@"https://translation.googleapis.com/language/translate/v2/languages?%@", params];
        
        NSURL *url = [NSURL URLWithString:targetUrl];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"GET"];
        
        //Create task
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            //Handle your response here
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //NSLog(@"%@",responseDict);
            
            [SVProgressHUD dismiss];
            
            BOOL isOk = NO;
            
            NSMutableDictionary* dataDic = [responseDict objectForKey:@"data"];
            if (dataDic != nil) {
                NSMutableArray* langArray = [dataDic objectForKey:@"languages"];
                if (langArray != nil) {
                    isOk = YES;
                    
                    self.supportedLanguages = [NSMutableArray arrayWithArray:langArray];
                    //[self.supportedLanguages addObjectsFromArray:langArray];
                    
                    [self navigateLanguageVC:idx];
                }
            }
            
            if (!isOk) {
                [self showErrorAlertWithMessage:@"Oops! It seems that something went wrong and supported languages cannot be fetched."];
            }
        }];
        
        [dataTask resume];
    }
}

- (void)translate {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    [SVProgressHUD showWithStatus:@"Translating..."];
    
    //Init the NSURLSession with a configuration
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    //Create an URLRequest
    NSURL *url = [NSURL URLWithString:@"https://translation.googleapis.com/language/translate/v2"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSString* targetLanguage = self.selectedLangCode2;
    NSString* textToTranslate = self.textView1.text;
    
    //Create POST Params and add it to HTTPBody
    NSString *params = [NSString stringWithFormat:@"key=%@&q=%@&format=text&target=%@",API_KEY,textToTranslate, targetLanguage];
    
    if (![self.selectedLangCode1 isEqualToString:@"adt"] && ![self.selectedLangCode1 isEqualToString:self.selectedLangCode2]) {
        NSString* sourceLanguage = self.selectedLangCode1;
        params = [params stringByAppendingString:[NSString stringWithFormat:@"&source=%@", sourceLanguage]];
    }
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Create task
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //Handle your response here
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@",responseDict);
        
        BOOL isOk = NO;
        
        NSMutableDictionary* dataDic = [responseDict objectForKey:@"data"];
        if (dataDic != nil) {
            NSMutableArray* translationArray = [dataDic objectForKey:@"translations"];
            if (translationArray != nil) {
                NSString *translatedText = [[translationArray firstObject] objectForKey:@"translatedText"];
                
                if (translatedText != nil) {
                    self.textView2.text = translatedText;
                    isOk = YES;
                }
            }
        }
        
        [SVProgressHUD dismiss];
        
        if (!isOk) {
            [self showErrorAlertWithMessage:@"Oops! It seems that something went wrong and translation cannot be done."];
        }
    }];
    
    [dataTask resume];
}

- (IBAction)onCopy:(UIButton *)sender {
    [self.view endEditing:YES];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (sender.tag == 1) {
        pasteboard.string = self.textView1.text;
    }
    else{
        pasteboard.string = self.textView2.text;
    }
    [SVProgressHUD showSuccessWithStatus:@"Copied to clipboard"];
}

- (IBAction)onSpeech:(UIButton *)sender {
    
    [self.soundButton1 setEnabled:NO];
    [self.soundButton2 setEnabled:NO];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    [SVProgressHUD showWithStatus:@"Text-to-Speech..."];
    
    //Init the NSURLSession with a configuration
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    //Create an URLRequest
    NSURL *url = [NSURL URLWithString:@"https://texttospeech.googleapis.com/v1beta1/text:synthesize"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSString *textToSpeech, *languageCode;
    
    if (sender.tag == 1) {
        textToSpeech = self.textView1.text;
        languageCode = [self.selectedLangCode1 isEqualToString:@"adt"]? @"en" : self.selectedLangCode1;
    } else {
        textToSpeech = self.textView2.text;
        languageCode = self.selectedLangCode2;
    }
    
    
    //Create POST Params and add it to HTTPBody
//    NSString *params = [NSString stringWithFormat:@"key=%@&q=%@&format=text&target=%@",API_KEY,textToTranslate, targetLanguage];
//
    NSDictionary *jsonBodyDict = @{@"input": @{@"text":textToSpeech}, @"voice": @{@"languageCode":languageCode/*, @"name":@"en-US-Wavenet-F"*/}, @"audioConfig": @{@"audioEncoding": @"LINEAR16"}};
    
    //NSLog(@"%@", jsonBodyDict);
    
    NSData *params = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    [urlRequest addValue:API_KEY forHTTPHeaderField:@"X-Goog-Api-Key"];
    [urlRequest addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [urlRequest setHTTPBody: params];
    
    //Create task
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //Handle your response here
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        //NSLog(@"%@",responseDict);
        
        self.isOk = NO;

        NSString* audioContent = [responseDict objectForKey:@"audioContent"];
        if (audioContent != nil) {
            NSData* audioData = [[NSData alloc] initWithBase64EncodedString:audioContent options:nil];
            if (audioData != nil) {
                self.isOk = YES;
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    
                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                    [[AVAudioSession sharedInstance] setActive:YES error:nil];
                    
                    self.player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
                    
                    //NSLog(@"%@",[self.player data]);
                    
                    if (self.player != nil) {
                        [self.player setDelegate:self];
                        [self.player setVolume:1.0];
                        [self.player prepareToPlay];
                        [self.player play];
                    }
                });
            }
        }
        
        [SVProgressHUD dismiss];
        
        if (!self.isOk) {
            [self.soundButton1 setEnabled:YES];
            [self.soundButton2 setEnabled:YES];
            [self showErrorAlertWithMessage:@"Oops! It seems that something went wrong and text-to-speech cannot be done."];
        }
    }];
    
    [dataTask resume];
}
    
- (IBAction)showPopupMenu:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    CGRect frame = CGRectMake(button.frame.origin.x,
                              button.frame.origin.y + 120,
                              button.frame.size.width,
                              button.frame.size.height);
    
    if (button.tag == 1) {
        [self.plasticPopupMenu1 showInView:self.view targetRect:frame animated:YES];
    } else {
        [self.plasticPopupMenu2 showInView:self.view targetRect:frame animated:YES];
    }
}
    
- (void)editText1 {
    [self.textView1 becomeFirstResponder];
}
    
- (void)share1 {
    NSArray *items = @[self.textView1.text];
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}
    
- (void)delete1 {
    self.textView1.text = @"";
}
    
- (void)editText2 {
    [self.textView2 becomeFirstResponder];
}
    
- (void)share2 {
    NSArray *items = @[self.textView2.text];
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}
    
- (void)delete2 {
    self.textView2.text = @"";
}
    
#pragma mark - textField
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.activeTextView = textView;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    
    if ([textView isEqual:self.textView1 ]) {
        [self translate];
    }
    
    self.activeTextView = nil;
    
    return YES;
}
    
-(void)textViewDoneButtonPressed {
    if (self.activeTextView != nil) {
        [self textViewShouldEndEditing:self.activeTextView];
    }
}
    
#pragma mark - keyboard
-(void)keyboardWillShow:(NSNotification*) notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat distanceToBottom = self.view.frame.size.height - (self.activeTextView.frame.origin.y + self.activeTextView.frame.size.height + 120);
    
    CGFloat collapseSpace = keyboardRect.size.height - distanceToBottom;
    if (collapseSpace > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.viewTopConstraint.constant -= collapseSpace;
            self.viewBottomConstraint.constant += collapseSpace;
        }];
    }
}
    
-(void)keyboardWillHide:(NSNotification*) notification {
    [UIView animateWithDuration:0.3 animations:^{
        self.viewTopConstraint.constant = 40;
        self.viewBottomConstraint.constant = 0;
    }];
}
    
#pragma mark - tap gesture
    
- (IBAction)onTappedView:(UITapGestureRecognizer *)sender {
    if (self.activeTextView != nil) {
        [self textViewShouldEndEditing:self.activeTextView];
    }
}
    
#pragma mark - AVAudioPlayer

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.soundButton1 setEnabled:YES];
    [self.soundButton2 setEnabled:YES];
    
    [self.player setDelegate:nil];
    self.player = nil;
}
    
@end
