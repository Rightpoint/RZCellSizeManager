//
//  RZCellSizeManager+CoreData.h
//  RZCellSizeManager
//
//  Created by Alex Rouse on 1/15/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//
@import CoreData;

#import "RZCellSizeManager.h"

@interface RZCellSizeManager (CoreData)

- (void)invalidateCellHeightsForResultsController:(NSFetchedResultsController *)controller changeType:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath;

@end
