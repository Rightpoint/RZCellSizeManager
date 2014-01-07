//
//  RZCellSizeManager+RZCollectionList.h
//  Raizlabs
//
//  Created by Alex Rouse on 12/12/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZCellSizeManager.h"
#import "RZCollectionList.h"

@interface RZCellSizeManager (RZCollectionList)

- (void)rz_autoInvalidateWithCollectionList:(id<RZCollectionList>)collectionList;

@end
