//
//  FTEPaintingStoreModel.m
//  MagicPaint
//
//  Created by kukushi on 8/10/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingModel.h"
#import "KKSPaintingBase.h"

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
    UIGraphicsBeginImageContext(self.originalContentSize);
    [self.backgroundImage drawAtPoint:CGPointZero];
    for (KKSPaintingBase *painting in self.usedPaintings) {
        CGFloat zoomScale = painting.zoomScale;
        painting.zoomScale = 1.f;
        [painting drawPath];
        painting.zoomScale = zoomScale;
    }
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
