//
//  KKSFreePainting.m
//  Drawing Demo
//
//  Created by kukushi on 3/3/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingPen.h"
#import "KKSPointExtend.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"

#pragma mark - KKSFreePainting

@interface KKSPaintingPen ()

@property (nonatomic) CGPoint previousLocation;
@property (nonatomic, strong) UIBezierPath *originalPath;

@end


@implementation KKSPaintingPen

#pragma mark - Touch

- (void)recordingBeganWithTouch:(UITouch *)touch {
    CGPoint currentLocation = [touch locationInView:self.view];
    [self.path moveToPoint:currentLocation];
    self.previousLocation = currentLocation;
}

- (void)recordingContinueWithTouchMoved:(UITouch *)touch {
    CGPoint currentLocation = [touch locationInView:self.view];
    CGPoint midPoint = middlePoint(self.previousLocation, currentLocation);

    [self.path addQuadCurveToPoint:midPoint controlPoint:self.previousLocation];

    self.previousLocation = [touch locationInView:self.view];
    
    CGRect drawingBounds = self.path.bounds;
    CGFloat bounceWidth = [self scaledLineWidth];
    drawingBounds.origin.x -= bounceWidth;
    drawingBounds.origin.y -= bounceWidth;
    drawingBounds.size.height += bounceWidth * 2;
    drawingBounds.size.width += bounceWidth * 2;
    
    [self.view needUpdatePaintingsInRect:drawingBounds];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"path": @"path"};
}

#pragma mark - Drawing

- (void)drawPath {
    [self setupBezierPath];
    
    CGAffineTransform transform = [self currentTransform];
    UIBezierPath *transformedPath = [self.path copy];
    [transformedPath applyTransform:transform];
    [transformedPath stroke];

    CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(self.path.CGPath,
            &transform,
            self.scaledLineWidth + 12.f,
            kCGLineCapRound,
            kCGLineJoinRound,
            0.f);

    self.strokingPath = [UIBezierPath bezierPathWithCGPath:strokingPath];

    if (self.shouldStrokePath) {
        [self strokeBoundWithBounds:transformedPath.bounds];
    }
}



@end