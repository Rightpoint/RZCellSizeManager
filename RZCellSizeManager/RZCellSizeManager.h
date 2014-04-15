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
 *  RZCellSizeManager is an object that can be created to manage custom UITableViewCell heights or UICollectionViewCell sizes.
 *  All sizes calculated will be cached so that look-up times will be much faster for additional calls for the size of a cell based 
 *  on an index path. The cached heights can be invalidated at any time by indexpath or the entire cache.
 **/
@interface RZCellSizeManager : NSObject


/**
 *  Registers a cell by its class name for a particular data object class. 
 *  The size/height will be computed automatically by autolayout after the cell is configured by a required block.
 *
 *  This flavor of registration is useful for registering a cell that represents an instance of 
 *  a model object if the cell's size/height can be determined by autolayout and the data in the object.
 *
 *  @warning    The configuration of the cell within the block should be simple and efficient.
 *              Cells with lots of autolayout constraints may slow down the responseiveness of the UI during size/height computation.
 *              If the cell configuration is complex, it may be better to use a size/height block registration instead.
 *
 *  @param cellClass          Name of the cell class. Must not be nil.
 *  @param nibNameOrNil       Name of the nib file representing the cell, or nil to use the default name (or if there is no nib)
 *  @param objectClass        Class of the model object this cell represents, or Nil to use this block for all cells.
 *  @param configurationBlock Block which is passed a pointer to the cell as well as a pointer to the model object, if applicable.
 *                            The block should configure the cell's subviews from the model object. Must not be nil.
 *
 */
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;

/**
 *  Registers a cell by its class name, for a particular reuse identifier. 
 *  The size/height of the cell will be computed using a configuration block.
 *
 *  This flavor of registration is useful for registering a cell that represents an instance of
 *  a model object if the cell's size/height can be determined by autolayout and the data in the object.
 *
 *  @warning    The configuration of the cell within the block should be simple and efficient.
 *              Cells with lots of autolayout constraints may slow down the responseiveness of the UI during size/height computation.
 *              If the cell configuration is complex, it may be better to use a size/height block registration instead.
 *
 *  @param cellClass          Name of the cell class. Must not be nil.
 *  @param nibNameOrNil       Name of the nib file representing the cell, or nil to use the default name (or if there is no nib)
 *  @param reuseIdentifier    Reuse identifier of the cell, or nil if all cells will have the same identifier
 *  @param configurationBlock Block which is passed a pointer to the cell as well as the model object for the cell, if applicable.
 *                            The block should configure the cell's subviews from the model object. Must not be nil.
 */
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;

/**
 *  Registers a cell by its class name, for a particular data object class. 
 *  The height of the cell will be computed externally using using a height block.
 *
 *  This flavor of registration is useful for registering a table view cell whose height can easily be computed
 *  externally (not using autolayout).
 *
 *  @param cellClass          Name of the cell class. Must not be nil.
 *  @param nibNameOrNil       Name of the nib file representing the cell, or nil to use the default name (or if there is no nib)
 *  @param objectClass        Class of the model object this cell represents, or Nil to use this block for all cells.
 *  @param heightBlock        Block which is passed a pointer to the cell as well as the model object for the cell, if applicable.
 *                            This block should compute the height of the cell and return it. Must not be nil.
 */
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
              withHeightBlock:(RZCellSizeManagerHeightBlock)heightBlock;

/**
 *  Registers a cell by its class name, for a particular reuse identifier.
 *  The height of the cell will be computed externally using using a height block.
 *
 *  This flavor of registration is useful for registering a table view cell whose height can easily be computed
 *  externally (not using autolayout).
 *
 *  @param cellClass          Name of the cell class. Must not be nil.
 *  @param nibNameOrNil       Name of the nib file representing the cell, or nil to use the default name (or if there is no nib)
 *  @param reuseIdentifier    Reuse identifier of the cell, or nil if all cells will have the same identifier
 *  @param heightBlock        Block which is passed a pointer to the cell as well as the model object for the cell, if applicable.
 *                            This block should compute the height of the cell and return it. Must not be nil.
 */
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
              withHeightBlock:(RZCellSizeManagerHeightBlock)heightBlock;

/**
 *  Registers a cell by its class name, for a particular data object class.
 *  The height of the cell will be computed externally using using a size block.
 *
 *  This flavor of registration is useful for registering a collection view cell whose size can easily be computed
 *  externally (not using autolayout).
 *
 *  @param cellClass          Name of the cell class. Must not be nil.
 *  @param nibNameOrNil       Name of the nib file representing the cell, or nil to use the default name (or if there is no nib)
 *  @param objectClass        Class of the model object this cell represents, or Nil to use this block for all cells.
 *  @param sizeBlock          Block which is passed a pointer to the cell as well as the model object for the cell, if applicable.
 *                            This block should compute the size of the cell and return it. Must not be nil.
 */
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;

/**
 *  Registers a cell by its class name, for a particular reuse identifier.
 *  The height of the cell will be computed externally using using a size block.
 *
 *  This flavor of registration is useful for registering a collection view cell whose size can easily be computed
 *  externally (not using autolayout).
 *
 *  @param cellClass          Name of the cell class. Must not be nil.
 *  @param nibNameOrNil       Name of the nib file representing the cell, or nil to use the default name (or if there is no nib)
 *  @param reuseIdentifier    Reuse identifier of the cell, or nil if all cells will have the same identifier
 *  @param sizeBlock          Block which is passed a pointer to the cell as well as the model object for the cell, if applicable.
 *                            This block should compute the size of the cell and return it. Must not be nil.
 */
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
                withSizeBlock:(RZCellSizeManagerSizeBlock)sizeBlock;

/**
 *  Invalidate the entire cache of cell sizes.
 */
- (void)invalidateCellSizeCache;

/**
 *  Invalidate the cached size for a cell at a particular index paths.
 *
 *  @param indexPath The index path of the cell for which the size will be invalidated. Must not be nil.
 */
- (void)invalidateCellSizeAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Invalidate the cached sizes for multiple cells.
 *
 *  @param indexPaths An array of NSIndexPaths of the cells for which the size will be invalidated. Must not be nil.
 */
- (void)invalidateCellSizesAtIndexPaths:(NSArray *)indexPaths;


/**
 *  Extra padding of the cell height. This defaults to 1 px.  
 *
 *  This is necessary because a UITableViewCell uses a seperator as part of its height so it will cut off the content.
 *  You should set this to 0 if you don't have cell dividers, or set it to whatever you divider is set too.
 */
@property (nonatomic, assign) CGFloat cellHeightPadding;

/**
 *   This is used to override a static width for a cell.  
 *   A possible use case would be having a cell created for iPhone at 320.0 pts wide work on an iPad with a width of 768.0 pts.
 *   Setting this automatically invalidates the cache.
 *   @warning If you have labels that you want to have a dynamic height you must make sure that the preferredMaxLayoutWidth is correct.
 */
@property (nonatomic, assign) CGFloat overideWidth;
 

/**
 *  Return the height for a table view cell at a particular index path, for a particular object.
 *
 *  @param object    Optional model object which will be used to configure the cell.
 *  @param indexPath Index path of the cell.
 *
 *  @return Height of the cell.
 */
- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath;

/**
 *  Return the height for a table view cell at a particular index path, for a particular object and reuse identifier.
 *
 *  @param object          Optional model object which will be used to configure the cell.
 *  @param indexPath       Index path of the cell.
 *  @param reuseIdentifier Reuse identifier of the cell.
 *
 *  @return Height of the cell.
 */
- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath cellReuseIdentifier:(NSString *)reuseIdentifier;

/**
 *  Return the size for a collection view cell at a particular index path, for a particular object.
 *
 *  @param object    Optional model object which will be used to configure the cell.
 *  @param indexPath Index path of the cell.
 *
 *  @return Size of the cell.
 */
- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath;

/**
 *  Return the size for a collection view cell at a particular index path, for a particular object and reuse identifier.
 *
 *  @param object          Optional model object which will be used to configure the cell.
 *  @param indexPath       Index path of the cell.
 *  @param reuseIdentifier Reuse identifier of the cell.
 *
 *  @return Size of the cell.
 */
- (CGSize)cellSizeForObject:(id)object indexPath:(NSIndexPath *)indexPath cellReuseIdentifier:(NSString *)reuseIdentifier;

@end
