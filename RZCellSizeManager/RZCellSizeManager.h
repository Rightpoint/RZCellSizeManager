//
//  RZCellSizeManager.h
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


/**
 *  Registers a cell for height computation by its class name, for a particular
 *  data object class. The height will be computed using using a configuration block.
 *
 *  This flavor of registration is useful for registering a cell that represents an instance of 
 *  a model object if the cell's height is determined by the data in the object.
 *
 *  @param cellClass          Name of the cell class
 *  @param nibNameOrNil       Name of the nib file representing the cell, or nil to use the default name (or if there is no nib)
 *  @param objectClass        Class of the model object this cell represents
 *  @param configurationBlock Block which is passed a pointer to the cell as well as the model object.
 *                            The block should configure the cell's subviews from the model object.
 *
 */
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;

/**
 *  Registers a cell for height computation by its class name, for a particular
 *  reuse identifier. The height will be computed using a configuration block.
 *
 *  This flavor of registration is useful for registering a cell that represents an instance of
 *  a model object if the cell's height is determined by the data in the object.
 *
 *  @param cellClass          Name of the cell class.
 *  @param reuseIdentifier
 *  @param nibNameOrNil       Name of the nib file representing the cell, or nil to use the default name (or if there is no nib)
 *  @param configurationBlock <#configurationBlock description#>
 */
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;

// Registration For additional cells using a heightBlock
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
              withHeightBlock:(RZCellSizeManagerHeightBlock)heightBlock;

- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
              withHeightBlock:(RZCellSizeManagerHeightBlock)heightBlock;

// Registration for additional cells using the sizeBlock
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;

- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;

// Clears the cached heights.
- (void)invalidateCellSizeCache;
- (void)invalidateCellSizeAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateCellSizesAtIndexPaths:(NSArray *)indexPaths;

// This defaults to 1 px.  This is because a UITableViewCell uses a seperator as part of its height so it will cut off the content.
// You should set this to 0 if you don't have cell dividers, or set it to whatever you divider is set too.
@property (nonatomic, assign) CGFloat cellHeightPadding;

// This is used to override a static width for a cell.  A possible usecase would be having a cell created for iPhone at 320.0 pt's wide
//  work on an iPad with a width of 768.0 pt's.  Setting this automatically invalidates the cache.
//
// NOTE: If you have labels that you want to have a dynamic height you must make sure that the preferredMaxLayoutWidth is correct.
//  You can use the RZAutolayoutLabel subclass for this if you need to.
@property (nonatomic, assign) CGFloat overideWidth;


// Returns the height for the cell given an object and an index.
- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath;
- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath cellReuseIdentifier:(NSString *)reuseIdentifier;

// Returns the Size for the cell given an object and an index.
- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath;
- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath cellReuseIdentifier:(NSString *)reuseIdentifier;

@end
