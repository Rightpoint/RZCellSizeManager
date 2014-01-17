//
//  RZCellData.h
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/7/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZCellData : NSObject

@property (strong, readonly, nonatomic) NSString* title;
@property (strong, readonly, nonatomic) NSString* subTitle;

+ (instancetype)cellDataWithTitle:(NSString *)title subTitle:(NSString *)subTitle;

@end

@interface RZOtherCellData : NSObject

@property (strong, readonly, nonatomic) NSString* title;

+ (instancetype)otherCellDataWithTitle:(NSString *)title;

@end