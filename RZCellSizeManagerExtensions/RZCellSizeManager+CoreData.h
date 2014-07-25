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

/**
 *  Automatically invalidates cell heights based on a fetched results controller
 *
 *  @param controller   Results controller that is being observed
 *  @param type         Type of change
 *  @param indexPath    The indexPath from the change
 *  @param newIndexPath The new indexPath from the change
 */
- (void)invalidateCellHeightsForResultsController:(NSFetchedResultsController *)controller
                                       changeType:(NSFetchedResultsChangeType)type
                                        indexPath:(NSIndexPath *)indexPath
                                     newIndexPath:(NSIndexPath *)newIndexPath;

@end
