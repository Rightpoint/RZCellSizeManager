//
//  RZCellSizeManager.m
//
//  Created by Alex Rouse on 12/11/13.

// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import "RZCellSizeManager.h"

#define kRZCellSizeManagerDefaultCellHeightPadding  1.0f

/**
 * UICollectionViewCell (AutoLayout)
 *
 * Helper methods for a UICollectionViewCell
 **/
@interface UIView (AutoLayout)

- (void)moveConstraintsToContentView;

@end

@implementation UIView (AutoLayout)

// Taken from : http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-heights
// Note that there may be performance issues with this in some cases.  Should only call in on Awake from nib or initialization and not on reuse.
- (void)moveConstraintsToContentView
{
    if ( [self isKindOfClass:[UICollectionViewCell class]] || [self isKindOfClass:[UITableViewCell class]] ) {
        for( NSLayoutConstraint *cellConstraint in self.constraints ) {
            [self removeConstraint:cellConstraint];
            id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
            id secondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
            //There is a case where we can grab the iOS7 UITableViewCellScrollView which will break, this check is for that.
            if ( ([[firstItem superview] isEqual:self] && ![firstItem isEqual:self.contentView]) ||
                ([[secondItem superview] isEqual:self] && ![secondItem isEqual:self.contentView]) ) {
                continue;
            }
            
            NSLayoutConstraint* contentViewConstraint =
            [NSLayoutConstraint constraintWithItem:firstItem
                                         attribute:cellConstraint.firstAttribute
                                         relatedBy:cellConstraint.relation
                                            toItem:secondItem
                                         attribute:cellConstraint.secondAttribute
                                        multiplier:cellConstraint.multiplier
                                          constant:cellConstraint.constant];
            [self.contentView addConstraint:contentViewConstraint];
        }
    }
}

- (UIView *)contentView
{
    // We know we are a collectionview cell or a tableview cell so this is safe.
    return [(UITableViewCell *)self contentView];
}

@end


/**
 *  RZCellSizeManagerCellConfiguration
 **/
@interface RZCellSizeManagerCellConfiguration : NSObject

@property (nonatomic, strong) id cell;
@property (nonatomic, copy) RZCellSizeManagerConfigBlock configurationBlock;
@property (nonatomic, copy) RZCellSizeManagerSizeBlock sizeBlock;
@property (nonatomic, assign) Class objectClass;
@property (nonatomic, copy) NSString *cellClass;
@property (nonatomic, copy) NSString *reuseIdentifier;

+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                           reuseIdentifier:(NSString *)reuseIdentifier
                               objectClass:(Class)objectClass
                        configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;

+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                           reuseIdentifier:(NSString *)reuseIdentifier
                               objectClass:(Class)objectClass
                                 sizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;
@end

@implementation RZCellSizeManagerCellConfiguration

+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                           reuseIdentifier:(NSString *)reuseIdentifier
                               objectClass:(Class)objectClass
                        configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;
{
    RZCellSizeManagerCellConfiguration* config = [RZCellSizeManagerCellConfiguration new];
    config.cell = cell;
    config.cellClass = cellClass;
    config.objectClass = objectClass;
    config.configurationBlock = configurationBlock;
    config.reuseIdentifier = reuseIdentifier;
    return config;
}

+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                           reuseIdentifier:(NSString *)reuseIdentifier
                               objectClass:(Class)objectClass
                                 sizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;
{
    RZCellSizeManagerCellConfiguration* config = [RZCellSizeManagerCellConfiguration new];
    config.cell = cell;
    config.cellClass = cellClass;
    config.objectClass = objectClass;
    config.sizeBlock = sizeBlock;
    config.reuseIdentifier = reuseIdentifier;
    return config;
}

@end


/**
 * RZCellHeightManager
 **/

@interface RZCellSizeManager ()

@property (nonatomic, strong) NSMutableArray *configurationList;
@property (nonatomic, strong) NSCache *cellSizeCache;

@property (nonatomic, assign) BOOL shouldKeySizeCacheOffObjects;

@end

@implementation RZCellSizeManager

#pragma mark - Initializers

/**
 * A common init function
 * Initializes the cellConfigurations dictionary and the cellSizeCache.
 **/
- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _configurationList = [[NSMutableArray alloc] init];
        _cellSizeCache = [[NSCache alloc] init];
        _cellHeightPadding = kRZCellSizeManagerDefaultCellHeightPadding;
    }
    return self;
}

#pragma mark - Custom Setters

- (void)setOverideWidth:(CGFloat)overideWidth
{
    if ( overideWidth != _overideWidth ) {
        _overideWidth = overideWidth;
        [self.configurationList enumerateObjectsUsingBlock:^(RZCellSizeManagerCellConfiguration *obj, NSUInteger idx, BOOL *stop) {
            id cell = obj.cell;
            CGRect overideFrame = [cell frame];
            overideFrame.size.width = overideWidth;
            [cell setFrame:overideFrame];
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
        }];
        [self invalidateCellSizeCache];
    }
}

- (void)setShouldKeySizeCacheOffObjects:(BOOL)shouldKeySizeCacheOffObjects
{
    if ( shouldKeySizeCacheOffObjects != _shouldKeySizeCacheOffObjects ) {
        _shouldKeySizeCacheOffObjects = shouldKeySizeCacheOffObjects;
        [self invalidateCellSizeCache];
    }
}
#pragma mark - Registration methods


- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock
{
    NSParameterAssert(cellClass);
    NSParameterAssert(configurationBlock);
    
    id cell = [self configureOffScreenCellWithCellClassName:cellClass nibName:nibNameOrNil];
    
    RZCellSizeManagerCellConfiguration *configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell cellClass:cellClass reuseIdentifier:nil objectClass:objectClass configurationBlock:configurationBlock];

    [self.configurationList addObject:configuration];
}

- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock
{
    NSParameterAssert(cellClass);
    NSParameterAssert(configurationBlock);
    
    id cell = [self configureOffScreenCellWithCellClassName:cellClass nibName:nibNameOrNil];
    
    RZCellSizeManagerCellConfiguration *configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell cellClass:cellClass reuseIdentifier:reuseIdentifier objectClass:nil configurationBlock:configurationBlock];

    [self.configurationList addObject:configuration];
}


- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock
{
    NSParameterAssert(cellClass);
    NSParameterAssert(sizeBlock);
    
    id cell = [self configureOffScreenCellWithCellClassName:cellClass nibName:nibNameOrNil];
    RZCellSizeManagerCellConfiguration *configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell cellClass:cellClass reuseIdentifier:nil objectClass:objectClass sizeBlock:sizeBlock];

    [self.configurationList addObject:configuration];
}

- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock
{
    NSParameterAssert(cellClass);
    NSParameterAssert(sizeBlock);
    
    id cell = [self configureOffScreenCellWithCellClassName:cellClass nibName:nibNameOrNil];
    RZCellSizeManagerCellConfiguration *configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell cellClass:cellClass reuseIdentifier:reuseIdentifier objectClass:nil sizeBlock:sizeBlock];

    [self.configurationList addObject:configuration];
}

#pragma mark - Other Public Methods

- (void)invalidateCellSizeCache
{
    [self.cellSizeCache removeAllObjects];
}

- (void)invalidateCellSizeAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath != nil ) {
        [self.cellSizeCache removeObjectForKey:indexPath];
    }
}

- (void)invalidateCellSizesAtIndexPaths:(NSArray *)indexPaths
{
    if ( indexPaths != nil ) {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath* obj, NSUInteger idx, BOOL *stop) {
            [self.cellSizeCache removeObjectForKey:obj];
        }];
    }
}

- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath
{
    return [self cellSizeForObject:object indexPath:indexPath cellReuseIdentifier:nil];
}

- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath cellReuseIdentifier:(NSString *)reuseIdentifier
{
    NSAssert( !(indexPath == nil && self.shouldKeySizeCacheOffObjects) , @"An index path is required if you are not using Object based Size Cacheing.  See @property shouldKeySizeCacheOffObjects" );
    NSAssert( !(self.shouldKeySizeCacheOffObjects && object == nil) , @"An Object is required when using Object based Size Cacheing.  See @property shouldKeySizeCacheOffObjects" );

    id obj = nil;
    if ( self.shouldKeySizeCacheOffObjects && [object isKindOfClass:[NSObject class]] ) {
        obj = [self.cellSizeCache objectForKey:@(((NSObject *)object).hash)];
    }
    else {
        obj = [self.cellSizeCache objectForKey:indexPath];
    }
    CGSize size = CGSizeZero;
    if ( obj == nil ) {
        RZCellSizeManagerCellConfiguration* configuration = [self configurationForObject:object reuseIdentifier:reuseIdentifier];
        
        BOOL validSize = NO;
        if ( configuration ) {
            if ( configuration.configurationBlock ) {
                [configuration.cell prepareForReuse];
                configuration.configurationBlock(configuration.cell, object);
                UIView* contentView = [configuration.cell contentView];
                size = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
                validSize = YES;
            }
            else if ( configuration.sizeBlock ) {
                size = configuration.sizeBlock(configuration.cell, object);
                validSize = YES;
            }
        }

        if ( validSize ) {
            id key = indexPath;
            if ( self.shouldKeySizeCacheOffObjects ) {
                key = @(((NSObject *)object).hash);
            }
            [self.cellSizeCache setObject:[NSValue valueWithCGSize:size] forKey:key];
        }
    }
    else {
        if ( [obj isKindOfClass:[NSValue class]] ) {
            size = [obj CGSizeValue];
        }
        else {
            NSAssert( false, @"Cache returned a non size value.  Something is very wrong" );
        }
    }
    return size;
}

#pragma mark - Private Methods

/**
 * Creates a cell to be stored offscreen to use for AutoLayout.
 * The cell is initially created from a nib that shares the same name as the class passed in.
 *  It will then just allocate an instance using the default init.
 **/
- (id)configureOffScreenCellWithCellClassName:(NSString *)className nibName:(NSString *)nibNameOrNil
{
    //Configure the static cell
    id cell = nil;
    if ( className ) {
        NSString *nibName = nibNameOrNil ?: className;
        UINib* nib = [UINib nibWithNibName:nibName bundle:nil];
        
        // Try and instantiate the cell from the nib.  If not we shall just call init on it.
        @try {
            cell = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        @catch (NSException *exception) {
            // There is a chance that we want to just create it with init.
            cell = [[NSClassFromString(className) alloc] init];
        }
        @finally {
            
        }
        if ( self.shouldTransferConstraintsToContentView ) {
            [cell moveConstraintsToContentView];
        }
    }

    if ( self.overideWidth != 0 ) {
        CGRect overideFrame = [cell frame];
        overideFrame.size.width = self.overideWidth;
        [cell setFrame:overideFrame];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
    }
    
    NSAssert(cell != nil, @"Cell not created successfully.  Make sure there is a cell with your class name in your project:%@",className);
    return cell;
}

/** 
 * returns the configuration object that is associated with either the object or the reuseIdentifier
 * This will first check to see if we are sending in a reuseIdentifier.  If we do, it will not try and
 *  object match, otherwise it will see if we have an object class regiserted to match the object.
 **/
- (RZCellSizeManagerCellConfiguration *)configurationForObject:(id)object reuseIdentifier:(NSString *)reuseIdentifier
{
    __block RZCellSizeManagerCellConfiguration* configuration = nil;
    if ( reuseIdentifier ) {
        [self.configurationList enumerateObjectsUsingBlock:^(RZCellSizeManagerCellConfiguration *obj, NSUInteger idx, BOOL *stop) {
            if ( [reuseIdentifier isEqualToString:obj.reuseIdentifier] ) {
                configuration = obj;
                *stop = YES;
            }
        }];
    }

    if ( !configuration ) {
        [self.configurationList enumerateObjectsUsingBlock:^(RZCellSizeManagerCellConfiguration *obj, NSUInteger idx, BOOL *stop) {
            if ( [object isKindOfClass:obj.objectClass] ) {
                configuration = obj;
                *stop = YES;
            }
        }];
    }
    
    if ( !configuration ) {
        configuration = [self.configurationList firstObject];
    }
    
    return configuration;

}

@end

@implementation RZCellSizeManager (ObjectBasedCacheing)

- (CGSize) cellSizeForObject:(id)object
{
    return [self cellSizeForObject:object indexPath:nil cellReuseIdentifier:nil];
}

- (void)invalidateCellSizeForObject:(NSObject *)object
{
    if ( object != nil && self.shouldKeySizeCacheOffObjects ) {
        [self.cellSizeCache removeObjectForKey:@(object.hash)];
    }
}

- (void)invalidateCellSizeForObjects:(NSArray *)objects
{
    if ( objects != nil && self.shouldKeySizeCacheOffObjects ) {
        [objects enumerateObjectsUsingBlock:^(NSObject *obj, NSUInteger idx, BOOL *stop) {
            [self.cellSizeCache removeObjectForKey:@(obj.hash)];
        }];
    }
}

@end
