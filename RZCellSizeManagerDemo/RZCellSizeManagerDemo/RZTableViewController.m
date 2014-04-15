//
//  RZTableViewController.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 12/20/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZTableViewController.h"
#import "RZCellData.h"
#import "RZCellSizeManager.h"

#import "RZTableViewCell.h"

#import "NSString+RandomString.h"

#define kRZMaxCells             100
#define kRZMaxTitleLength       50
#define kRZMaxDescriptionLength 200

@interface RZTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* dataArray;
@property (strong, nonatomic) RZCellSizeManager* sizeManager;

@end

@implementation RZTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureDataSource];
    
    [self configureTableView];
}

- (void)configureDataSource
{
    // Create an array of random objects to be the datasource so its different every time.
    NSMutableArray* arry = [NSMutableArray array];
    for (int i = 0; i<kRZMaxCells; i++)
    {
        [arry addObject:[RZCellData cellDataWithTitle:[NSString randomStringOfMaxLength:kRZMaxTitleLength] subTitle:[NSString randomStringOfMaxLength:kRZMaxDescriptionLength]]];
    }
    self.dataArray = [NSArray arrayWithArray:arry];
    
    
    // Initialize the size manager.  In this case we are using a configuration block to compute the height.
    // We could also use a height block to do it where we could set the data and return the height, this is good if
    //  the cell is similar and you don't need to layout everything.
    // NOTE: if you are doing things that don't pertain to layout in the setCellData: method it may be best to create a different
    //  method for computing the height or add an optional parameter setCellData:forHeight: to not do additional work,  This
    //  expecially applies if you are loading images or anything of that manor.
    self.sizeManager = [[RZCellSizeManager alloc] init];
    [self.sizeManager registerCellClassName:@"RZTableViewCell" forObjectClass:nil configurationBlock:^(RZTableViewCell* cell, id object) {
        [cell setCellData:object];
    }];
}

- (void)configureTableView
{
    [self.tableView registerNib:[RZTableViewCell reuseNib] forCellReuseIdentifier:[RZTableViewCell reuseIdentifier]];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStyleDone target:self action:@selector(reloadPressed)]];

}

- (void)reloadPressed
{
    [self configureDataSource];
    
    // In this case we are going to invalidate our entire height cache since we are changing the entire datasource.  It is possible
    //  to just invalidate a speific indexpath or an array of them, and you should so long as you know what is being invalidated.
    [self.sizeManager invalidateCellSizeCache];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[RZCellData class]])
    {
        RZTableViewCell* tableCell = [tableView dequeueReusableCellWithIdentifier:[RZTableViewCell reuseIdentifier]];
        [tableCell setCellData:object];
        cell = tableCell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve our object to give to our size manager.
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    // Since we are using a tableView we are using the cellHeightForObject:indexPath: method.
    //  It uses the indexPath as the key for cacheing so it is important to pass in the correct one.
    return [self.sizeManager cellHeightForObject:object indexPath:indexPath];
}

// If you have very complex cells or a large number implementing this method speeds up initial load time.
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RZTableViewCell estimatedCellHeight];
}
@end

