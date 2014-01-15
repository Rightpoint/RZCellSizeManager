//
//  RZRootViewController.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/15/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZRootViewController.h"

#import "RZTableViewController.h"
#import "RZCoreDataTableViewController.h"


@interface RZRootViewController ()
- (IBAction)simplePressed:(id)sender;
- (IBAction)coreDataPressed:(id)sender;

@end

@implementation RZRootViewController

- (IBAction)simplePressed:(id)sender {
    RZTableViewController* tableVC = [[RZTableViewController alloc] init];
    [self.navigationController pushViewController:tableVC animated:YES];
}

- (IBAction)coreDataPressed:(id)sender {
    RZCoreDataTableViewController* tableVC = [[RZCoreDataTableViewController alloc] init];
    [self.navigationController pushViewController:tableVC animated:YES];
}
@end
