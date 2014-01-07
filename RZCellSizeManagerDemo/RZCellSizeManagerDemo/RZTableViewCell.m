//
//  RZTableViewCell.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 12/20/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZTableViewCell.h"

#import "RZCellData.h"

@interface RZTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation RZTableViewCell

+ (NSString *)reuseIdentifier
{
    static NSString* s_reuseIdentifier = nil;
    if (!s_reuseIdentifier)
    {
        s_reuseIdentifier = NSStringFromClass([RZTableViewCell class]);
    }
    return s_reuseIdentifier;
}

+ (UINib *)reuseNib
{
    UINib* nib = [UINib nibWithNibName:[RZTableViewCell reuseIdentifier] bundle:nil];
    return nib;
}

+ (CGFloat)estimatedCellHeight
{
    return 120.0f;
}

- (void)setCellData:(RZCellData *)cellData
{
    self.titleLabel.text = cellData.title;
    self.descriptionLabel.text = cellData.subTitle;
    _cellData = cellData;
}

@end
