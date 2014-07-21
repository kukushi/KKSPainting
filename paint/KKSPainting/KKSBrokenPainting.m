//
//  KKSBrokenPainting.m
//  Drawing Demo
//
//  Created by kukushi on 3/5/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSBrokenPainting.h"
#import "KKSPointExtend.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"
#import "NSMutableArray+KKSValueSupport.h"

CGFloat const kAutoEndTime = 1.2f;
NSTimeInterval const kLongPressEndTime = 0.6f;

#pragma mark - KKSBrokenPainting

@interface KKSBrokenPainting() <NSCoding>

@property (nonatomic) BOOL isFirstTap;
@property (nonatomic) BOOL isBeforeSecondTap;
@property (nonatomic) CGPoint firstLocation;
@property (nonatomic) CGPoint previousLocation;

@property (nonatomic) CGFloat previousTimeStamp;

@property (nonatomic, strong) NSTimer *autoEndTimer;
@property (nonatomic, strong) NSTimer *longPressFinishTimer;

@end

@implementation KKSBrokenPainting

#pragma mark - Init

- (id)initWithView:(UIScrollView *)view {
    self = [super initWithView:view];
    if (self) {
        self.isDrawingFinished = NO;
        _isFirstTap = YES;
        _isBeforeSecondTap = YES;
    }
    return self;
}

#pragma mark -

- (void)recordingBeganWithTouch:(UITouch *)touch {
    self.previousTimeStamp = touch.timestamp;
    
    if ([self.autoEndTimer isValid]) {
        [self.autoEndTimer invalidate];
    }
    
    if ([self.delegate respondsToSelector:@selector(drawingWillEndAutomatically)]) {
        self.autoEndTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoEndTime
                                                         target:self.delegate
                                                              selector:@selector(drawingWillEndAutomatically)
                                                       userInfo:nil
                                                        repeats:NO];
    }
    
    if (self.delegate) {
        self.longPressFinishTimer = [NSTimer scheduledTimerWithTimeInterval:kLongPressEndTime
                                                                     target:self
                                                                   selector:@selector(drawingWillEndNormally)
                                                                   userInfo:nil
                                                                    repeats:NO];
    }
    
    if (self.isFirstTap) {
        self.isFirstTap = NO;
        self.firstLocation = [touch locationInView:self.view];
    } else {
        self.isBeforeSecondTap = NO;
    }
}

- (void)drawingWillEndNormally {
    [self.autoEndTimer invalidate];
     if ([self.delegate respondsToSelector:@selector(drawingDidEndNormally)]) {
         [self.delegate drawingDidEndNormally];
     }
}

- (BOOL)isLongTapWithTouch:(UITouch *)touch {
    if (self.previousTimeStamp == 0) {
        return NO;
    }
    return touch.timestamp - self.previousTimeStamp > 0.4f;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    KKSBrokenPainting *painting = [super copyWithZone:zone];
    if (painting) {
        painting->_isFirstTap = self.isFirstTap;
        painting->_isBeforeSecondTap = self.isBeforeSecondTap;
        painting->_firstLocation = self.firstLocation;
        painting->_previousLocation = self.previousLocation;
        painting->_previousTimeStamp = self.previousTimeStamp;
    }
    return painting;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _isFirstTap = [decoder decodeBoolForKey:@"isFirstTap"];
        _isBeforeSecondTap = [decoder decodeBoolForKey:@"isBeforeSecondTap"];
        _firstLocation = [decoder decodeCGPointForKey:@"firstLocation"];
        _previousLocation = [decoder decodeCGPointForKey:@"previousLocation"];
        _previousTimeStamp = [decoder decodeFloatForKey:@"previousTimeStamp"];
        _autoEndTimer = [decoder decodeObjectForKey:@"autoEndTimer"];
        _longPressFinishTimer = [decoder decodeObjectForKey:@"longPressFinishTimer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.isFirstTap forKey:@"isFirstTap"];
    [encoder encodeBool:self.isBeforeSecondTap forKey:@"isBeforeSecondTap"];
    [encoder encodeCGPoint:self.firstLocation forKey:@"firstLocation"];
    [encoder encodeCGPoint:self.previousLocation forKey:@"previousLocation"];
    [encoder encodeFloat:self.previousTimeStamp forKey:@"previousTimeStamp"];
    if (self.autoEndTimer) {
        [encoder encodeObject:self.autoEndTimer forKey:@"autoEndTimer"];
    }
    if (self.longPressFinishTimer) {
        [encoder encodeObject:self.longPressFinishTimer forKey:@"longPressFinishTimer"];
    }
}

@end



#pragma mark - KKSPaintingSegments

@interface KKSPaintingSegments()

@property (nonatomic, strong) NSMutableArray *points;

@end

@implementation KKSPaintingSegments

#pragma mark - Init

- (id)initWithView:(UIScrollView *)view {
    self = [super initWithView:view];
    if (self) {
        _points = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Override Touches

- (void)recordingBeganWithTouch:(UITouch *)touch {
    
    CGPoint currentLocation = [touch locationInView:self.view];
    
    [super recordingBeganWithTouch:touch];
    
    [self.points kks_addPoint:currentLocation];
    
    self.previousLocation = currentLocation;
    
    [self.view setNeedsDisplay];
}

- (void)recordingContinueWithTouchMoved:(UITouch *)touch {
    // do nothing
}

- (UIImage *)recordingEndedWithTouch:(UITouch *)touch cachedImage:(UIImage *)cachedImage {
    [self.longPressFinishTimer invalidate];
    
    if ([self isLongTapWithTouch:touch]) {
        // Drawing End
        self.isDrawingFinished = YES;
        cachedImage = [super recordingEndedWithTouch:touch cachedImage:cachedImage];
    }
    
    return cachedImage;
}

- (UIImage *)endDrawingWithCacheImage:(UIImage *)cachedImage {
    self.isDrawingFinished = YES;
    cachedImage = [super recordingEndedWithTouch:nil
                                     cachedImage:cachedImage];
    return cachedImage;
}

#pragma mark - Helper


- (void)drawPath {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    [self setupContext:context];
    
    if (self.isBeforeSecondTap) {
        CGContextAddArc(context,
                        self.firstLocation.x,
                        self.firstLocation.y,
                        self.scaledLineWidth / 4.f,
                        0.f * M_PI/180,
                        360.f * M_PI/180,
                        1);
    } else {
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGAffineTransform transform = [self currentTransform];
        CGPoint points[200];
        NSInteger pointsCount = [self.points kks_cArrayWithCGPoint:points];
        CGPathAddLines(path, &transform, points, pointsCount);
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
    KKSPaintingSegments *painting = [super copyWithZone:zone];
    if (painting) {
        painting->_points = [self.points copy];
    }
    return painting;
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _points = [decoder decodeObjectForKey:@"points"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    if (self.points) {
        [encoder encodeObject:self.points forKey:@"points"];
    }
}

@end


#pragma mark - KKSPaintingBezier

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


#pragma mark - KKSPaintingPolygon

@interface KKSPaintingPolygon ()

@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic) BOOL isLastDrawing;

@end

@implementation KKSPaintingPolygon

#pragma mark - Init

- (id)initWithView:(UIScrollView *)view {
    self = [super initWithView:view];
    if (self) {
        _points = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Touches

- (void)recordingBeganWithTouch:(UITouch *)touch {
    
    CGPoint currentLocation = [touch locationInView:self.view];
    
    if ([self isNearStartLocation:touch]) {
        self.isDrawingFinished = YES;
    } else {
        [super recordingBeganWithTouch:touch];
        [self.points kks_addPoint:currentLocation];
    }
    
    [self.view setNeedsDisplay];
}

- (UIImage *)endDrawingWithCacheImage:(UIImage *)cachedImage {
    self.isDrawingFinished = YES;
    [self.view setNeedsDisplay];
    UIImage *image = [super recordingEndedWithTouch:nil cachedImage:cachedImage];
    return image;
}

- (UIImage *)recordingEndedWithTouch:(UITouch *)touch cachedImage:(UIImage *)cachedImage {
    [self.longPressFinishTimer invalidate];
    
    UIImage *image;
    if ([self isLongTapWithTouch:touch] || self.isDrawingFinished) {
        self.isDrawingFinished = YES;
        [self.autoEndTimer invalidate];
        image = [super recordingEndedWithTouch:touch cachedImage:cachedImage];
    }
    else {
        image = cachedImage;
    }
    
    return image;
}

#pragma mark - Helper

- (BOOL)isNearStartLocation:(UITouch *)touch {
    if (CGPointEqualToPoint(self.firstLocation, CGPointMake(0.f, 0.f))) {
        return NO;
    }
    return distanceBetweenPoints(self.firstLocation, [touch locationInView:self.view]) < 2 * self.scaledLineWidth;
}

- (void)drawPath {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    [self setupContext:context];
    
    if (self.isBeforeSecondTap) {
        CGContextAddArc(context,
                        self.firstLocation.x,
                        self.firstLocation.y,
                        self.scaledLineWidth / 4.f,
                        0.f * M_PI/180,
                        360.f * M_PI/180,
                        1);
        CGContextStrokePath(context);
    } else if (!self.isDrawingFinished) {
        CGAffineTransform transform = [self currentTransform];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint points[200];
        NSInteger pointsCount = [self.points kks_cArrayWithCGPoint:points];
        CGPathAddLines(path, &transform, points, pointsCount);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
    } else {
        CGMutablePathRef path = CGPathCreateMutable();
        CGAffineTransform transform = [self currentTransform];
        CGPoint points[200];
        NSInteger pointsCount = [self.points kks_cArrayWithCGPoint:points];
        CGPathAddLines(path, &transform, points, pointsCount);
        CGPathCloseSubpath(path);
        
        CGContextAddPath(context, path);
        
        self.path = path;
        
        if (self.shouldFill) {
            CGContextSetFillColorWithColor(context, self.fillColor);
            CGContextDrawPath(context, kCGPathFillStroke);
        } else {
            CGContextStrokePath(context);
        }
        
        if (self.shouldStrokePath) {
            self.strokingPath = [self strokePathWithContext:context];
        }
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    KKSPaintingPolygon *painting = [super copyWithZone:zone];
    if (painting) {
        painting->_points = [self.points copy];
    }
    return painting;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _points = [decoder decodeObjectForKey:@"points"];
        _isLastDrawing = [decoder decodeBoolForKey:@"isLastDrawing"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    if (self.points) {
        [encoder encodeObject:self.points forKey:@"points"];
    }
    [encoder encodeBool:self.isLastDrawing forKey:@"isLastDrawing"];
}

@end


