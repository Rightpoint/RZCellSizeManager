RZCellSizeManager
=================

Dynamic size computation and cacheing for cells.

RZCellSizeManager is an object used to cache and get cell heights for UICollectionView cells and UITableView cells.  It works expecially well when using AutoLayout but can be used anytime you want to cache cell sizes.


Getting Started
===============

Using RZCellSizeManager is easy.  All you have to do is create an instance of the size manager using one of the initializers and set up a configuration block.  A configuration block is what will happen to the cell to adjust its height.

```
self.sizeManager = [[RZCellSizeManager alloc] initWithCellClassName:@"RZTableViewCell" configurationBlock:^(RZTableViewCell* cell, id object) {
    [cell setCellData:object];
}];
```

In this case we are setting an object on the cell which will set two different labels.  Both of these labels are configured with autolayout so they will adjust their size depending on the content of them.  Here is an example of the  ```setCellData:``` method

```
// Using AutoLayout
- (void)setCellData:(RZCellData *)cellData
{
    self.titleLabel.text = cellData.title;
    self.descriptionLabel.text = cellData.subTitle;
    _cellData = cellData;
}
```

Then just implement the UITableViewDelegate Method and ask the sizeManager for the size at your cells index path.

```
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve our object to give to our size manager.
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    // Since we are using a tableView we are using the cellHeightForObject:indexPath: method.
    //  It uses the indexPath as the key for cacheing so it is important to pass in the correct one.
    return [self.sizeManager cellHeightForObject:object indexPath:indexPath];
}
```
And your done.  All of your cell's sizes will be cached so that any future calls will be quick.


Invalidating Sizes
==================

if you are using RZCellSizeManager and you data changes you will need to invalidate it's cache so that it can compute the new heights.  This can be done by giving it a specific index path, or you can just invalidate the entire cache.
```
[self.sizeManager invalidateCellHeightCache];
```


