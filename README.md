RZCellSizeManager
=================

Dynamic size computation and cacheing for cells.

RZCellSizeManager is an object used to cache and get cell heights for `UICollectionView` cells and `UITableView` cells.  It works especially well when using AutoLayout but can be used anytime you want to cache cell sizes.


Getting Started
===============


Copy the RZCellSizeManager folder into your project.  All you need is the ```RZCellSizeManager.h``` and ```RZCellSizeManager.m```

Implementation
--------------

There are two different approaches to using `RZCellSizeManager`.  The first is to use a ReuseIdentifier to register your cell class.  This is a familiar approach since it is how we interact normally with a UITableView or a UICollectionView

```
@property (strong, nonatomic) RZCellSizeManager* sizeManager;
```

```
self.sizeManager = [[RZCellSizeManager alloc] initWithCellClassName:@"TableViewCell" cellReuseIdentifier:[TableViewCell reuseIdentifier] configurationBlock:^(TableViewCell* cell, id object) {
        [cell setCellData:object];
    }];
```

If you pass in a reuseIdentifier of `nil` it will work fine so long as you only have one cell type.
    
The second approach is to register with an object class.

	self.sizeManager = [[RZCellSizeManager alloc] initWithCellClassName:@"TableViewCell" objectClass:[CellData class] configurationBlock:^(TableViewCell* cell, id object) {
        [cell setCellData:object];
    }];

Either method supports the ability to register additional cell classes, either for additional ReuseIdentifiers or object classes.
	
	- (void)registerCellClassName:(NSString *)cellClass
               forObjectClass:(Class)objectClass
           configurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;
           
	- (void)registerCellClassName:(NSString *)cellClass
           forReuseIdentifier:(NSString *)reuseIdentifier
       withConfigurationBlock:(RZCellSizeManagerConfigBlock)configurationBlock;
    
Mixing the two different methods will result in unsupported behavior.

In this case we are setting an object on the cell which will set two different labels.  Both of these labels are configured with autolayout so they will adjust their size depending on the content of them.  Here is an example of the  ```setCellData:``` method

```
// Using AutoLayout
- (void)setCellData:(RZCellData *)cellData
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

