//
//  RZCoreDataManager.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZCoreDataManager.h"
#import "RZEntry.h"
#import "NSString+RandomString.h"

@interface RZCoreDataManager ()

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property (nonatomic, strong) NSString* dbPath;
@end

@implementation RZCoreDataManager

+ (instancetype)sharedInstance
{
    static RZCoreDataManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[RZCoreDataManager alloc] init];
    });
    return s_manager;
}


#pragma mark - Core Data Code
- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel)
    {
        NSString* path = [[self bundlePath] stringByAppendingPathComponent:@"RZModel.momd"];
        NSURL *modelURL = [NSURL fileURLWithPath:path];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator)
    {
        // if there's no default path set for the datbase, use the documents directory
        if (nil == self.dbPath)
        {
            self.dbPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"RZModel.sqlite"];
        }
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:[NSURL fileURLWithPath:self.dbPath] options:nil error:&error])
        {
            // there was an error; delete the existing database and try again.
            NSLog(@"Database error (so we're deleting the DB) %@, %@", error, [error userInfo]);
            
            error = nil;
            NSFileManager* manager = [NSFileManager defaultManager];
            [manager removeItemAtPath:self.dbPath error:&error];
            
            // try. again.
            if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:self.dbPath] options:nil error:&error])
            {
                NSLog(@"Unresolveable DB error (we tried. Really, we did.) %@, %@", error, [error userInfo]);
                abort();
            }
            
        }
    }
    return _persistentStoreCoordinator;
}

- (NSString*)applicationDocumentsDirectory
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
- (NSString*)bundlePath
{
    return [[NSBundle bundleForClass:[RZCoreDataManager class]] bundlePath];
}

#pragma mark - Public Methods

- (NSFetchedResultsController *)entryResultsController
{
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modifiedDate" ascending:YES]];
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [controller performFetch:nil];
    return controller;
}

- (void)populateWithRandomData
{
    static CGFloat titleMaxLength = 50.0f;
    static CGFloat subtitleMaxLength = 150.0f;
    
    for (int i = 0; i<=3; i++)
    {
        RZEntry* entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:self.managedObjectContext];
        entry.title = [NSString randomStringOfMaxLength:titleMaxLength];
        entry.subTitle = [NSString randomStringOfMaxLength:subtitleMaxLength];
        entry.modifiedDate = [NSDate date];
    }
}

- (void)randomMovement
{
    static CGFloat titleMaxLength = 50.0f;
    static CGFloat subtitleMaxLength = 150.0f;
    
    int action = (int)arc4random_uniform(3);
    switch (action) {
        case 0: // Insert
        {
            RZEntry* entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:self.managedObjectContext];
            entry.title = [NSString randomStringOfMaxLength:titleMaxLength];
            entry.subTitle = [NSString randomStringOfMaxLength:subtitleMaxLength];
            entry.modifiedDate = [NSDate date];
            [self.managedObjectContext save:nil];
        }
            break;
        case 1: // Delete
        {
            NSArray* objs = self.entryResultsController.fetchedObjects;
            if (objs.count > 0)
            {
                int index = arc4random_uniform((int)objs.count);
                RZEntry* entry = [self.entryResultsController.fetchedObjects objectAtIndex:index];
                [self.managedObjectContext deleteObject:entry];
                [self.managedObjectContext save:nil];
            }
        }
            break;
        case 2: // Update
        {
            NSArray* objs = self.entryResultsController.fetchedObjects;
            if (objs.count > 0)
            {
                int index = arc4random_uniform((int)objs.count);
                RZEntry* entry = [self.entryResultsController.fetchedObjects objectAtIndex:index];
                entry.title = [NSString randomStringOfMaxLength:titleMaxLength];
                entry.subTitle = [NSString randomStringOfMaxLength:subtitleMaxLength];
                [self.managedObjectContext save:nil];
            }
        }
            break;
        default:
            break;
    }
}

@end
