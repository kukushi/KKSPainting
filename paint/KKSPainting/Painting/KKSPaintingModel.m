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

#pragma mark - Init

- (id)init {
    if (self = [super init]) {
        _usedPaintings = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Manage Used Paintings

- (void)removePainting:(id)painting {
    NSMutableArray *mutableUsedPaintings = [NSMutableArray arrayWithArray:self.usedPaintings];
    [mutableUsedPaintings removeObject:painting];
    self.usedPaintings = [mutableUsedPaintings copy];
}

- (void)addPainting:(id)painting {
    NSMutableArray *mutableUsedPaintings = [NSMutableArray arrayWithArray:self.usedPaintings];
    [mutableUsedPaintings addObject:painting];
    self.usedPaintings = [mutableUsedPaintings copy];
}

- (void)removeAllPaintings {
    self.usedPaintings = [[NSMutableArray alloc] init];
}

- (UIImage *)previewImage {
    UIGraphicsBeginImageContext(self.cachedImage.size);
    [self.backgroundImage drawAtPoint:CGPointZero];
    [self.cachedImage drawAtPoint:CGPointZero];
    UIImage *previewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return previewImage;
}

#pragma mark - Mantle

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
