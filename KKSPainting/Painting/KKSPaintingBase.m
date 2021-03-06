//
//  KKSPainting.m
//  Drawing Demo
//
//  Created by kukushi on 3/3/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingBase.h"

#pragma mark - KKSPainting

@interface KKSPaintingBase ()

@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) CGFloat realLineWidth;

@property (nonatomic) CGFloat rotateDegree;

@property (nonatomic) CGFloat baseZoomScale;

@property (nonatomic) CGPoint translation;
@property (nonatomic) CGFloat zoomAroundCenterScale;

@property (nonatomic) CGPoint centerPoint;

@property (nonatomic) BOOL shouldUpdateTransform;

@property (nonatomic) CGFloat zoomScale;

@end

@implementation KKSPaintingBase

#pragma mark - Init

- (id)initWithView:(KKSPaintingScrollView *)view {
    
    if (self = [super init]) {
        _view = view;
        _lineWidth = 6.f;
        _alpha = 1.f;
        _strokeColor = [UIColor blackColor];
        _fillColor = [UIColor clearColor];
        _path = [UIBezierPath bezierPath];
        _isDrawingFinished = YES;
        _transform = CGAffineTransformIdentity;
        _zoomAroundCenterScale = 1.f;
    }
    return self;
}

- (void)setLineWidth:(CGFloat)lineWidth
               color:(UIColor *)color
               alpha:(CGFloat)alpha {
    _lineWidth = lineWidth;
    _realLineWidth = lineWidth;
    _strokeColor = color;
    _alpha = alpha;
}

#pragma mark - Path Info

- (void)initPathCenterPoint {
    if (CGPointEqualToPoint(self.centerPoint, CGPointZero)) {
        CGRect bounds = self.path.bounds;
        self.centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    }
}

- (void)resetCenterPoint {
    CGRect bounds = self.path.bounds;
    self.centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

- (CGPoint)pathCenterPoint {
    CGPoint translatedPoint = CGPointMake(self.centerPoint.x + self.translation.x,
                                          self.centerPoint.y + self.translation.y);
    return translatedPoint;
}

#pragma mark - Handling Touches

- (void)recordingBeganWithTouch:(UITouch *)touch {
    // implemented by subclass
}

- (void)recordingContinueWithTouchMoved:(UITouch *)touch {
    // implemented by subclass
}

- (void)recordingEndedWithTouch:(UITouch *)touch {
    [self initPathCenterPoint];
}

- (BOOL)pathContainsPoint:(CGPoint)point {
    return [self.strokingPath containsPoint:point];
}

- (BOOL)areaContainsPoint:(CGPoint)point {
    return [self.path containsPoint:point];
}

#pragma mark - Drawing

- (void)drawPath {
    // implemented by subclass
}

- (void)endDrawing {
    // implemented by subclass
}

#pragma mark - Transform

- (CGPoint)currentTranslation {
    return self.translation;
}

- (void)moveBySettingTranslation:(CGPoint)translation {
    self.translation = translation;
    self.shouldUpdateTransform = YES;

//    [self resetCenterPoint];
}

- (void)moveByIncreasingTranslation:(CGPoint)translation {
    self.translation = CGPointMake(self.translation.x + translation.x,
                                   self.translation.y + translation.y);
    self.shouldUpdateTransform = YES;


//    [self resetCenterPoint];
}

- (CGFloat)currentRotateDegree {
    return self.rotateDegree;
}

- (void)rotateAroundCenterBySettingDegree:(CGFloat)degree {
    self.rotateDegree = degree;
    self.shouldUpdateTransform = YES;
}

- (void)rotateAroundByIncreasingDegree:(CGFloat)degree {
    self.rotateDegree += degree;
    self.shouldUpdateTransform = YES;
}

- (void)zoomBySettingScale:(CGFloat)scale {
    if (self.baseZoomScale == 0.f) {
        self.baseZoomScale = scale;
    }
    self.zoomScale = scale / self.baseZoomScale;
    self.shouldUpdateTransform = YES;
}

- (void)zoomByIncreasingScale:(CGFloat)scale {
    self.zoomScale += scale;
    self.shouldUpdateTransform = YES;
}

- (CGFloat)currentZoomScale {
    return self.zoomAroundCenterScale;
}

- (void)zoomAroundCenterBySettingScale:(CGFloat)scale {
    self.zoomAroundCenterScale = scale;
    self.shouldUpdateTransform = YES;
}

- (void)zoomAroundCenterByIncreasingCurrentScale:(CGFloat)scale {
    self.zoomAroundCenterScale += scale;
    self.shouldUpdateTransform = YES;
}

- (void)updateTransform {
    CGFloat lineWidth = self.lineWidth;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(self.translation.x,
                                                                   self.translation.y);

    CGPoint centerPoint = [self centerPoint];

    if (self.zoomScale != 0.f && self.zoomScale != 1.f) {
        transform = CGAffineTransformTranslate(transform, -1 * self.translation.x, -1 * self.translation.y);
        transform = CGAffineTransformScale(transform, self.zoomScale, self.zoomScale);
        lineWidth *= self.zoomScale;
        transform = CGAffineTransformTranslate(transform, self.translation.x, self.translation.y);
    }

    transform = CGAffineTransformTranslate(transform, centerPoint.x, centerPoint.y);
    transform = CGAffineTransformRotate(transform, self.rotateDegree);
    if (self.zoomAroundCenterScale != 1.f) {
        transform = CGAffineTransformScale(transform, self.zoomAroundCenterScale, self.zoomAroundCenterScale);
        lineWidth *= self.zoomAroundCenterScale;
    }
    transform = CGAffineTransformTranslate(transform, -1 * centerPoint.x, -1 * centerPoint.y);

    self.realLineWidth = lineWidth;
    	
    self.transform = transform;
}

- (void)setFill:(BOOL)shouldFill color:(UIColor *)fillColor {
    self.shouldFill = shouldFill;
    self.fillColor = fillColor;
}

- (CGAffineTransform)currentTransform {
    if (self.shouldUpdateTransform) {
        [self updateTransform];
        self.shouldUpdateTransform = NO;
    }
    return self.transform;
}

- (CGFloat)scaledLineWidth {
    return self.realLineWidth;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"lineWidth": @"lineWidth",
             @"alpha": @"alpha",
             @"shouldFill": @"shouldFill",
             @"path": @"path",
             @"shouldStrokePath": @"shouldStrokePath",
             @"strokingPath": @"strokingPath",
             @"strokeColor": @"strokeColor",
             @"fillColor": @"fillColor",
             @"transform": @"transform",
             @"realLineWidth": @"realLineWidth",
             @"rotateDegree": @"rotateDegree",
             @"translation": @"translation",
             @"zoomAroundCenterScale": @"zoomAroundCenterScale",
             @"centerPoint": @"centerPoint"
             };
}

#pragma mark - KKSPaintingHelper

- (void)setupBezierPath {
    self.path.lineCapStyle = kCGLineCapRound;
    self.path.lineWidth = self.scaledLineWidth;
    [self.strokeColor setStroke];
    [self.fillColor setFill];
}

#pragma mark - Setter

- (void)setBaseZoomScale:(CGFloat)baseZoomScale {
    if (_baseZoomScale == 0.f) {
        _baseZoomScale = baseZoomScale;
    }
}

#pragma mark - Drawing Bounds

- (UIColor *)boundsColor {
    return [UIColor colorWithRed:233/255.f
                           green:163/255.f
                            blue:104/255.f
                           alpha:1.f];
}

- (void)setupBoundsPath:(UIBezierPath *)path {
    CGFloat dashStyle[] = {5.0f, 5.0f};
    CGFloat lineWidth = floor(self.scaledLineWidth / 4.f);
    UIColor *strokeColor = [self boundsColor];
    [path setLineDash:dashStyle count:2 phase:0];
    [path setLineWidth:MAX(1.f, lineWidth)];
    [strokeColor setStroke];
}

- (void)updateSelectionStrokingPath {
    CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(self.path.CGPath,
            NULL,
            self.scaledLineWidth + 15.f,
            kCGLineCapRound,
            kCGLineJoinRound,
            0.f);
    self.strokingPath = [UIBezierPath bezierPathWithCGPath:strokingPath];
    CGPathRelease(strokingPath);
}

- (void)strokePathBounds {
    CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(self.path.CGPath,
                                                            NULL,
                                                            self.scaledLineWidth + 5.f,
                                                            kCGLineCapRound,
                                                            kCGLineJoinRound,
                                                            0.f);
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:strokingPath];
    [self setupBoundsPath:path];
    [path stroke];
    CGPathRelease(strokingPath);
}

- (void)strokeBoundWithBounds:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [self setupBoundsPath:path];
    [path stroke];
}

@end
