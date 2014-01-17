//
//  RZCellSizeManager.h
//  Raizlabs
//
//  Created by Alex Rouse on 12/11/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void    (^RZCellSizeManagerConfigBlock)(id cell, id object);
typedef CGFloat (^RZCellSizeManagerHeightBlock)(id cell, id object);
typedef CGSize  (^RZCellSizeManagerSizeBlock)(id cell, id object);

/**
 *  RZCellSizeManager
 *
 *  RZCellSizeManager is an object that can be created to manage custom cell sizes.
 *  All sizes calculated will be cached so that look-up times will be much faster for additional
 *  calls for the size of a cell based on an index path.
 *  The cached heights can be invalidated at any time by indexpath or the entire cache.
 **/

@interface RZCellSizeManager : NSObject

// Assumes that the cell comes from a nib and has the same name as the class
- (instancetype)initWithCellClassName:(NSString *)cellClass
                          objectClass:(Class)objectClass
                   configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;

- (instancetype)initWithCellClassName:(NSString *)cellClass
                  cellReuseIdentifier:(NSString *)reuseIdentifier
                   configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;


// This version still caches heights, but instead of autolayout uses the response from the provided block instead.
// Useful for when height is only dependent on one particular view and performance may be an issue.
- (instancetype)initWithCellClassName:(NSString *)cellClass
                          objectClass:(Class)objectClass
                          heightBlock:(RZCellSizeManagerHeightBlock)heightBlock;
- (instancetype)initWithCellClassName:(NSString *)cellClass
                  cellReuseIdentifier:(NSString *)reuseIdentifier
                          heightBlock:(RZCellSizeManagerHeightBlock)heightBlock;


// This version still caches sizes, but instead of autolayout uses the response from the provided block instead.
// Useful for when height is only dependent on one particular view and performance may be an issue.
- (instancetype)initWithCellClassName:(NSString *)cellClass
                          objectClass:(Class)objectClass
                            sizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;
- (instancetype)initWithCellClassName:(NSString *)cellClass
                  cellReuseIdentifier:(NSString *)reuseIdentifier
                            sizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;


// Registration For additional cells using a configurationBlock
- (void)registerCellClassName:(NSString *)cellClass
               forObjectClass:(Class)objectClass
           configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;
- (void)registerCellClassName:(NSString *)cellClass
           forReuseIdentifier:(NSString *)reuseIdentifier
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;

// Registration For additional cells using a heightBlock
- (void)registerCellClassName:(NSString *)cellClass
               forObjectClass:(Class)objectClass
              withHeightBlock:(RZCellSizeManagerHeightBlock)heightBlock;
- (void)registerCellClassName:(NSString *)cellClass
           forReuseIdentifier:(NSString *)reuseIdentifier
              withHeightBlock:(RZCellSizeManagerHeightBlock)heightBlock;

// Registration for additional cells using the sizeBlock
- (void)registerCellClassName:(NSString *)cellClass
               forObjectClass:(Class)objectClass
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;
- (void)registerCellClassName:(NSString *)cellClass
           forReuseIdentifier:(NSString *)reuseIdentifier
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;

// Clears the cached heights.
- (void)invalidateCellSizeCache;
- (void)invalidateCellSizeAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateCellSizesAtIndexPaths:(NSArray *)indexPaths;

// Returns the height for the cell given an object and an index.
- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath;
- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath cellReuseIdentifier:(NSString *)reuseIdentifier;

// Returns the Size for the cell given an object and an index.
- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath;
- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath cellReuseIdentifier:(NSString *)reuseIdentifier;

@end
