//
//  RZCellSizeManager+CoreData.m
//  RZCellSizeManager
//
//  Created by Alex Rouse on 1/15/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZCellSizeManager+CoreData.h"

@implementation RZCellSizeManager (CoreData)

- (NSArray *)indexPathsInSectionAboveIndexPath:(NSIndexPath *)indexPath forController:(NSFetchedResultsController *)controller
{
    NSMutableArray* indexPaths = [NSMutableArray array];
    NSInteger numberOfObjectes = [[controller.sections objectAtIndex:indexPath.section] numberOfObjects];
    for (int i = indexPath.row; i <numberOfObjectes; i++)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
    }
    return indexPaths;
}

// TODO:
// There is potentially a good bit of optimization that could be done here where we move around index paths based on moves.  For now we are just invalidating everything that could be affected.
- (void)invalidateCellHeightsForResultsController:(NSFetchedResultsController *)controller changeType:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [self invalidateCellHeightsAtIndexPaths:[self indexPathsInSectionAboveIndexPath:indexPath forController:controller]];
            break;
        case NSFetchedResultsChangeInsert:
            [self invalidateCellHeightsAtIndexPaths:[self indexPathsInSectionAboveIndexPath:newIndexPath forController:controller]];
            break;
        case NSFetchedResultsChangeMove:
        {
            if (indexPath.section == newIndexPath.section)
            {
                [self invalidateCellHeightsAtIndexPaths:[self indexPathsInSectionAboveIndexPath:((indexPath.row > newIndexPath.row) ? newIndexPath : indexPath) forController:controller]];
            }
            else
            {
                // We are moving sections.  For now just invalidate everything
                [self invalidateCellHeightCache];
            }
        }
            break;
        case NSFetchedResultsChangeUpdate:
            [self invalidateCellHeightAtIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}

@end
