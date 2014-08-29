//  KKSPointExtend.h
//  Drawing Demo
//
//  Created by kukushi on 3/17/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#ifndef Drawing_Demo_KKSPointExtend_h
#define Drawing_Demo_KKSPointExtend_h

FOUNDATION_EXPORT CGFloat distanceBetweenPoints(CGPoint point1, CGPoint point2);

static inline  __attribute__((pure)) CGPoint middlePoint(CGPoint firstPoint, CGPoint secondPoint) {
    return CGPointMake((firstPoint.x + secondPoint.x) * 0.5,
                       (firstPoint.y + secondPoint.y) * 0.5);
}


FOUNDATION_EXPORT CGFloat degreeWithPoints(CGPoint originPoint,
                                           CGPoint initialPoint,
                                           CGPoint currentPoint);

FOUNDATION_EXPORT CGFloat scaleChangeBetweenPoints(CGPoint originPoint,
                                                   CGPoint basicPoint,
                                                   CGPoint previousPoint,
                                                   CGPoint currentPoint);

static inline CGPoint translationBetweenPoints(CGPoint point1, CGPoint point2) {
    return CGPointMake(point2.x - point1.x,
                       point2.y - point1.y);
}

#endif