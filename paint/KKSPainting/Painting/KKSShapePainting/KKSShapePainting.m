//
//  KKSShapepainting.m
//  Drawing Demo
//
//  Created by kukushi on 3/4/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSShapePainting.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"
#import "KKSLog.h"

#pragma mark - KKSShapePainting

@interface KKSShapePainting ()

@end


@implementation KKSShapePainting

#pragma mark - Override

- (void)recordingBeganWithTouch:(UITouch *)touch {
    self.firstLocation = [touch locationInView:self.view];
}

- (void)recordingContinueWithTouchMoved:(UITouch *)touch {
    self.lastLocation = [touch locationInView:self.view];
    [self.view needUpdatePaintings];
}

#pragma mark - Helper

- (CGRect)rectToDraw {
    return CGRectMake(self.firstLocation.x,
                      self.firstLocation.y,
                      self.lastLocation.x - self.firstLocation.x,
                      self.lastLocation.y - self.firstLocation.y);
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"firstLocation": @"firstLocation",
             @"lastLocation": @"lastLocation"
             };
}

/*
#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    KKSShapePainting *painting = [super copyWithZone:zone];
    if (painting) {
        painting->_firstLocation = _firstLocation;
        painting->_lastLocation = _lastLocation;
    }
    return painting;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeCGPoint:self.firstLocation forKey:@"firstLocation"];
    [encoder encodeCGPoint:self.lastLocation forKey:@"lastLocation"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _firstLocation = [decoder decodeCGPointForKey:@"firstLocation"];
        _lastLocation = [decoder decodeCGPointForKey:@"lastLocation"];
    }
    return self;
}
 */


@end

