RZCellSizeManager
=================

Dynamic size computation and cacheing for cells.

RZCellSizeManager is an object used to cache and get cell heights for `UICollectionView` cells and `UITableView` cells.  It works especially well when using AutoLayout but can be used anytime you want to cache cell sizes.


Getting Started
===============

Use Cocoapods
------------------
Add the pod to your Podfile:

```
pod 'RZCellSizeManager', '~>1.0.0'
```


Manually
---------

Copy the RZCellSizeManager folder into your project.  All you need is the ```RZCellSizeManager.h``` and ```RZCellSizeManager.m```

Implementation
--------------

To use RZCellSizeManager you first must create an instance to it.

```
@property (strong, nonatomic) RZCellSizeManager* sizeManager;
```
```
self.sizeManager = [[RZCellSizeManager alloc] init];

```

Once we have an instance we can then register different cell classes/nibs.

Depending on what your use case is there are a few different methods to do this (See the in class documentation for more methods):

```
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
           forReuseIdentifier:(NSString *)reuseIdentifier
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock; 
       
- (void)registerCellClassName:(NSString *)cellClass
                 withNibNamed:(NSString *)nibNameOrNil
               forObjectClass:(Class)objectClass
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;
       
```
The first method above will work similar to how your `UITableView` interaction will work.  You give RZCellSizeManager a cell class name, an optional nib name, and a reuseIdentifier.  The last parameter here is a configuration block which you will use to configure your cell given an optional object and an indexPath.

```
self.sizeManager registerCellClassName:NSStringFromClass([TableViewCell class]) withNibNamed:nil forReuseIdentifier:[TableViewCell reuseIdentifier] configurationBlock:^(TableViewCell* cell, id object) {
        [cell setCellData:object];
    }];
```
If you pass in a reuseIdentifier of `nil` it will work fine so long as you only have one cell type.
    
The second approach is to register with an object class.  Based on a paticular object class it will choose the correct cell for you.

```
self.sizeManager registerCellClassName:NSStringFromClass([TableViewCell class]) withNibNamed:nil forObjectClass:[CellData class] configurationBlock:^(TableViewCell *cell, CellData *object) {
        [cell setCellData:object];
    }];
```
Mixing the two different methods will result in unsupported behavior.

In this case we are setting an object on the cell which will set two different labels.  Both of these labels are configured with autolayout so they will adjust their size depending on the content of them.  Here is an example of the  ```setCellData:``` method

```
// Using AutoLayout
- (void)setCellData:(CellData *)cellData
{
    self.titleLabel.text = cellData.title;
    self.descriptionLabel.text = cellData.subTitle;
}
```

Then just implement the UITableViewDelegate Method and ask the sizeManager for the size at your cells index path.

For the ReuseIdentifier approach we just pass in an additional parameter as the ReuseIdentifier for cell that we want to use to get our height based off the indexPath.

	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
	{
 	   	// Retrieve our object to give to our size manager.
 	   	id object = [self.dataArray objectAtIndex:indexPath.row];

       	return [self.sizeManager cellHeightForObject:object indexPath:indexPath cellReuseIdentifier:[TableViewCell reuseIdentifier]];	
    }
        
For the object class approach, RZCellSizeManager will figure out the correct cell to use based on the class of the provided object so this call is even simpiler.


	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
	{
 	   // Retrieve our object to give to our size manager.
 	   id object = [self.dataArray objectAtIndex:indexPath.row];

		return [self.sizeManager cellHeightForObject:object indexPath:indexPath];
	}

And your done.  All of your cell's sizes will be cached so that any future calls will be quick.


Invalidating Sizes
------------------

if you are using RZCellSizeManager and you data changes you will need to invalidate it's cache so that it can compute the new heights.  This can be done by giving it a specific index path, or you can just invalidate the entire cache.

```
	- (void)invalidateCellHeightCache;
	- (void)invalidateCellHeightAtIndexPath:(NSIndexPath *)indexPath;
	- (void)invalidateCellHeightsAtIndexPaths:(NSArray *)indexPaths;


```

Next Steps
==========

Check out the demo project for a simple example of how to use the ```RZCellSizeManager``` and feel free to add issue's and pull requests if you have good ideas for future enhancements.

Also there is a link to a blog post about `RZCellSizeManager` here: http://www.raizlabs.com/dev/2014/02/leveraging-auto-layout-for-dynamic-cell-heights
