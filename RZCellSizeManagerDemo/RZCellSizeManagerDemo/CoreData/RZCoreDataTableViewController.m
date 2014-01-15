//
//  RZCoreDataTableViewController.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZCoreDataTableViewController.h"
#import "RZCellData.h"
#import "RZCellSizeManager.h"
#import "RZCellSizeManager+CoreData.h"
#import "RZCoreDataManager.h"
#import "RZEntry.h"

#import "RZTableViewCell.h"

#import "NSString+RandomString.h"

#define kRZMaxCells             100
#define kRZMaxTitleLength       50
#define kRZMaxDescriptionLength 200

@interface RZCoreDataTableViewController () <NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* dataArray;
@property (strong, nonatomic) NSFetchedResultsController* fetchedResultController;
@property (strong, nonatomic) RZCellSizeManager* sizeManager;
@property (strong, nonatomic) NSTimer* timer;

@end

@implementation RZCoreDataTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self configureDataSourceForCoreData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startRandomActionTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)configureDataSourceForCoreData
{
    [[RZCoreDataManager sharedInstance] populateWithRandomData];
    self.fetchedResultController = [[RZCoreDataManager sharedInstance] entryResultsController];
    self.fetchedResultController.delegate = self;
    
    // Initialize the size manager.  In this case we are using a configuration block to compute the height.
    // We could also use a height block to do it where we could set the data and return the height, this is good if
    //  the cell is simpilar and you don't need to layout everything.
    // NOTE: if you are doing things that don't pertain to layout in the setCellData: method it may be best to create a different
    //  method for computing the height or add an optional parameter setCellData:forHeight: to not do additional work,  This
    //  expecially applies if you are loading images or anything of that manor.
    self.sizeManager = [[RZCellSizeManager alloc] initWithCellClassName:@"RZTableViewCell" configurationBlock:^(RZTableViewCell* cell, id object) {
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
    // In this case we are going to invalidate our entire height cache since we are changing the entire datasource.  It is possible
    //  to just invalidate a speific indexpath or an array of them, and you should so long as you know what is being invalidated.
    [self.sizeManager invalidateCellHeightCache];
    
    [self.tableView reloadData];
}

- (void)startRandomActionTimer
{
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer timerWithTimeInterval:1.0f target:[RZCoreDataManager sharedInstance] selector:@selector(randomMovement) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    id object = [self.fetchedResultController objectAtIndexPath:indexPath];
    if ([object isKindOfClass:[RZEntry class]])
    {
        RZTableViewCell* tableCell = [tableView dequeueReusableCellWithIdentifier:[RZTableViewCell reuseIdentifier] forIndexPath:indexPath];
        [tableCell setCellEntry:object];
        cell = tableCell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve our object to give to our size manager.
    id object = [self.fetchedResultController objectAtIndexPath:indexPath];
    
    // Since we are using a tableView we are using the cellHeightForObject:indexPath: method.
    //  It uses the indexPath as the key for cacheing so it is important to pass in the correct one.
    return [self.sizeManager cellHeightForObject:object indexPath:indexPath];
}

// If you have very complex cells or a large number implementing this method speeds up initial load time.
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RZTableViewCell estimatedCellHeight];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
    // This is a category method on RZCellSizeManager that automaticlly invalidates heights based on changes.  This is ment as a demo only.
    [self.sizeManager invalidateCellHeightsForResultsController:controller changeType:type indexPath:indexPath newIndexPath:newIndexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


@end
