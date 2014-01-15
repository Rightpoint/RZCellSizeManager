//
//  RZTableViewCell.h
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 12/20/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RZCellData;
@class RZEntry;
@interface RZTableViewCell : UITableViewCell

@property (nonatomic, strong) RZCellData* cellData;
@property (nonatomic, strong) RZEntry* cellEntry;
+ (NSString *)reuseIdentifier;

+ (UINib *)reuseNib;

+ (CGFloat)estimatedCellHeight;

@end
