//
//  RZCellSizeManager+RZCollectionList.m
//  Raizlabs
//
//  Created by Alex Rouse on 12/12/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZCellSizeManager+RZCollectionList.h"
#import <objc/runtime.h>

static char s_RZAutoLayoutHeightManagerToken;

@interface RZAutoLayoutHeightManagerObserver : NSObject <RZCollectionListObserver>

@property (nonatomic, weak) id<RZCollectionList> collectionList;
@property (nonatomic, weak) RZCellSizeManager *heightManager;
@property (nonatomic, assign) BOOL shouldFlushCache;
@property (nonatomic, strong) NSMutableSet* reloadableIndexPaths;
@end

@implementation RZAutoLayoutHeightManagerObserver

- (void)dealloc
{
    [self.collectionList removeCollectionListObserver:self];
}

#pragma mark - Collection List Observer

- (void)collectionListWillChangeContent:(id<RZCollectionList>)collectionList
{
    self.shouldFlushCache = NO;
    self.reloadableIndexPaths = [[NSMutableSet alloc] init];
}
- (void)collectionList:(id<RZCollectionList>)collectionList didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(RZCollectionListChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    // TODO: see if we can optimize what we reload a bit more for the Delete, Insert, Move notifications.
    switch (type) {
        case RZCollectionListChangeDelete:
            self.shouldFlushCache = YES;
            break;
        case RZCollectionListChangeInsert:
            self.shouldFlushCache = YES;
            break;
        case RZCollectionListChangeMove:
            self.shouldFlushCache = YES;
            break;
        case RZCollectionListChangeUpdate:
            if (!self.shouldFlushCache)
            {
                [self.reloadableIndexPaths addObject:indexPath];
            }
            break;
        default:
            break;
    }
}
- (void)collectionList:(id<RZCollectionList>)collectionList didChangeSection:(id<RZCollectionListSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(RZCollectionListChangeType)type
{
    self.shouldFlushCache = YES;
}
- (void)collectionListDidChangeContent:(id<RZCollectionList>)collectionList
{
    if (self.shouldFlushCache)
    {
        [self.heightManager invalidateCellSizeCache];
    }
    else
    {
        [self.heightManager invalidateCellSizesAtIndexPaths:[self.reloadableIndexPaths allObjects]];
    }
}

@end


@implementation RZCellSizeManager (RZCollectionList)

- (void)rz_autoInvalidateWithCollectionList:(id<RZCollectionList>)collectionList
{
    RZAutoLayoutHeightManagerObserver *obs = [RZAutoLayoutHeightManagerObserver new];
    obs.collectionList = collectionList;
    obs.heightManager = self;
    [collectionList addCollectionListObserver:obs];
    objc_setAssociatedObject(self, &s_RZAutoLayoutHeightManagerToken, obs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
