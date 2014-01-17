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
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;

@end

@implementation RZSecondTableViewCell

+ (NSString *)reuseIdentifier
{
    static NSString* s_reuseIdentifier = nil;
    if (!s_reuseIdentifier)
    {
        s_reuseIdentifier = NSStringFromClass([RZSecondTableViewCell class]);
    }
    return s_reuseIdentifier;
}

+ (UINib *)reuseNib
{
    UINib* nib = [UINib nibWithNibName:[RZSecondTableViewCell reuseIdentifier] bundle:nil];
    return nib;
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
