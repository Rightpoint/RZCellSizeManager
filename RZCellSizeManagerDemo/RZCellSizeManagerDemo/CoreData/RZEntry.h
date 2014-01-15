//
//  RZEntry.h
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 1/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RZEntry : NSManagedObject

@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSString * title;

@end
