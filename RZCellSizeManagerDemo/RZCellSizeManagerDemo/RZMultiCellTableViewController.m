//
//  RZMultiCellTableViewController.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 12/20/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZMultiCellTableViewController.h"
#import "RZCellData.h"
#import "RZCellSizeManager.h"

#import "RZTableViewCell.h"
#import "RZSecondTableViewCell.h"

#import "NSString+RandomString.h"

#define kRZMaxCells             100
#define kRZMaxTitleLength       50
#define kRZMaxDescriptionLength 200

@interface RZMultiCellTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* dataArray;
@property (strong, nonatomic) RZCellSizeManager* sizeManager;

@end

@implementation RZMultiCellTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureDataSource];
    
    [self configureSizeManager];
    
    [self configureTableView];
}

- (void)configureDataSource
{
    // Create an array of random objects to be the datasource so its different every time.
    NSMutableArray* arry = [NSMutableArray array];
    for (int i = 0; i<kRZMaxCells; i++)
    {
        int rando = arc4random_uniform(2);
        // We are going to add two different objects to the datasource.  One fore the regular cell and one for our secondCell
        switch (rando) {
            case 0:
                [arry addObject:[RZCellData cellDataWithTitle:[NSString randomStringOfMaxLength:kRZMaxTitleLength] subTitle:[NSString randomStringOfMaxLength:kRZMaxDescriptionLength]]];
                break;
            case 1:
                [arry addObject:[RZOtherCellData otherCellDataWithTitle:[NSString randomStringOfMaxLength:kRZMaxTitleLength]]];
                break;
            default:
                break;
        }
        
    }
    self.dataArray = [NSArray arrayWithArray:arry];
}

- (void)configureSizeManager
{
    // Initialize the size manager.  In this case we are using a configuration block to compute the height.
    // We could also use a height block to do it where we could set the data and return the height, this is good if
    //  the cell is simpilar and you don't need to layout everything.
    // NOTE: if you are doing things that don't pertain to layout in the setCellData: method it may be best to create a different
    //  method for computing the height or add an optional parameter setCellData:forHeight: to not do additional work,  This
    //  expecially applies if you are loading images or anything of that manor.
    
    self.sizeManager = [[RZCellSizeManager alloc] init];

    [self.sizeManager registerCellClassName:@"RZTableViewCell"
                               withNibNamed:nil
                             forObjectClass:[RZCellData class]
                         withConfigurationBlock:^(id cell, id object) {
                             [cell setCellData:object];
                         }];
    
    [self.sizeManager registerCellClassName:@"RZSecondTableViewCell"
                               withNibNamed:nil
                             forObjectClass:[RZOtherCellData class]
                         withConfigurationBlock:^(RZSecondTableViewCell* cell, RZOtherCellData* object) {
                             [cell setOtherCellData:object];
                         }];

    // These are for using a reuse Identifier approach instead of the Object class approach.
//    self.sizeManager = [[RZCellSizeManager alloc] initWithCellClassName:@"RZTableViewCell" cellReuseIdentifier:[RZTableViewCell reuseIdentifier] configurationBlock:^(id cell, id object) {
//        [cell setCellData:object];
//    }];
//
//    [self.sizeManager registerCellClassName:@"RZSecondTableViewCell" forReuseIdentifier:[RZSecondTableViewCell reuseIdentifier] withConfigurationBlock:^(id cell, id object) {
//        [cell setOtherCellData:object];
//    }];

    
}

- (void)configureTableView
{
    [self.tableView registerNib:[RZTableViewCell reuseNib] forCellReuseIdentifier:[RZTableViewCell reuseIdentifier]];
    [self.tableView registerNib:[RZSecondTableViewCell reuseNib] forCellReuseIdentifier:[RZSecondTableViewCell reuseIdentifier]];
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
    else if ([object isKindOfClass:[RZOtherCellData class]])
    {
        RZSecondTableViewCell* secondTableCell = [tableView dequeueReusableCellWithIdentifier:[RZSecondTableViewCell reuseIdentifier]];
        [secondTableCell setOtherCellData:object];
        cell = secondTableCell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve our object to give to our size manager.
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    // Since we have multiple different types of cells for the same tableview we either need to register our object classes,
    //  Or we have to give it a reuseIdentifier.
    return [self.sizeManager cellSizeForObject:object indexPath:indexPath].height;
//    return [self.sizeManager cellHeightForObject:object indexPath:indexPath cellReuseIdentifier:(([object isKindOfClass:[RZCellData class]]) ? [RZTableViewCell reuseIdentifier] : [RZSecondTableViewCell reuseIdentifier])];
    
    
}

// If you have very complex cells or a large number implementing this method speeds up initial load time.
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RZTableViewCell estimatedCellHeight];
}
@end

