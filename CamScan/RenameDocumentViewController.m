//
//  RenameDocumentViewController.m
//  CamScan
//
//  Created by Amit Kulkarni on 23/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "RenameDocumentViewController.h"
#import "Document.h"
#import "Toaster.h"

#ifdef PRO_VERSION
#import "CamScan_Pro-Swift.h"
#else
#import "CamScan-Swift.h"
#endif

@implementation RenameDocumentViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor clearColor];
    self.container.clipsToBounds = YES;
    self.editName.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)saveDocument:(id)sender {
    if ([self.editName.text length] == 0) {
//        [[Toast makeText:@"Please enter document name"] show];
         [[[Toast alloc] initWithText:@"Please enter document name" delay:0 duration:Delay.Short] show];
        
    } else {
        Document *doc = [[Document alloc] init];
        doc.documentName = self.editName.text;
        doc.isFolder = NO;
        doc.createdDateTime = [NSDate date];
        if (self.file) {
            [doc.documents addObject:self.file];
        } else {
            for (File *file in self.array) {
                [doc.documents addObject:file];
            }
        }
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObject:doc];
        }];
        
        [self.delegate cancelWithSelectingDocument:doc withVC:self];
    }
}

- (IBAction)cancel:(id)sender {
    [self.delegate cancelButtonClicked:self];
}
@end
