//
//  KKSPaintingBezier.m
//  MagicPaint
//
//  Created by kukushi on 7/25/14.
//  Copyright (c) 2014 Xing He All rights reserved.
//

#import "KKSPaintingBezier.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"

@interface KKSPaintingBezier()

@property (nonatomic) CGPoint lastLocation;
@property (nonatomic) CGPoint secondTouchLocation;
@property (nonatomic) CGPoint thirdTouchLocation;
@property (nonatomic) NSInteger touchCount;

@end

@implementation KKSPaintingBezier

- (void)recordingBeganWithTouch:(UITouch *)touch {
    ++self.touchCount;
    
    if (self.touchCount == 1) {
        self.firstLocation = [touch locationInView:self.view];
    } else if (self.touchCount == 2) {
        self.secondTouchLocation = [touch locationInView:self.view];
        [self.view needUpdatePaintings];
    } else if (self.touchCount == 3) {
        self.thirdTouchLocation = [touch locationInView:self.view];
        [self.view needUpdatePaintings];
    }
}

- (void)recordingContinueWithTouchMoved:(UITouch *)touch {
    if (self.touchCount == 1) {
        self.lastLocation = [touch locationInView:self.view];
        [self.view needUpdatePaintings];
    }
}

- (void)recordingEndedWithTouch:(UITouch *)touch {
    if (self.touchCount == 3) {
        [super recordingEndedWithTouch:touch];
        self.isDrawingFinished = YES;
    }
}

- (void)drawPath {
    if (self.touchCount == 1 || self.touchCount == 2) {
        self.path = [UIBezierPath bezierPath];
        [self.path moveToPoint:self.firstLocation];
        [self.path addLineToPoint:self.lastLocation];
    }

    if (self.touchCount == 2) {
        [self.path moveToPoint:self.secondTouchLocation];
        [self.path addArcWithCenter:self.secondTouchLocation
                             radius:self.scaledLineWidth / 4.f
                         startAngle:0.f
                           endAngle:360.f * M_PI/180
                          clockwise:YES];
    }
    
    if (self.touchCount == 3) {
        self.path = [UIBezierPath bezierPath];
        [self.path moveToPoint:self.firstLocation];
        [self.path addCurveToPoint:self.lastLocation
                     controlPoint1:self.secondTouchLocation
                     controlPoint2:self.thirdTouchLocation];
    }

    [self setupBezierPath];
    [self.path applyTransform:[self currentTransform]];
    [self.path stroke];

    [self updateSelectionStrokingPath];

    if (self.shouldStrokePath) {
        [self strokePathBounds];
    }
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"lastLocation" : @"lastLocation",
            @"secondTouchLocation" : @"secondTouchLocation",
            @"thirdTouchLocation" : @"thirdTouchLocation",
            @"touchCount" : @"touchCount"};
}

@end
