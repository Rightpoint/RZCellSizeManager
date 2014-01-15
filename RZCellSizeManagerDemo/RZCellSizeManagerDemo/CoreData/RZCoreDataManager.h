//
//  RZCoreDataManager.h
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RZCoreDataManager : NSObject

+ (instancetype)sharedInstance;

- (NSFetchedResultsController *)entryResultsController;
- (void)populateWithRandomData;
- (void)randomMovement;

@end
