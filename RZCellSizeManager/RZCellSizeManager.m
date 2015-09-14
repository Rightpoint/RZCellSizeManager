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

#define kRZCellSizeManagerCellKey               @"RZCellSizeManagerCellKey"
#define kRZCellSizeManagerObjectClassKey        @"RZCellSizeManagerObjectClassKey"
#define kRZCellSizeManagerConfigurationBlockKey @"RZCellSizeManagerConfigurationBlockKey"

#define kRZCellSizeManagerDefaultCellHeightPadding  1.0f
/**
 * UICollectionViewCell (AutoLayout)
 *
 * Helper methods for a UICollectionViewCell
 **/

@interface UIView (AutoLayout)

- (void)moveConstraintsToContentView;

@end

/**
 *  A @c UIWindow subclass with a settable trait collection.
 */

@interface SettableTraitCollectionWindow : UIWindow

/**
 *  A settable trait collection. We use a custom name, instead of just @c traitCollection, to prevent potential future collisions.
 */
@property (strong, nonatomic) UITraitCollection *settableTraitCollection;

@end

@implementation SettableTraitCollectionWindow

- (void)setSettableTraitCollection:(UITraitCollection *)settableTraitCollection
{
    if ( _settableTraitCollection != settableTraitCollection ) {

        // Only if trait collection is available (iOS 8+)
        if ( [UITraitCollection class] ) {
            UITraitCollection *oldTraitCollection = _settableTraitCollection;
            _settableTraitCollection = settableTraitCollection;

            // Only if trait collection is available (iOS 8+)
            if ( [super respondsToSelector:@selector(traitCollectionDidChange:)] ) {
                [super traitCollectionDidChange:oldTraitCollection];
            }
        }
    }
}

- (UITraitCollection *)traitCollection
{
    return self.settableTraitCollection;
}

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
            id secondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
            //There is a case where we can grab the iOS7 UITableViewCellScrollView which will break, this check is for that.
            if (([[firstItem superview] isEqual:self] && ![firstItem isEqual:self.contentView]) ||
                ([[secondItem superview] isEqual:self] && ![secondItem isEqual:self.contentView]))
            {
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
@property (nonatomic, copy) RZCellSizeManagerHeightBlock heightBlock;
@property (nonatomic, copy) RZCellSizeManagerSizeBlock sizeBlock;
@property (nonatomic, assign) Class objectClass;
@property (nonatomic, strong) NSString* cellClass;
@property (nonatomic, strong) NSString* reuseIdentifier;

+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                               objectClass:(Class)objectClass
                        configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;
+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                               objectClass:(Class)objectClass
                               heightBlock:(RZCellSizeManagerHeightBlock)heightBlock;
+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                               objectClass:(Class)objectClass
                                 sizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;
@end

@implementation RZCellSizeManagerCellConfiguration

+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                               objectClass:(Class)objectClass
                        configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock
{
    RZCellSizeManagerCellConfiguration* config = [RZCellSizeManagerCellConfiguration new];
    config.cell = cell;
    config.cellClass = cellClass;
    config.objectClass = objectClass;
    config.configurationBlock = configurationBlock;
    return config;
}

+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                               objectClass:(Class)objectClass
                               heightBlock:(RZCellSizeManagerHeightBlock)heightBlock;
{
    RZCellSizeManagerCellConfiguration* config = [RZCellSizeManagerCellConfiguration new];
    config.cell = cell;
    config.cellClass = cellClass;
    config.objectClass = objectClass;
    config.heightBlock = heightBlock;
    return config;
}

+ (instancetype) cellConfigurationWithCell:(id)cell
                                 cellClass:(NSString *)cellClass
                               objectClass:(Class)objectClass
                                 sizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock
{
    RZCellSizeManagerCellConfiguration* config = [RZCellSizeManagerCellConfiguration new];
    config.cell = cell;
    config.cellClass = cellClass;
    config.objectClass = objectClass;
    config.sizeBlock = sizeBlock;
    return config;
}

@end


/**
 * RZCellSizeManager
 **/

@interface RZCellSizeManager ()

@property (nonatomic, strong) NSMutableDictionary* cellConfigurations;
@property (nonatomic, strong) id offScreenCell;
@property (nonatomic, strong) NSString* cellClassName;
@property (nonatomic, strong) NSString* cellNibName;
@property (nonatomic, strong) NSCache* cellSizeCache;

@property (nonatomic, strong, readonly) SettableTraitCollectionWindow *settableTraitCollectionWindow;

@property (nonatomic, assign) BOOL isUsingObjectTypesForLookup;

@property (nonatomic, copy) RZCellSizeManagerConfigBlock configurationBlock;
@property (nonatomic, copy) RZCellSizeManagerHeightBlock heightBlock;
@property (nonatomic, copy) RZCellSizeManagerSizeBlock sizeBlock;

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
        _cellConfigurations = [NSMutableDictionary dictionary];
        _cellSizeCache = [[NSCache alloc] init];
        _cellHeightPadding = kRZCellSizeManagerDefaultCellHeightPadding;
    }
    return self;
}

#pragma mark - Custom Setters

- (void)setOverideWidth:(CGFloat)overideWidth
{
    if (overideWidth != _overideWidth)
    {
        _overideWidth = overideWidth;

        [self.cellConfigurations enumerateKeysAndObjectsUsingBlock:^(id key, RZCellSizeManagerCellConfiguration *obj, BOOL *stop) {
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

- (void)setTraitCollection:(UITraitCollection *)traitCollection
{
    if ( ![_traitCollection isEqual:traitCollection] ) {
        _traitCollection = traitCollection;

        // This is an over-cautious assumption. Trait collection changes do not necessarily mean that the sizes are invalidated.
        // In future, we could provide more control over cell size cache invalidation.
        [self invalidateCellSizeCache];
    }
}

#pragma mark - Getters

- (SettableTraitCollectionWindow *)settableTraitCollectionWindow
{
    static NSMutableDictionary *settableTraitCollectionWindows = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settableTraitCollectionWindows = [[NSMutableDictionary alloc] init];
    });

    SettableTraitCollectionWindow *settableTraitCollectionWindow = settableTraitCollectionWindows[self.traitCollection];
    if (settableTraitCollectionWindow == nil || [settableTraitCollectionWindow isEqual:[NSNull null]]) {
        settableTraitCollectionWindow = [[SettableTraitCollectionWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        settableTraitCollectionWindow.settableTraitCollection = self.traitCollection;
        settableTraitCollectionWindow.windowLevel = -(CGFLOAT_MAX - settableTraitCollectionWindows.count); // for different window levels
        settableTraitCollectionWindow.rootViewController = [[UIViewController alloc] init];
        settableTraitCollectionWindow.hidden = NO;
    }

    return settableTraitCollectionWindow;
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
    
    RZCellSizeManagerCellConfiguration* configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell
                                                                                                            cellClass:cellClass
                                                                                                          objectClass:objectClass
                                                                                                   configurationBlock:configurationBlock];
    [self.cellConfigurations setObject:configuration forKey:cellClass];
}

- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock
{
    NSParameterAssert(cellClass);
    NSParameterAssert(configurationBlock);
    
    id cell = [self configureOffScreenCellWithCellClassName:cellClass nibName:nibNameOrNil];
    
    RZCellSizeManagerCellConfiguration* configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell
                                                                                                            cellClass:cellClass
                                                                                                          objectClass:nil
                                                                                                   configurationBlock:configurationBlock];
    configuration.reuseIdentifier = reuseIdentifier;
    [self.cellConfigurations setObject:configuration forKey:cellClass];
}


- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
              withHeightBlock:(RZCellSizeManagerHeightBlock)heightBlock
{
    NSParameterAssert(cellClass);
    NSParameterAssert(heightBlock);
    
    id cell = [self configureOffScreenCellWithCellClassName:cellClass nibName:nibNameOrNil];
    RZCellSizeManagerCellConfiguration* configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell
                                                                                                            cellClass:cellClass
                                                                                                          objectClass:objectClass
                                                                                                            heightBlock:heightBlock];
    [self.cellConfigurations setObject:configuration forKey:cellClass];
}

- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
              withHeightBlock:(RZCellSizeManagerHeightBlock)heightBlock
{
    NSParameterAssert(cellClass);
    NSParameterAssert(heightBlock);
    
    id cell = [self configureOffScreenCellWithCellClassName:cellClass nibName:nibNameOrNil];
    RZCellSizeManagerCellConfiguration* configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell
                                                                                                            cellClass:cellClass
                                                                                                          objectClass:nil
                                                                                                            heightBlock:heightBlock];
    configuration.reuseIdentifier = reuseIdentifier;
    [self.cellConfigurations setObject:configuration forKey:cellClass];
}

- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock
{
    NSParameterAssert(cellClass);
    NSParameterAssert(sizeBlock);
    
    id cell = [self configureOffScreenCellWithCellClassName:cellClass nibName:nibNameOrNil];
    RZCellSizeManagerCellConfiguration* configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell
                                                                                                            cellClass:cellClass
                                                                                                          objectClass:objectClass
                                                                                                            sizeBlock:sizeBlock];
    [self.cellConfigurations setObject:configuration forKey:cellClass];
}

- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock
{
    NSParameterAssert(cellClass);
    NSParameterAssert(sizeBlock);
    
    id cell = [self configureOffScreenCellWithCellClassName:cellClass nibName:nibNameOrNil];
    RZCellSizeManagerCellConfiguration* configuration = [RZCellSizeManagerCellConfiguration cellConfigurationWithCell:cell
                                                                                                            cellClass:cellClass
                                                                                                          objectClass:nil
                                                                                                            sizeBlock:sizeBlock];
    configuration.reuseIdentifier = reuseIdentifier;
    [self.cellConfigurations setObject:configuration forKey:cellClass];
}

#pragma mark - Other Public Methods

- (void)invalidateCellSizeCache
{
    [self.cellSizeCache removeAllObjects];
}

- (void)invalidateCellSizeAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath);
    [self.cellSizeCache removeObjectForKey:indexPath];
}

- (void)invalidateCellSizesAtIndexPaths:(NSArray *)indexPaths
{
    NSParameterAssert(indexPaths);
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath* obj, NSUInteger idx, BOOL *stop) {
        [self.cellSizeCache removeObjectForKey:obj];
    }];
}

- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath
{
    return [self cellHeightForObject:object indexPath:indexPath cellReuseIdentifier:nil];
}

- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath cellReuseIdentifier:(NSString *)reuseIdentifier
{
    NSParameterAssert(indexPath);

    NSNumber * height = [self.cellSizeCache objectForKey:indexPath];
    if (height == nil)
    {
        RZCellSizeManagerCellConfiguration* configuration = [self configurationForObject:object reuseIdentifier:reuseIdentifier];
        
        height = [self cellHeightForObject:object configuration:configuration];
        
        if (height)
        {
            [self.cellSizeCache setObject:height forKey:indexPath];
        }
    }
    return [height floatValue];
}

- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath
{
    return [self cellSizeForObject:object indexPath:indexPath cellReuseIdentifier:nil];
}

- (void)addCellToWindowIfNeeded:(UIView *)cell
{
    if ( self.traitCollection && !cell.superview ) {
        [self.settableTraitCollectionWindow.rootViewController.view addSubview:cell];
    }
}

- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath cellReuseIdentifier:(NSString *)reuseIdentifier
{
    NSParameterAssert(indexPath);
    
    id obj = [self.cellSizeCache objectForKey:indexPath];
    CGSize size = CGSizeZero;
    if (obj == nil)
    {
        RZCellSizeManagerCellConfiguration* configuration = [self configurationForObject:object reuseIdentifier:reuseIdentifier];
        
        BOOL validSize = NO;
        if (configuration)
        {
            if (configuration.configurationBlock)
            {
                [self addCellToWindowIfNeeded:configuration.cell];

                [configuration.cell prepareForReuse];
                configuration.configurationBlock(configuration.cell, object);
                UIView* contentView = [configuration.cell contentView];
                CGSize size;
                if ( self.overideWidth == 0.0f ) {
                    size = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
                }
                else {
                    CGSize fittingSize = CGSizeMake(self.overideWidth, UILayoutFittingCompressedSize.height);
                    size = [contentView systemLayoutSizeFittingSize:fittingSize withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
                }

                // If a cell has an internal width or height constraint (for example, the kind used to auto-size cells
                // when you want a fixed width), it will conflict with the cell's native size on the next layout pass
                // unless we update the cell’s frame to match the size we were just given.
                CGRect cellFrame = CGRectMake(0.0f, 0.0f, size.width, size.height);
                [configuration.cell setFrame:cellFrame];
                [[configuration.cell contentView] setFrame:cellFrame];

                validSize = YES;
                
            }
            else if (configuration.sizeBlock)
            {
                size = configuration.sizeBlock(configuration.cell, object);
                validSize = YES;
                
            }
            
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

#pragma mark - Private Methods

/**
 * Creates a cell to be stored offscreen to use for AutoLayout.
 * The cell is initially created from a nib that shares the same name as the class passed in.
 *  It will then just allocate an instance using the default init.
 **/
- (id)configureOffScreenCellWithCellClassName:(NSString *)className nibName:(NSString *)nibNameOrNil
{
    if ([self.cellConfigurations objectForKey:className])
    {
        [self.cellConfigurations removeObjectForKey:className];
    }
    
    //Configure the static cell
    id cell = nil;
    if (className)
    {
        NSString *nibName = nibNameOrNil != nil ? nibNameOrNil : className;
        BOOL nibExists = ([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"] != nil);
        UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
        
        // Try and instantiate the cell from the nib.  If not we shall just call init on it.
        if ( nibExists ) {
            cell = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        else {
            // There is a chance that we want to just create it with init.
            cell = [[NSClassFromString(className) alloc] init];
        }

        [cell moveConstraintsToContentView];

        if (self.overideWidth != 0)
        {
            CGRect overideFrame = [cell frame];
            overideFrame.size.width = self.overideWidth;
            [cell setFrame:overideFrame];
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
        }
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
    if (reuseIdentifier)
    {
        [self.cellConfigurations enumerateKeysAndObjectsUsingBlock:^(id key, RZCellSizeManagerCellConfiguration* obj, BOOL *stop) {
            if ([reuseIdentifier isEqualToString:obj.reuseIdentifier])
            {
                configuration = obj;
                *stop = YES;
            }
        }];
    }
    else
    {
        [self.cellConfigurations enumerateKeysAndObjectsUsingBlock:^(id key, RZCellSizeManagerCellConfiguration* obj, BOOL *stop) {
            if ([object isKindOfClass:obj.objectClass])
            {
                configuration = obj;
                *stop = YES;
            }
        }];
    }
    
    if (!configuration)
    {
        configuration = [[self.cellConfigurations allValues] firstObject];
    }
    
    return configuration;

}

- (NSNumber *)cellHeightForObject:(id)object configuration:(RZCellSizeManagerCellConfiguration *)configuration
{
    NSNumber* height = nil;
    if (configuration)
    {
        if (configuration.configurationBlock)
        {
            [self addCellToWindowIfNeeded:configuration.cell];

            [configuration.cell prepareForReuse];
            configuration.configurationBlock(configuration.cell, object);
            [configuration.cell layoutIfNeeded];
            UIView* contentView = [configuration.cell contentView];

            CGSize size;
            if ( self.overideWidth == 0.0f ) {
                size = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            }
            else {
                CGSize fittingSize = CGSizeMake(self.overideWidth, UILayoutFittingCompressedSize.height);
                size = [contentView systemLayoutSizeFittingSize:fittingSize withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
            }
            size.height += self.cellHeightPadding;

            // If a cell has an internal width or height constraint (for example, the kind used to auto-size cells
            // when you want a fixed width), it will conflict with the cell's native size on the next layout pass
            // unless we update the cell’s frame to match the size we were just given.
            CGRect cellFrame = CGRectMake(0.0f, 0.0f, size.width, size.height);
            [configuration.cell setFrame:cellFrame];
            [[configuration.cell contentView] setFrame:cellFrame];

            height = @(size.height);
        }
        else if (configuration.heightBlock)
        {
            height = @(configuration.heightBlock(configuration.cell, object) + self.cellHeightPadding);
        }
        
    }
    return height;

}

@end


