//
//  SelectDefaultProcessViewController.m
//  PDFScanner
//
//  Created by Amit Kulkarni on 15/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "SelectDefaultProcessViewController.h"
#import "Preferences.h"

@interface SelectDefaultProcessViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (nonatomic) NSArray *options;
@end

@implementation SelectDefaultProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.container.layer.cornerRadius = 10;
    self.container.clipsToBounds = YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.container.backgroundColor = [UIColor whiteColor];
    
    self.options = @[@"Normal", @"B & W", @"Gray"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    if ([[self.options objectAtIndex:indexPath.row] isEqualToString:[[Preferences sharedInstance] defaultProcess]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[Preferences sharedInstance] setDefaultProcess:[self.options objectAtIndex:indexPath.row]];
    
    if (self.completionBlock) {
        self.completionBlock(indexPath.row);
    }
    [self.delegate cancelButtonClicked:self];
}

@end
