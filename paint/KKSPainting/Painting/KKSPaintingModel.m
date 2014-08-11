//
//  FTEPaintingStoreModel.m
//  MagicPaint
//
//  Created by kukushi on 8/10/14.
//  Copyright (c) 2014 Robin W. All rights reserved.
//

#import "KKSPaintingModel.h"

@interface KKSPaintingModel ()


@end

@implementation KKSPaintingModel

- (id)init {
    if (self = [super init]) {
        _usedPaintings = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"name": @"name",
             @"createdDate": @"date",
             @"backgroundImage": @"backgroundImage",
             @"cachedImage": @"cachedImage",
             @"usedPaintings": @"usedPaintings",
             @"originalContentSize": @"originalContentSize"
             };
}

@end
