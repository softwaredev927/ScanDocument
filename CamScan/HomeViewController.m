//
//  HomeViewController.m
//  CamScan
//
//  Created by Amit Kulkarni on 19/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "ViewController.h"
#import "CropViewController.h"

#import "DocumentTableViewCell.h"
#import "ImageTableViewCell.h"
#import "DocumentAddPageCell.h"

#import "Document.h"

#import "DocumentCollectionViewCell.h"

#import "PDFPreviewViewController.h"

#import "UIViewController+MJPopupViewController.h"
#import "PopViewControllerDelegate.h"
#import "RenameDocumentViewController.h"

#import "OCRResultViewController.h"

#import "CLImageEditor.h"
#import "KRLCollectionViewGridLayout.h"

#import "UIImage+Thumbnail.h"
#import "AppDelegate.h"
#import "Preferences.h"
#import "DMPasscode.h"
#import "UploadViewController.h"

#import <DropboxSDK/DropboxSDK.h>
#import "SVProgressHUD.h"
//#import "SlideMenuController.h"
#import "SWRevealViewController.h"

#ifdef PRO_VERSION
    #import "CamScan_Pro-Swift.h"
#else
    #import "CamScan-Swift.h"
#endif

#import "CreolePhotoCollection/CreolePhotoSelection.h"

@import GoogleMobileAds;
@import Firebase;

@interface HomeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PopViewControllerDelegate, CLImageEditorDelegate, UITabBarDelegate, DBRestClientDelegate, UISearchBarDelegate, GADInterstitialDelegate, GADBannerViewDelegate, CreolePhotoSelectionDelegate> {
    UIDocumentInteractionController *docController;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchbarHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeight;
@property (nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet KRLCollectionViewGridLayout *layout;
@property (nonatomic) Document *currentDocument;
@property (nonatomic) RLMResults<Document *> *documents;
@property (nonatomic) RLMArray<File *> *files;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UIImagePickerController *picker;
@property (nonatomic) CreolePhotoSelection *cre_picker;
@property (nonatomic, retain) NSMutableArray *arrSelectedPhotos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *buttonGallery;
@property (weak, nonatomic) IBOutlet UIButton *buttonCamera;
@property (weak, nonatomic) IBOutlet UIButton *buttonUpgrade;
@property (nonatomic) DBRestClient *restClient;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIView *mainToolbar;
@property (weak, nonatomic) IBOutlet UIView *subToolbar;
@property (weak, nonatomic) IBOutlet UIView *selectionBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *toolbarSearchButton;
@property (weak, nonatomic) IBOutlet UIButton *toolbarArrangeButton;
@property (weak, nonatomic) IBOutlet UIButton *toolbarSortButton;
@property (weak, nonatomic) IBOutlet UIButton *toolbarSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *toolbarBackButton;
@property (weak, nonatomic) IBOutlet UIButton *toolbarShareButton;
@property (weak, nonatomic) IBOutlet UIButton *toolbarCopyButton;
@property (weak, nonatomic) IBOutlet UIButton *toolbarTrashButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchButtonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrangeButtonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sortButtonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectButtonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backButtonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shareButtonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *toobarCopyButtonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *trashButtonImageView;

@property (nonatomic) UIBarButtonItem *itemList, *itemGrid;

@property (weak, nonatomic) IBOutlet UIStackView *stackButtons;

@property(nonatomic, strong) GADInterstitial *interstitial;
@property(nonatomic, strong) GADBannerView *bannerView;

@property(nonatomic, strong) RenameDocumentViewController *renameDocVC;

@property(nonatomic) BOOL sortAscending;
@property(nonatomic) BOOL selectionMode;
@property(nonatomic) NSInteger selectedIndex;

@end

UIImage *imgSelect;
BOOL isSelecteFromGallery;

@implementation HomeViewController

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    self.documents = nil;
    self.documents = [Document objectsWhere:@"documentName CONTAINS[c] %@", searchBar.text];
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    self.documents = nil;
    self.documents = [Document allObjects];
    [self.tableView reloadData];
    [self.collectionView reloadData];
    
    [searchBar setHidden:YES];
}

- (IBAction)searchButtonTapped:(id)sender {
    [self.searchBar setHidden:NO];
}

- (IBAction)sortButtonTapped:(id)sender {
    self.sortAscending = !self.sortAscending;
    self.documents = [self.documents sortedResultsUsingProperty:@"createdDateTime" ascending:self.sortAscending];
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (IBAction)toolbarBackButtonTapped:(id)sender {
    self.selectionMode = NO;
    self.selectedIndex = -1;
    self.selectionBackgroundView.hidden = true;
    
    self.mainToolbar.hidden = false;
    self.subToolbar.hidden = true;
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (IBAction)toolBarShareButtonTapped:(id)sender {
    if (self.selectedIndex == -1) {
        return;
    }
    
    Document *doc = self.documents[self.selectedIndex];
    [self createPDF: doc];
}

- (IBAction)copyButtonTapped:(id)sender {
    if (self.selectedIndex == -1) {
        return;
    }
    
    Document *doc = self.documents[self.selectedIndex];
    NSMutableArray *array = [NSMutableArray array];
    for (File *file in doc.documents) {
        [array addObject:file];
    }
    
    self.renameDocVC = [[RenameDocumentViewController alloc] initWithNibName:@"RenameDocumentViewController" bundle:nil];
    self.renameDocVC.array = array;
    self.renameDocVC.delegate = self;
    [self presentPopupViewController:self.renameDocVC animationType:MJPopupViewAnimationSlideBottomTop];
}

- (IBAction)deleteButtonTapped:(id)sender {
    if (self.selectedIndex == -1) {
        return;
    }
    
    Document *doc = self.documents[self.selectedIndex];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObject:doc];
    [realm commitWriteTransaction];
    
    self.selectedIndex = -1;
    
    self.documents = [Document allObjects];
    [self.collectionView reloadData];
    
    [self updateToolbarButtons];
}

- (IBAction)selectButtonTapped:(id)sender {
    self.selectionMode = YES;
    self.selectionBackgroundView.hidden = false;
    
    self.mainToolbar.hidden = true;
    self.subToolbar.hidden = false;
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void) addBannerViewToView:(UIView *) bannerView {
    
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    
    if (@available(iOS 11.0, *)) {
        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
        
        if (!self.currentDocument) {
            [NSLayoutConstraint activateConstraints:@[
                                                      [guide.leftAnchor constraintEqualToAnchor:bannerView.leftAnchor],
                                                      [guide.rightAnchor constraintEqualToAnchor:bannerView.rightAnchor],
                                                      [self.buttonCamera.topAnchor constraintEqualToAnchor:bannerView.bottomAnchor constant:8]
                                                      ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                                                      [guide.leftAnchor constraintEqualToAnchor:bannerView.leftAnchor],
                                                      [guide.rightAnchor constraintEqualToAnchor:bannerView.rightAnchor],
                                                      [self.stackButtons.topAnchor constraintEqualToAnchor:bannerView.bottomAnchor constant:0]
                                                      ]];
        }
    } else {
        // Fallback on earlier versions
        if (!self.currentDocument) {
            [self.view addConstraints:@[
                                        [NSLayoutConstraint constraintWithItem:bannerView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.buttonCamera
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0],
                                        [NSLayoutConstraint constraintWithItem:bannerView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0]
                                        ]];
        } else {
            [self.view addConstraints:@[
                                        [NSLayoutConstraint constraintWithItem:bannerView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.stackButtons
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0],
                                        [NSLayoutConstraint constraintWithItem:bannerView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0]
                                        ]];
        }
    }
    
}

-(void)updateToolbarButtons {
    if (self.documents.count == 0) {
        self.searchButtonImageView.alpha = 0.5;
        self.toolbarSearchButton.enabled = false;
        self.sortButtonImageView.alpha = 0.5;
        self.toolbarSortButton.enabled = false;
        self.selectButtonImageView.alpha = 0.5;
        self.toolbarSelectButton.enabled = false;
    } else {
        self.searchButtonImageView.alpha = 1;
        self.toolbarSearchButton.enabled = true;
        self.sortButtonImageView.alpha = 1;
        self.toolbarSortButton.enabled = true;
        
        if (self.collectionView.isHidden) {
            self.selectButtonImageView.alpha = 0.5;
            self.toolbarSelectButton.enabled = false;
        } else {
            self.selectButtonImageView.alpha = 1;
            self.toolbarSelectButton.enabled = true;
        }
    }
    
    if (self.selectionMode && self.selectedIndex >=0) {
        self.shareButtonImageView.alpha = 1;
        self.toolbarShareButton.enabled = true;
        self.toobarCopyButtonImageView.alpha = 1;
        self.toolbarCopyButton.enabled = true;
        self.trashButtonImageView.alpha = 1;
        self.toolbarTrashButton.enabled = true;
    } else {
        self.shareButtonImageView.alpha = 0.5;
        self.toolbarShareButton.enabled = false;
        self.toobarCopyButtonImageView.alpha = 0.5;
        self.toolbarCopyButton.enabled = false;
        self.trashButtonImageView.alpha = 0.5;
        self.toolbarTrashButton.enabled = false;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Narola Dev
    if(CSAppDelegate.isPurchased == FALSE) {
        self.interstitial = [self createAndLoadInterstitial];
        self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        [self addBannerViewToView:self.bannerView];
        self.bannerView.adUnitID = ADMOB_BANNER_KEY; //ADMOB_KEY;
        self.bannerView.rootViewController = self;
        [self.bannerView loadRequest:[GADRequest request]];
    }

    
//    self.picker = [[UIImagePickerController alloc] init];
//    self.picker.delegate = self;
//    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.cre_picker = [[CreolePhotoSelection alloc]initWithNibName:@"CreolePhotoSelection" bundle:nil];
    self.cre_picker.delegate = self;
    self.cre_picker.strTitle = @"Select Photos";
    self.cre_picker.arySelectedPhoto = self.arrSelectedPhotos;
    self.cre_picker.maxCount = 100;
    
    self.tableView.hidden = NO;
    self.collectionView.hidden = YES;
    
    if (!self.currentDocument) {
        self.navigationItem.title = @"My Docs(0)";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStyleDone target:self action:@selector(showSettings)];
        
        self.itemGrid = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"grid.png"] style:UIBarButtonItemStyleDone target:self action:@selector(showGrid)];
        self.itemList = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStyleDone target:self action:@selector(showList)];
        self.navigationItem.leftBarButtonItem = self.itemGrid;
        
    } else {
        self.searchBar.hidden = true;
        self.mainToolbar.hidden = true;
        self.subToolbar.hidden = true;
        
        self.toolbarHeight.constant = 0;
        
//        CGRect rect = self.tableView.frame;
//        rect.origin.y = 0;
//        rect.size.height += self.searchBar.frame.size.height;
//        self.tableView.frame = rect;
//        
//        rect = self.collectionView.frame;
//        rect.origin.y = 0;
//        rect.size.height += self.searchBar.frame.size.height;
//        self.collectionView.frame = rect;
//        
        
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(createPDF)];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DocumentCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    //self.layout.numberOfItemsPerLine = 3;
    
//    self.collectionView.backgroundColor = [UIColor colorWithRed:0.929  green:0.929  blue:0.929 alpha:1];
    self.view.backgroundColor = [UIColor colorWithRed:0.929  green:0.929  blue:0.929 alpha:1];
//    self.tableView.backgroundColor = [UIColor colorWithRed:0.929  green:0.929  blue:0.929 alpha:1];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DocumentTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"imagecell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DocumentAddPageCell" bundle:nil] forCellReuseIdentifier:@"addPageCell"];

    [self reloadDocuments];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (!delegate.passcodeEntered && [[Preferences sharedInstance] passCodeEnabled]) {
        [DMPasscode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
            if (success) {
                delegate.passcodeEntered = YES;
            } else {
                if (error) {
                    [self showErrorAlertWithMessage:@"Passcode did not match"];
                }
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    if (!self.currentDocument) {
        delegate.popupState = @"Popup";
        [self checkLimitIsOverArrayCount:MAX_NUM_FILE message:ALERT_LIMIT_OVER];
        
        SWRevealViewController *revealController = [self revealViewController];
        
        [revealController panGestureRecognizer];
        [revealController tapGestureRecognizer];
    }

    self.sortAscending = YES;
    self.selectionMode = NO;
    self.selectedIndex = -1;
    [self updateToolbarButtons];
    
    if ([delegate.popupState isEqualToString:@""]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0), dispatch_get_main_queue(), ^{
            [delegate reviewing:self];
        });
    }
    
    if (!self.currentDocument) {
        [self showGrid];
    }
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.passcodeEntered = NO;
}

- (void)appplicationIsActive:(NSNotification *)notification {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (!delegate.passcodeEntered && [[Preferences sharedInstance] passCodeEnabled]) {
        [DMPasscode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
            if (success) {
                delegate.passcodeEntered = YES;
            } else {
                if (error) {
                    [self showErrorAlertWithMessage:@"Passcode did not match"];
                }
            }
        }];
    }
}


- (void)reloadDocuments {
    if (!self.currentDocument) {
        self.documents = nil;
        self.documents = [Document allObjects];
        self.navigationItem.title = [NSString stringWithFormat:@"My Docs(%lu)", (unsigned long)[self.documents count]];
    } else {
        self.navigationItem.title = self.currentDocument.documentName;
    }
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (IBAction)preview:(id)sender {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.currentDocument.documents count]];
    for (File *file in self.currentDocument.documents) {
        [array addObject:[UIImage imageNamed:file.modifiedPath]];
    }
    
    NSString *path = [self createPDFWithImagesArray:array];
    PDFPreviewViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PDFPreviewViewController"];
    vc.path = path;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showGrid {
    self.tableView.hidden = YES;
    self.collectionView.hidden = NO;
    self.navigationItem.leftBarButtonItem = self.itemList;
    [self updateToolbarButtons];
}

- (void)showList {
    self.tableView.hidden = NO;
    self.collectionView.hidden = YES;
    self.navigationItem.leftBarButtonItem = self.itemGrid;
    [self updateToolbarButtons];
}

- (NSString *)createPDFWithImagesArray:(NSMutableArray *)array {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *PDFPath = [documentsDirectory stringByAppendingPathComponent:@"file.pdf"];
    NSLog(@"pdf path: %@", PDFPath);
    
    UIGraphicsBeginPDFContextToFile(PDFPath, CGRectZero, nil);
    for (UIImage *image in array)
    {
        // Mark the beginning of a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, image.size.width, image.size.height), nil);
        
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
    UIGraphicsEndPDFContext();
    
    return PDFPath;
}

- (IBAction)showCamera:(id)sender {
//    [self test];
//    return;
    
 //Narola Dev
    if(CSAppDelegate.isPurchased == FALSE) {
        if (![self checkLimitIsOverArrayCount:[Document allObjects].count message:ALERT_LIMIT_OVER]) {
            return;
        }
    }
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    NSMutableDictionary *event =
//    [[GAIDictionaryBuilder createEventWithCategory:@"Action"
//                                            action:@"Camera Opened"
//                                             label:nil
//                                             value:nil] build];
//    [tracker send:event];
    
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

- (IBAction)shareWithDropbox {
    UploadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UploadViewController"];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.currentDocument.documents count]];
    for (File *file in self.currentDocument.documents) {
        [array addObject:[UIImage imageNamed:file.modifiedPath]];
    }
    NSString *path = [self createPDFWithImagesArray:array];
    
    vc.filePath = path;
    [self showViewController:vc sender:nil];
    
//    if (![[DBSession sharedSession] isLinked]) {
////        [[JLToast makeText:@"Please login to your dropbox account. When its done, please tap on the share icon again."] show];
//         [[[Toast alloc] initWithText:@"Please login to your dropbox account. When its done, please tap on the share icon again." delay:0 duration:Delay.Short] show];
//        [[DBSession sharedSession] linkFromController:self];
//    } else {
////        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
////        NSMutableDictionary *event =
////        [[GAIDictionaryBuilder createEventWithCategory:@"Action"
////                                                action:@"Share on Dropbox"
////                                                 label:nil
////                                                 value:nil] build];
////        [tracker send:event];
//
//        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.currentDocument.documents count]];
//        for (File *file in self.currentDocument.documents) {
//            [array addObject:[UIImage imageNamed:file.modifiedPath]];
//        }
//
//        NSString *path = [self createPDFWithImagesArray:array];
//
//        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//        self.restClient.delegate = self;
//
//        // Upload file to Dropbox
//        NSString *destDir = @"/";
//        [SVProgressHUD showWithStatus:@"Uploading pdf to dropbox"];
//        [self.restClient uploadFile:[NSString stringWithFormat:@"%@.pdf", self.currentDocument.documentName]
//                             toPath:destDir
//                      withParentRev:nil
//                           fromPath:path];
//    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    
    [SVProgressHUD showWithStatus:@"Generating dropbox link"];
    NSString *path =[NSString stringWithFormat:@"/%@.pdf", self.currentDocument.documentName];
    [[self restClient] loadSharableLinkForFile:path];
}

- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link forFile:(NSString*)path {
    [SVProgressHUD dismiss];
    
    NSArray *items = @[link];
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error {
    [SVProgressHUD dismiss];
    [self showErrorAlertWithMessage:@"Filed to share pdf file with dropbox"];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    [self showErrorAlertWithMessage:@"Filed to upload pdf file with dropbox"];
}

- (IBAction)createPDF {
//    [self createPDF: self.currentDocument];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please select file type to share"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *jpegAction = [UIAlertAction actionWithTitle:@"JPEG"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                             [self shareAsJpeg];
                                                         }];
    UIAlertAction *pdfAction = [UIAlertAction actionWithTitle:@"PDF"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            [self shareAsPdf];
                                                        }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:jpegAction];
    [alert addAction:pdfAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil]; // 6
}

- (void)shareAsPdf {
    [SVProgressHUD showWithStatus:@"Creating PDF"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.currentDocument.documents count]];
    for (File *file in self.currentDocument.documents) {
        [array addObject:[UIImage imageNamed:file.modifiedPath]];
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        
        NSString *path = [self createPDFWithImagesArray:array];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSArray *items = @[data];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [SVProgressHUD dismiss];
            UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
            [self presentViewController:controller animated:YES completion:nil];
        });
        
    });
}

- (void)shareAsJpeg {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.currentDocument.documents count]];
    for (File *file in self.currentDocument.documents) {
        [array addObject:[UIImage imageWithContentsOfFile:file.modifiedPath]];
    }
    
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:array applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)createPDF:(Document*)doc {
    //    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    //    NSMutableDictionary *event =
    //    [[GAIDictionaryBuilder createEventWithCategory:@"Action"
    //                                            action:@"Create PDF"
    //                                             label:nil
    //                                             value:nil] build];
    //    [tracker send:event];
    
    [SVProgressHUD showWithStatus:@"Creating PDF"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[doc.documents count]];
    for (File *file in doc.documents) {
        [array addObject:[UIImage imageNamed:file.modifiedPath]];
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        
        NSString *path = [self createPDFWithImagesArray:array];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSArray *items = @[];
        
        items = [items arrayByAddingObjectsFromArray:array];
        items = [items arrayByAddingObjectsFromArray:array];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [SVProgressHUD dismiss];
            UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
            
            [controller setExcludedActivityTypes: @[UIActivityTypeAirDrop, UIActivityTypeSaveToCameraRoll]];
            
            [self presentViewController:controller animated:YES completion:nil];
        });
        
    });
}

- (void)showSettings {
//    SettingsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
//    [self.navigationController pushViewController:vc animated:YES];
//    [self.slideMenuController openRight];
    [[self revealViewController] rightRevealToggleAnimated:YES];
}

- (void)removeImage {
    self.navigationController.navigationBarHidden = NO;
//    self.searchBar.hidden = NO;
    if (self.currentDocument) {
        self.buttonCamera.hidden = YES;
        self.buttonGallery.hidden = YES;
        self.buttonUpgrade.hidden = YES;
        self.stackButtons.hidden = NO;
    } else {
        self.buttonCamera.hidden = NO;
        self.buttonGallery.hidden = NO;
        self.buttonUpgrade.hidden = NO;
        self.stackButtons.hidden = YES;
    }
    [self.imageView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"Home Screen"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
//    if (self.showSplash) {
//        [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(removeImage) userInfo:nil repeats:NO];
//        
//        self.showSplash = NO;
//        self.navigationController.navigationBarHidden = YES;
//        self.searchBar.hidden = YES;
//        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash.jpg"]];
//        self.imageView.frame = [[UIScreen mainScreen] bounds];
//        [self.view addSubview:self.imageView];
//    } else {
        self.navigationController.navigationBarHidden = NO;
//        self.searchBar.hidden = NO;
    
        if (self.currentDocument) {
            self.buttonCamera.hidden = YES;
            self.buttonGallery.hidden = YES;
            self.buttonUpgrade.hidden = YES;
            self.stackButtons.hidden = NO;
        } else {
            self.buttonCamera.hidden = NO;
            self.buttonGallery.hidden = NO;
            self.buttonUpgrade.hidden = NO;
            self.stackButtons.hidden = YES;
            
            self.selectionMode = NO;
            self.selectionBackgroundView.hidden = true;
            
            self.mainToolbar.hidden = false;
            self.toolbarHeight.constant = 50;
            self.selectionBackgroundView.hidden = true;
            self.searchBar.hidden = true;
            self.subToolbar.hidden = true;
        }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    }
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (IBAction)showUpgrade:(id)sender {
    
}

- (IBAction)showGallery:(id)sender {
//Narola Dev
    if(CSAppDelegate.isPurchased == FALSE) {
        if (![self checkLimitIsOverArrayCount:[Document allObjects].count message:ALERT_LIMIT_OVER]) {
            return;
        }
    }

//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    NSMutableDictionary *event =
//    [[GAIDictionaryBuilder createEventWithCategory:@"Action"
//                                            action:@"Gallery Opened"
//                                             label:nil
//                                             value:nil] build];
//    [tracker send:event];
    [self presentViewController:self.cre_picker animated:YES completion:nil];
//    [self presentViewController:self.picker animated:YES completion:nil];
    
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
    if(CSAppDelegate.isPurchased == FALSE) {
        self.interstitial = [self createAndLoadInterstitial];
    }
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

        if (isSelecteFromGallery) {
            CropViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CropViewController"];
            vc.delegate = self;
            vc.isDisplayAds = YES;
            vc.adjustedImage = imgSelect;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
            isSelecteFromGallery = NO;
        }
    }
    isSelecteFromGallery = NO;
    NSLog(@"%@", NSStringFromSelector(_cmd)); // Objective-C
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad{
    NSLog(@"%@", NSStringFromSelector(_cmd)); // Objective-C
}


#pragma mark - GADBannerView Delegate

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
}

- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}

#pragma mark Picker delegate

- (void)getSelectedPhoto:(NSMutableArray *)aryPhoto {
    if (aryPhoto.count == 1) {

        imgSelect = ([aryPhoto[0] valueForKey:@"mainImage"]);
        isSelecteFromGallery = YES;
        CropViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CropViewController"];
        vc.delegate = self;
        vc.adjustedImage = ([aryPhoto[0] valueForKey:@"mainImage"]);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:^{
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if(CSAppDelegate.isPurchased == FALSE) {
                        //                vc.isDisplayAds = YES;
                        if (CSAppDelegate.needApplovinAd) {
                            [CSAppDelegate showApplovinAd];
                        }else{
                            if (self.interstitial.isReady) {
                                [self.interstitial presentFromRootViewController:vc];
                            }
                            //                        CSAppDelegate.needApplovinAd = YES;
                        }
                    }
                });
                
            }];
        });
        
    }else if(aryPhoto.count > 1) {
        if(CSAppDelegate.isPurchased == FALSE) {
            [self dismissViewControllerAnimated:NO completion:^{
                [CSAppDelegate presentViewWith:self];
            }];
            
        }else{
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                NSMutableArray *files = [[NSMutableArray alloc] init];
                for(NSDictionary *dict in aryPhoto){
                    UIImage *image = [dict valueForKey:@"mainImage"];
                    File *file = [[File alloc] init];
                    file.originalFile = [self saveImage:image];
                    file.modifiedFile = [self saveImage:image];
                    file.thumbnailFile = [self saveImage:[image imageWithThumbnailWidth:100]];
                    file.createdDateTime = [NSDate date];
                    [files addObject:file];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self imageEditor:nil didFinishEdittingWithImages:files];
                });
            });
        }
    }
}

- (NSString *)saveImage:(UIImage *)image {
    NSData *originalData = UIImagePNGRepresentation(image);
    NSString *originalName = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
    NSString *originalPath = [NSString pathWithComponents:@[NSHomeDirectory(), @"Documents", originalName]];
    [originalData writeToFile:originalPath atomically:YES];
    return originalName;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //Narola Dev
    if(CSAppDelegate.isPurchased == FALSE) {
        imgSelect = [info objectForKey:UIImagePickerControllerOriginalImage];
        isSelecteFromGallery = YES;

        
//        else {
//            CropViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CropViewController"];
//            vc.delegate = self;
//            vc.isDisplayAds = YES;
//            vc.adjustedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
//        }
    }
//    else{
        CropViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CropViewController"];
        vc.delegate = self;
        vc.isDisplayAds = YES;
        vc.adjustedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:^{
        if (CSAppDelegate.needApplovinAd) {
            [CSAppDelegate showApplovinAd];
        }else{
            if (self.interstitial.isReady) {
                [self.interstitial presentFromRootViewController:vc];
            }
//            CSAppDelegate.needApplovinAd = YES;
        }
    }];
//    }
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"camera"]) {
        ViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark crop delegate

- (void)cancelButtonClicked:(UIViewController *)secondDetailViewController {
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
    [self reloadDocuments];
    
    self.renameDocVC = nil;
}

- (void)cancelWithSelectingDocument:(Document *)doc withVC:(UIViewController *)vc2 {
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
    [self reloadDocuments];
    
    self.renameDocVC = nil;
    
    //Narola Dev
    if(CSAppDelegate.isPurchased == FALSE) {
        if (CSAppDelegate.needApplovinAd) {
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


    HomeViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
    vc.currentDocument = doc;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)imageEditor:(CLImageEditor*)editor didFinishEdittingWithImage:(File*)document {
    if (self.currentDocument) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [self.currentDocument.documents addObject:document];
        [realm commitWriteTransaction];
        
        [self.tableView reloadData];
    } else {
        self.renameDocVC = [[RenameDocumentViewController alloc] initWithNibName:@"RenameDocumentViewController" bundle:nil];
        self.renameDocVC.file = document;
        self.renameDocVC.delegate = self;
        [self presentPopupViewController:self.renameDocVC animationType:MJPopupViewAnimationSlideBottomTop];
    }
}

- (void)imageEditor:(CLImageEditor*)editor didFinishEdittingWithImages:(NSArray *)documents {
    if (self.currentDocument) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        for (File *file in documents) {
            [self.currentDocument.documents addObject:file];
        }
        [realm commitWriteTransaction];
        
        [self.tableView reloadData];
    } else {
        self.renameDocVC = [[RenameDocumentViewController alloc] initWithNibName:@"RenameDocumentViewController" bundle:nil];
        self.renameDocVC.array = documents;
        self.renameDocVC.delegate = self;
        [self presentPopupViewController:self.renameDocVC animationType:MJPopupViewAnimationSlideBottomTop];
    }
}

- (void)imageEditorDidCancel:(CLImageEditor*)editor {
    
}

#pragma mark - collectionview

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [self updateToolbarButtons];
    return [self.documents count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DocumentCollectionViewCell *cell = (DocumentCollectionViewCell *) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    Document *doc = [self.documents objectAtIndex:indexPath.row];
    cell.labelName.text = doc.documentName;
    
    File *document = [doc.documents objectAtIndex:0];
    UIImage *image = [UIImage imageWithContentsOfFile:document.modifiedPath];
    cell.imageView.image = image;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    cell.labelDate.text = [formatter stringFromDate:doc.createdDateTime];
    image = nil;
    
    if (self.selectionMode == YES) {
        if (self.selectedIndex == indexPath.item) {
            cell.selectionView.hidden = true;
        } else {
            cell.selectionView.hidden = false;
        }
    } else {
        cell.selectionView.hidden = true;
    }
    
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectionMode) {
        self.selectedIndex = indexPath.item;
        DocumentCollectionViewCell *cell = (DocumentCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.selectionView.hidden = true;
        
        [self updateToolbarButtons];
    } else {
        HomeViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
        vc.currentDocument = [self.documents objectAtIndex:indexPath.item];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectionMode) {
        DocumentCollectionViewCell *cell = (DocumentCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.selectionView.hidden = false;
        [self updateToolbarButtons];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.frame.size.width / 2) - 15, 180);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - tableView

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self updateToolbarButtons];
    return _currentDocument ? [_currentDocument.documents count] + 1 : [_documents count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.currentDocument) {
        HomeViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
        vc.currentDocument = [self.documents objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if (indexPath.row == [_currentDocument.documents count]) {
            [self showCamera: nil];
        } else {
            CropViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CropViewController"];
            vc.document = [self.currentDocument.documents objectAtIndex:indexPath.row];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
        }
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (indexPath.row == [_currentDocument.documents count]) {
        
    } else {
        UITableViewRowAction *actionDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            if (self.currentDocument) {
                if ([self.currentDocument.documents count] == 1) {
                    [realm deleteObject:self.currentDocument];
                } else {
                    [self.currentDocument.documents removeObjectAtIndex:indexPath.row];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } else {
                Document *document = [self.documents objectAtIndex:indexPath.row];
                [realm deleteObject:document];
            }
            [realm commitWriteTransaction];
            
            self.documents = [Document allObjects];
            [self.tableView reloadData];
        }];
        
        UITableViewRowAction *actionOCR = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"OCR" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            OCRResultViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OCRResultViewController"];
            vc.document = [self.currentDocument.documents objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
            
        }];
        
        if (self.currentDocument) {
            //[array addObject:actionOCR];
        }
        [array addObject:actionDelete];
    }
    
    return array;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return !self.currentDocument ? 70 : 250;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.currentDocument) {
        DocumentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        Document *doc = [self.documents objectAtIndex:indexPath.row];
        cell.labelTitle.text = doc.documentName;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        cell.moreAction = ^{
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                // Cancel button tappped do nothing.
                
            }]];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // Share button tapped.
                [self createPDF: doc];
            }]];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // Rename button tapped.
                
            }]];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                // Delete button tapped.
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [realm deleteObject:doc];
                [realm commitWriteTransaction];
                self.documents = [Document allObjects];
                [self.tableView reloadData];
            }]];
            
            [self presentViewController:actionSheet animated:YES completion:nil];
        };
        
        if (doc.isFolder) {
            cell.imageViewThumbnail.image = [UIImage imageNamed:@"folder.png"];
        } else {
            File *document = [doc.documents objectAtIndex:0];
            UIImage *image = [UIImage imageWithContentsOfFile:document.thumbnailPath];
            cell.imageViewThumbnail.image = image;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        cell.labelDate.text = [formatter stringFromDate:doc.createdDateTime];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        if (indexPath.row == [_currentDocument.documents count]) {
            DocumentAddPageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"addPageCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        } else {
            ImageTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"imagecell"];
            File *document = [self.currentDocument.documents objectAtIndex:indexPath.row];
            UIImage *image = [UIImage imageWithContentsOfFile:document.modifiedPath];
            cell.imageViewDoc.image = image;
            
            cell.detectText = ^{
    //Narola Dev
                if(CSAppDelegate.isPurchased == FALSE) {
                    if (![self checkLimitIsOverArrayCount:MAX_NUM_FILE message:ALERT_PRO_VERSION]) {
                        return ;
                    }
                }else{
                    OCRResultViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OCRResultViewController"];
                    File *file = [self.currentDocument.documents objectAtIndex:indexPath.row];
                    vc.image = [UIImage imageWithContentsOfFile:file.modifiedPath];
                    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
                }

            };
            
            cell.edit = ^{
                CropViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CropViewController"];
                vc.document = [self.currentDocument.documents objectAtIndex:indexPath.row];
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
            };
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
    }

    return nil;
}

#pragma mark - keyboard
-(void)keyboardWillShow:(NSNotification*) notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    if (self.renameDocVC != nil) {
        
        CGRect vcFrame = self.renameDocVC.view.frame;
        
        CGFloat distanceToBottom = self.view.frame.size.height / 2 - vcFrame.size.height / 2;

        CGFloat collapseSpace = keyboardRect.size.height - distanceToBottom;        
        if (collapseSpace > 0) {
            [UIView animateWithDuration:0.3 animations:^{
                [self.renameDocVC.view setFrame:CGRectMake(vcFrame.origin.x,self.view.frame.size.height / 2 - vcFrame.size.height / 2 - collapseSpace , vcFrame.size.width, vcFrame.size.height)];
            }];
        }
    }
}

-(void)keyboardWillHide:(NSNotification*) notification {
    if (self.renameDocVC != nil) {
        
        CGRect vcFrame = self.renameDocVC.view.frame;
        [UIView animateWithDuration:0.3 animations:^{
            [self.renameDocVC.view setFrame:CGRectMake(vcFrame.origin.x, self.view.frame.size.height / 2 - vcFrame.size.height / 2, vcFrame.size.width, vcFrame.size.height)];
        }];
    }
}

-(void)test {
    
    UIImage *image = [UIImage imageNamed:@"onedrive"];
//    CLImageEditor *editor = [[CLImageEditor alloc] initWithOriginalImage:image proccessedImage:image delegate:nil withDocument:nil];
//
//    CLImageToolInfo *tool = [editor.toolInfo subToolInfoWithToolName:@"CLBlurTool" recursive:YES];
//    tool.available = NO;
//
//    tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:YES];
//    tool.available = NO;
//
//    tool = [editor.toolInfo subToolInfoWithToolName:@"CLEffetctTool" recursive:YES];
//    tool.available = NO;
//
//    [self.navigationController pushViewController:editor animated:YES];
    CropViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CropViewController"];
    vc.delegate = self;
    vc.isDisplayAds = YES;
    vc.adjustedImage = image;
    //        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:^{
        
    }];
}
@end
