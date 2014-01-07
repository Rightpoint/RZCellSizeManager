//
//  RZCellSizeManager.m
//  Raizlabs
//
//  Created by Alex Rouse on 12/11/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZCellSizeManager.h"

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
    if ([self isKindOfClass:[UICollectionViewCell class]] || [self isKindOfClass:[UITableViewCell class]])
    {
        for(NSLayoutConstraint *cellConstraint in self.constraints){
            [self removeConstraint:cellConstraint];
            id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
            id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
            NSLayoutConstraint* contentViewConstraint =
            [NSLayoutConstraint constraintWithItem:firstItem
                                         attribute:cellConstraint.firstAttribute
                                         relatedBy:cellConstraint.relation
                                            toItem:seccondItem
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
 * RZCellHeightManager
 **/

@interface RZCellSizeManager ()
@property (nonatomic, strong) id offScreenCell;
@property (nonatomic, strong) NSString* cellClassName;
@property (nonatomic, strong) NSString* cellNibName;
@property (nonatomic, strong) NSCache* cellSizeCache;

@property (nonatomic, copy) RZCellSizeManagerConfigBlock configurationBlock;
@property (nonatomic, copy) RZCellSizeManagerHeightBlock heightBlock;
@property (nonatomic, copy) RZCellSizeManagerSizeBlock sizeBlock;
@end

@implementation RZCellSizeManager

- (instancetype)initWithCellClassName:(NSString *)cellClass configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock
{
    return [self initWithCellClassName:cellClass cellNibName:cellClass configurationBlock:configurationBlock];
}
- (instancetype)initWithCellClassName:(NSString *)cellClass cellNibName:(NSString *)cellNib configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock
{
    self = [super init];
    if (self)
    {
        self.configurationBlock = configurationBlock;
        self.cellClassName = cellClass;
        self.cellNibName = cellNib;
        self.cellSizeCache = [[NSCache alloc] init];
        [self configureOffScreenCell];
    }
    return self;
}

- (instancetype)initWithCellClassName:(NSString *)cellClass heightBlock:(RZCellSizeManagerHeightBlock)heightBlock
{
    return [self initWithCellClassName:cellClass cellNibName:cellClass heightBlock:heightBlock];
}

- (instancetype)initWithCellClassName:(NSString *)cellClass cellNibName:(NSString *)cellNib heightBlock:(RZCellSizeManagerHeightBlock)heightBlock
{
    self = [super init];
    if (self)
    {
        self.heightBlock = heightBlock;
        self.cellClassName = cellClass;
        self.cellNibName = cellNib;
        self.cellSizeCache = [[NSCache alloc] init];
        [self configureOffScreenCell];
    }
    return self;
}

- (instancetype)initWithCellClassName:(NSString *)cellClass sizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock
{
    return [self initWithCellClassName:cellClass cellNibName:cellClass sizeBlock:sizeBlock];
}
- (instancetype)initWithCellClassName:(NSString *)cellClass cellNibName:(NSString *)cellNib sizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock
{
    self = [super init];
    if (self)
    {
        self.sizeBlock = sizeBlock;
        self.cellClassName = cellClass;
        self.cellNibName = cellNib;
        self.cellSizeCache = [[NSCache alloc] init];
        [self configureOffScreenCell];
    }
    return self;
}

- (void)configureOffScreenCell
{
    if (self.cellNibName)
    {
        UINib* nib = [UINib nibWithNibName:self.cellNibName bundle:nil];
        self.offScreenCell = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        [self.offScreenCell moveConstraintsToContentView];
    }
    else
    {
        self.offScreenCell = [[NSClassFromString(self.cellClassName) alloc] init];
    }
}

#pragma mark - Public Methods

- (void)invalidateCellHeightCache
{
    [self.cellSizeCache removeAllObjects];
}

- (void)invalidateCellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    [self.cellSizeCache removeObjectForKey:indexPath];
}

- (void)invalidateCellHeightsAtIndexPaths:(NSArray *)indexPaths
{
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath* obj, NSUInteger idx, BOOL *stop) {
        [self.cellSizeCache removeObjectForKey:obj];
    }];
}

- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath
{
    NSNumber * height = [self.cellSizeCache objectForKey:indexPath];
    if (height == nil)
    {
        if (self.configurationBlock)
        {
            self.configurationBlock(self.offScreenCell, object);
            UIView* contentView = [self.offScreenCell contentView];
            height = @([contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
        }
        else if (self.heightBlock)
        {
            height = @(self.heightBlock(self.offScreenCell, object));
        }
        
        if (height)
        {
            [self.cellSizeCache setObject:height forKey:indexPath];
        }
    }
    return [height floatValue];
}

- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath
{
    id obj = [self.cellSizeCache objectForKey:indexPath];
    CGSize size = CGSizeZero;
    if (obj == nil)
    {
        BOOL validSize = NO;
        if (self.configurationBlock)
        {
            self.configurationBlock(self.offScreenCell, object);
            UIView* contentView = [self.offScreenCell contentView];
            size = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            validSize = YES;
        }
        else if (self.sizeBlock)
        {
            size = self.sizeBlock(self.offScreenCell, object);
            validSize = YES;
        }
        
        if (validSize)
        {
            [self.cellSizeCache setObject:[NSValue valueWithCGSize:size] forKey:indexPath];
        }
        
    }
    else
    {
        // Hopefully we have an NSValue object that has a CGSize value
        if ([obj isKindOfClass:[NSValue class]])
        {
            size = [obj CGSizeValue];
        }
    }
    return size;
}

@end



