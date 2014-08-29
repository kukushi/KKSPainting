//  KKSPointExtend.m
//  Drawing Demo
//
//  Created by kukushi on 3/17/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPointExtend.h"

static const CGFloat eps = 1e-7;

CGFloat distanceBetweenPoints(CGPoint point1, CGPoint point2) {
    CGFloat distance1 = (point1.x - point2.x) * (point1.x - point2.x);
    CGFloat distance2 = (point1.y - point2.y) * (point1.y - point2.y);
    return sqrtf(distance1 + distance2);
}

NSInteger quadrantWithPoint(CGPoint point) {
    NSInteger result;
    if (point.x > 0 - eps) {
        if (point.y > 0 - eps) {
            result = 1;
        }
        else {
            result = 4;
        }
    }
    else {
        if (point.y > 0 - eps) {
            result = 2;
        }
        else {
            result = 3;
        }
    }
    return result;
}

CGFloat scaleChangeBetweenPoints(CGPoint originPoint,
                           CGPoint basicPoint,
                           CGPoint previousPoint,
                           CGPoint currentPoint) {
    
    return (distanceBetweenPoints(originPoint, currentPoint) - distanceBetweenPoints(originPoint, previousPoint)) / distanceBetweenPoints(originPoint, basicPoint);
}

CGFloat degreeWithPoints(CGPoint originPoint,
                                           CGPoint initialPoint,
                                           CGPoint currentPoint) {
    
    CGPoint currentPosition = CGPointMake(currentPoint.x - originPoint.x, currentPoint.y - originPoint.y);
    CGPoint initialPosition = CGPointMake(initialPoint.x - originPoint.x,
                                          initialPoint.y - originPoint.y);
    
    CGFloat distanceOriginToInit = distanceBetweenPoints(CGPointZero, initialPosition);
    CGFloat distanceOriginToCurrent = distanceBetweenPoints(CGPointZero, currentPosition);
    CGFloat distanceInitToCurrent = distanceBetweenPoints(initialPosition, currentPosition);
    
    CGFloat formulaPart1 = (distanceOriginToInit * distanceOriginToInit
                            + distanceOriginToCurrent * distanceOriginToCurrent
                            - distanceInitToCurrent * distanceInitToCurrent);
    CGFloat formulaPart2 = (2 * distanceOriginToInit * distanceOriginToCurrent);
    
    CGFloat angle = acos(formulaPart1 / formulaPart2);
    
    CGFloat factor = sqrt(distanceOriginToInit / distanceOriginToCurrent);
    currentPosition.x *= factor;
    currentPosition.y *= factor;
    
    //    CGPoint remapedInitalPositon = CGPointMake(initialPosition.x - origin.x, initialPosition.y - origin.y);
    //    CGPoint remappedCurrentPosition = CGPointMake(currentPosition.x - origin.x, currentPosition.y - origin.y);
    
    NSInteger quadrant = quadrantWithPoint(initialPosition);
    
    // in the UIKit coordinate system
    if (!((quadrant == 1 && (currentPosition.x < initialPosition.x)) ||
          (quadrant == 2 && (currentPosition.y < initialPosition.y)) ||
          (quadrant == 3 && (currentPosition.x > initialPosition.x)) ||
          (quadrant == 4 && (currentPosition.y > initialPosition.y)))) {
        angle *= -1;
    }
    return angle;
}
