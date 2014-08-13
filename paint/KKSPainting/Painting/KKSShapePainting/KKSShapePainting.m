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

@end

