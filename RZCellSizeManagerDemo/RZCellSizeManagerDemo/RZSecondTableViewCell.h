//
//  RZSecondTableViewCell.h
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/17/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RZOtherCellData;

@interface RZSecondTableViewCell : UITableViewCell

@property (nonatomic, strong) RZOtherCellData* otherCellData;

+ (NSString *)reuseIdentifier;

+ (UINib *)reuseNib;

+ (CGFloat)estimatedCellHeight;

@end
