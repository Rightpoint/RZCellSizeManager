//
//  RZSecondTableViewCell.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/17/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZSecondTableViewCell.h"
#import "RZCellData.h"

@interface RZSecondTableViewCell ()

@property (weak, nonatomic) UILabel *cellLabel;

@end

@implementation RZSecondTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( self ) {
        UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 20, 20)];
        cellLabel.translatesAutoresizingMaskIntoConstraints = NO;
        cellLabel.numberOfLines = 0;
        cellLabel.preferredMaxLayoutWidth = self.bounds.size.width - 40.0;
        cellLabel.backgroundColor = [UIColor lightGrayColor];
        cellLabel.font = [UIFont fontWithName:@"AvenirNext" size:24];
        [self.contentView addSubview:cellLabel];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[label]-20-|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:@{ @"label": cellLabel }]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]-10-|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:@{ @"label": cellLabel }]];
        _cellLabel = cellLabel;
    }
    return self;
}

+ (NSString *)reuseIdentifier
{
    static NSString* s_reuseIdentifier = nil;
    if (!s_reuseIdentifier)
    {
        s_reuseIdentifier = NSStringFromClass([RZSecondTableViewCell class]);
    }
    return s_reuseIdentifier;
}

+ (CGFloat)estimatedCellHeight
{
    return 80.0f;
}

- (void)setOtherCellData:(RZOtherCellData *)otherCellData
{
    self.cellLabel.text = otherCellData.title;
}

@end
