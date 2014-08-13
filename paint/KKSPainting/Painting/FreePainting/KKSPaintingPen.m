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
    // previousPoint = currentPoint;

/*
    CGPoint morePreviousLocation = self.previousLocation;
    self.previousLocation = [touch previousLocationInView:self.view];
    self.currentLocation = [touch locationInView:self.view];
    
    CGRect drawingBounds = [self addPathWithPreviousPoint:morePreviousLocation
                                             controlPoint:self.previousLocation
                                             currentPoint:self.currentLocation];
                                             */
    CGRect drawingBounds = self.path.bounds;
    CGFloat bounceWidth = [self scaledLineWidth];
    drawingBounds.origin.x -= bounceWidth;
    drawingBounds.origin.y -= bounceWidth;
    drawingBounds.size.height += bounceWidth * 2;
    drawingBounds.size.width += bounceWidth * 2;
    
    [self.view needUpdatePaintings];
}

#pragma mark - Helper

- (CGRect)addPathWithPreviousPoint:(CGPoint)previousPoint
                      controlPoint:(CGPoint)controlPoint
                      currentPoint:(CGPoint)currentPoint {
    
    CGPoint middlePoint1 = middlePoint(previousPoint, controlPoint);
    CGPoint middlePoint2 = middlePoint(controlPoint, currentPoint);

    UIBezierPath *subPath = [UIBezierPath bezierPath];
    [subPath moveToPoint:middlePoint1];
    [subPath addQuadCurveToPoint:controlPoint controlPoint:middlePoint2];
    
    CGRect bounds = subPath.bounds;
    [self.path appendPath:subPath];



    return bounds;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"path": @"path"};
}

/*
- (id)copyWithZone:(NSZone *)zone {
    KKSPaintingPen *painting = [super copyWithZone:zone];
    if (painting) {
        painting->_previousLocation = _previousLocation;
        painting->_currentLocation = _currentLocation;
        painting->_tempPath = CGPathCreateMutableCopy(CGPathRetain(_tempPath));
    }
    return painting;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeCGPoint:self.previousLocation forKey:@"previousLocation"];
    [encoder encodeCGPoint:self.currentLocation forKey:@"currentLocation"];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:self.tempPath];
    [encoder encodeObject:path forKey:@"tempPath"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _previousLocation = [decoder decodeCGPointForKey:@"previousLocation"];
        _currentLocation = [decoder decodeCGPointForKey:@"currentLocation"];
        
        UIBezierPath *path = [decoder decodeObjectForKey:@"tempPath"];
        _tempPath = CGPathCreateMutableCopy(path.CGPath);
    }
    return self;
}
 */

#pragma mark - Drawing

- (void)drawPath {

    [self setupBezierPath];

    //
    CGAffineTransform transform = [self currentTransform];
    UIBezierPath *transformedPath = [self.path copy];
    [transformedPath applyTransform:transform];
    [transformedPath stroke];

    CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(self.path.CGPath,
            &transform,
            self.scaledLineWidth + 3.f,
            kCGLineCapRound,
            kCGLineJoinRound,
            0.f);

    self.strokingPath = [UIBezierPath bezierPathWithCGPath:strokingPath];

    if (self.shouldStrokePath) {
        [self strokeBoundWithBounds:transformedPath.bounds];
    }
}



@end