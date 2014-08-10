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
@property (nonatomic) CGPoint currentLocation;

@property (nonatomic, readwrite) __attribute__((NSObject)) CGMutablePathRef tempPath;

@end


@implementation KKSPaintingPen

#pragma mark - Init

- (id)initWithView:(UIScrollView *)view {
    self = [super initWithView:view];
    if (self) {
        self.tempPath = CGPathCreateMutable();
    }
    return self;
}

- (void)recordingBeganWithTouch:(UITouch *)touch {
    CGPoint currentLocation = [touch locationInView:self.view];
    self.currentLocation = currentLocation;
    self.previousLocation = [touch previousLocationInView:self.view];
}

- (void)recordingContinueWithTouchMoved:(UITouch *)touch {
    
    CGPoint morePreviousLocation = self.previousLocation;
    self.previousLocation = [touch previousLocationInView:self.view];
    self.currentLocation = [touch locationInView:self.view];
    
    CGRect drawingBounds = [self addPathWithPreviousPoint:morePreviousLocation
                                             controlPoint:self.previousLocation
                                             currentPoint:self.currentLocation];
    
    CGFloat bounceWidth = [self scaledLineWidth];
    drawingBounds.origin.x -= bounceWidth;
    drawingBounds.origin.y -= bounceWidth;
    drawingBounds.size.height += bounceWidth * 2;
    drawingBounds.size.width += bounceWidth * 2;
    
    [self.view setNeedsDisplayInRect:drawingBounds];
}

#pragma mark - Helper

- (CGRect)addPathWithPreviousPoint:(CGPoint)previousPoint
                      controlPoint:(CGPoint)controlPoint
                      currentPoint:(CGPoint)currentPoint {
    
    CGPoint middlePoint1 = middlePoint(previousPoint, controlPoint);
    CGPoint middlePoint2 = middlePoint(controlPoint, currentPoint);
    
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, middlePoint1.x, middlePoint1.y);
    
    CGPathAddQuadCurveToPoint(subpath, NULL, controlPoint.x, controlPoint.y, middlePoint2.x, middlePoint2.y);
    
    CGRect bounds = CGPathGetBoundingBox(subpath);
    
    CGPathAddPath(self.tempPath, NULL, subpath);
    CGPathRelease(subpath);
    
    return bounds;
}

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
    NSValue *tempPathValue = [NSValue valueWithPointer:self.tempPath];
    [encoder encodeObject:tempPathValue forKey:@"tempPath"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _previousLocation = [decoder decodeCGPointForKey:@"previousLocation"];
        _currentLocation = [decoder decodeCGPointForKey:@"currentLocation"];
        NSValue *tempPathValue = [decoder decodeObjectForKey:@"tempPath"];
        _tempPath = [tempPathValue pointerValue];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawPath {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    
    [self setupContext:context];
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGAffineTransform transform = [self currentTransform];
    CGPathRef destinationPath = CGPathCreateCopyByTransformingPath(self.tempPath, &transform);
    
    CGContextAddPath(context, destinationPath);
    
    self.path = destinationPath;
    
    CGContextStrokePath(context);
    
    if (self.shouldStrokePath) {
        [self strokeBoundWithContext:context];
        self.strokingPath = CGPathCreateCopyByStrokingPath(self.path,
                                                           NULL,
                                                           self.scaledLineWidth + 3.f,
                                                           kCGLineCapRound,
                                                           kCGLineJoinRound,
                                                           0.f);
    }
}



@end