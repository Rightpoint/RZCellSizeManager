//
//  RZCellData.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/7/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZCellData.h"

@interface RZCellData ()
@property (strong, readwrite, nonatomic) NSString* title;
@property (strong, readwrite, nonatomic) NSString* subTitle;
@end

@implementation RZCellData

+ (instancetype)cellDataWithTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    RZCellData* data = [RZCellData new];
    data.title = title;
    data.subTitle = subTitle;
    return data;
}
@end
