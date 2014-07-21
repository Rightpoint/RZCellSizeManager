//
//  NSString+RandomString.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/7/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "NSString+RandomString.h"

@implementation NSString (RandomString)

+ (NSString *)randomStringOfMaxLength:(int)maxLength
{
    static NSString *characters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    int length = arc4random_uniform(maxLength);
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%c", [characters characterAtIndex: arc4random_uniform((int)[characters length])]];
    }
    return randomString;
}


@end
