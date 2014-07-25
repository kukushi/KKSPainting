//
//  KKSPaintingBezier.m
//  MagicPaint
//
//  Created by kukushi on 7/25/14.
//  Copyright (c) 2014 Robin W. All rights reserved.
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
        [self.view setNeedsDisplay];
    } else if (self.touchCount == 3) {
        self.thirdTouchLocation = [touch locationInView:self.view];
        [self.view setNeedsDisplay];
    }
    
}

- (void)recordingContinueWithTouchMoved:(UITouch *)touch {
    if (self.touchCount == 1) {
        self.lastLocation = [touch locationInView:self.view];
        [self.view setNeedsDisplay];
    }
}

- (UIImage *)recordingEndedWithTouch:(UITouch *)touch cachedImage:(UIImage *)cachedImage {
    [self.longPressFinishTimer invalidate];
    if (self.touchCount == 3) {
        self.isDrawingFinished = YES;
        cachedImage = [super recordingEndedWithTouch:touch cachedImage:cachedImage];
    }
    return cachedImage;
}

- (void)drawPath {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self setupContext:context];
    
    CGContextBeginPath(context);
    
    if (self.touchCount == 1 || self.touchCount == 2) {
        CGContextMoveToPoint(context, self.firstLocation.x, self.firstLocation.y);
        CGContextAddLineToPoint(context, self.lastLocation.x, self.lastLocation.y);
    }
    
    if (self.touchCount == 2) {
        CGContextMoveToPoint(context, self.secondTouchLocation.x, self.secondTouchLocation.y);
        CGContextAddArc(context,
                        self.secondTouchLocation.x,
                        self.secondTouchLocation.y,
                        self.scaledLineWidth / 4.f,
                        0.f * M_PI/180,
                        360.f * M_PI/180,
                        1);
    }
    
    if (self.touchCount == 3) {
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGAffineTransform transform = [self currentTransform];
        CGPathMoveToPoint(path, &transform, self.firstLocation.x, self.firstLocation.y);
        CGPathAddCurveToPoint(path,
                              &transform,
                              self.secondTouchLocation.x,
                              self.secondTouchLocation.y,
                              self.thirdTouchLocation.x,
                              self.thirdTouchLocation.y,
                              self.lastLocation.x,
                              self.lastLocation.y);
        CGContextAddPath(context, path);
        self.path = path;
    }
    
    CGContextStrokePath(context);
    
    if (self.shouldStrokePath) {
        self.strokingPath = [self strokePathWithContext:context];
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    KKSPaintingBezier *painting = [super copyWithZone:zone];
    if (painting) {
        painting->_lastLocation = self.lastLocation;
        painting->_secondTouchLocation = self.secondTouchLocation;
        painting->_thirdTouchLocation = self.thirdTouchLocation;
        painting->_touchCount = self.touchCount;
    }
    return painting;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeCGPoint:self.lastLocation forKey:@"lastLocation"];
    [encoder encodeCGPoint:self.secondTouchLocation forKey:@"secondTouchLocation"];
    [encoder encodeCGPoint:self.thirdTouchLocation forKey:@"thirdTouchLocation"];
    [encoder encodeInteger:self.touchCount forKey:@"touchCount"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _lastLocation = [decoder decodeCGPointForKey:@"lastLocation"];
        _secondTouchLocation = [decoder decodeCGPointForKey:@"secondTouchLocation"];
        _thirdTouchLocation = [decoder decodeCGPointForKey:@"thirdTouchLocation"];
        _touchCount = [decoder decodeIntegerForKey:@"touchCount"];
    }
    return self;
}

@end
