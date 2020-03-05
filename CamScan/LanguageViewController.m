//
//  LanguageViewController.m
//  CamScan
//
//  Created by Liao Fang on 5/8/19.
//  Copyright © 2019 Amit Kulkarni. All rights reserved.
//

#import "LanguageViewController.h"

@interface LanguageViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Supported Languages";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone  target:self action:@selector(done)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone  target:self action:@selector(cancel)];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView reloadData];
}

- (void)done {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.didDismiss)
        self.didDismiss(self.selectedLanguage, self.selectedLangCode);
}
    
- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.supportedLanguages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSMutableDictionary *lang = self.supportedLanguages[indexPath.row];
    cell.textLabel.text = lang[@"name"];
    
    if ([lang[@"name"] isEqualToString:self.selectedLanguage]) {
        [cell setSelected:YES];
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSMutableDictionary *lang = self.supportedLanguages[indexPath.row];
    self.selectedLanguage = lang[@"name"];
    self.selectedLangCode = lang[@"language"];
    
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

@end
