//
//  KKSPainting.m
//  Drawing Demo
//
//  Created by kukushi on 3/3/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingBase.h"

#pragma mark - KKSPainting

@interface KKSPaintingBase () <NSCopying, NSCoding>

@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) CGFloat realLineWidth;

@property (nonatomic) CGFloat rotateDegree;
@property (nonatomic) CGPoint translation;
@property (nonatomic) CGFloat zoomScale;

@property (nonatomic) CGPoint centerPoint;

@end

@implementation KKSPaintingBase

#pragma mark - Init

- (id)initWithView:(UIScrollView *)view {
    
    if (self = [super init]) {
        _view = view;
        _lineWidth = 6.f;
        _alpha = 1.f;
        _strokeColor = [UIColor blackColor].CGColor;
        _path = CGPathCreateMutable();
        _isDrawingFinished = YES;
        _transform = CGAffineTransformIdentity;
        _zoomScale = 1.f;
    }
    return self;
}

- (void)dealloc {
    _path = nil;
    _strokingPath = nil;
    _strokeColor = nil;
    _fillColor = nil;
}

- (void)setLineWidth:(CGFloat)lineWidth
               color:(CGColorRef)color
               alpha:(CGFloat)alpha {
    _lineWidth = lineWidth;
    _realLineWidth = lineWidth;
    _strokeColor = color;
    _alpha = alpha;
    
}

#pragma mark - Path Info

- (void)initPathCenterPoint {
    if (CGPointEqualToPoint(self.centerPoint, CGPointZero)) {
        CGRect bounds = CGPathGetBoundingBox(self.path);
        self.centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    }
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

- (UIImage *)recordingEndedWithTouch:(UITouch *)touch cachedImage:(UIImage *)cachedImage {
    
    CGSize imageSize;
    if (CGSizeEqualToSize(CGSizeZero, self.view.contentSize)) {
        imageSize = self.view.bounds.size;
    }
    else {
        imageSize = self.view.contentSize;
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.f);
    
    [cachedImage drawAtPoint:CGPointZero];
    
    [self drawPath];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    [self initPathCenterPoint];
    
    return image;
}

- (BOOL)pathContainsPoint:(CGPoint)point {
        CGFloat zoomLength = 15.f;
        CGPathRef selectingPath = CGPathCreateCopyByStrokingPath(self.path,
                                                           NULL,
                                                           self.scaledLineWidth + zoomLength,
                                                           kCGLineCapRound,
                                                           kCGLineJoinRound,
                                                           0.f);
    
    BOOL containsPoint = CGPathContainsPoint(selectingPath, NULL, point, true);
    CGPathRelease(selectingPath);
    return containsPoint;
}

- (BOOL)areaContainsPoint:(CGPoint)point {
    return CGPathContainsPoint(self.path, NULL, point, true);
}

#pragma mark - Drawing

- (void)drawPath {
    // implemented by subclass
}

- (UIImage *)endDrawingWithCacheImage:(UIImage *)cachedImage {
    // implemented by subclass
    return nil;
}

#pragma mark - Transform

- (CGPoint)currentTranslation {
    return self.translation;
}

- (void)moveBySettingTranslation:(CGPoint)translation {
    self.translation = translation;
    [self updateTransform];
}

- (void)moveByIncreasingTranslation:(CGPoint)translation {
    self.translation = CGPointMake(self.translation.x + translation.x,
                                   self.translation.y + translation.y);
    [self updateTransform];
}

- (CGFloat)currentRotateDegree {
    return self.rotateDegree;
}

- (void)rotateBySettingDegree:(CGFloat)degree {
    self.rotateDegree = degree;
    [self updateTransform];
}

- (void)rotateByIncreasingDegree:(CGFloat)degree {
    self.rotateDegree += degree;
    [self updateTransform];
}

- (CGFloat)currentZoomScale {
    return self.zoomScale;
}

- (void)zoomBySettingScale:(CGFloat)scale {
    self.zoomScale = scale;
    [self updateTransform];
}

- (void)zoomByPlusCurrentScale:(CGFloat)scale {
    self.zoomScale += scale;
    [self updateTransform];
}

- (void)updateTransform {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(self.translation.x,
                                                                   self.translation.y);
    
    CGPoint centerPoint = [self centerPoint];
    transform = CGAffineTransformTranslate(transform, centerPoint.x, centerPoint.y);
    transform = CGAffineTransformRotate(transform, self.rotateDegree);
    if (self.zoomScale != 1.f) {
        transform = CGAffineTransformScale(transform, self.zoomScale, self.zoomScale);
    }
    self.realLineWidth = self.lineWidth * self.zoomScale;
    transform = CGAffineTransformTranslate(transform, -1 * centerPoint.x, -1 * centerPoint.y);

    self.transform = transform;
}

- (void)setFill:(BOOL)shouldFill color:(CGColorRef)fillColor {
    self.shouldFill = shouldFill;
    self.fillColor = fillColor;
}

- (CGAffineTransform)currentTransform {
    return self.transform;
}

- (CGFloat)scaledLineWidth {
    return self.realLineWidth;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    KKSPaintingBase *painting = [[self class] allocWithZone:zone];
    if (painting) {
        painting->_lineWidth = _lineWidth;
        painting->_alpha = _alpha;
        painting->_shouldFill = _shouldFill;
        painting->_shouldStrokePath = _shouldStrokePath;
        
        painting->_path = CGPathRetain(_path);
        painting->_strokingPath = CGPathRetain(_strokingPath);
        
        painting->_strokeColor = CGColorRetain(_strokeColor);
        painting->_fillColor = CGColorRetain(_fillColor);
        
        painting->_delegate = _delegate;
        painting->_view = _view;
        
        painting->_isDrawingFinished = _isDrawingFinished;
        
        painting->_realLineWidth = _realLineWidth;
        painting->_transform = _transform;
        painting->_rotateDegree = _rotateDegree;
        painting->_translation = _translation;
        painting->_zoomScale = _zoomScale;
        painting->_centerPoint = _centerPoint;
    }
    return painting;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _lineWidth = [decoder decodeFloatForKey:@"lineWidth"];
        _alpha = [decoder decodeFloatForKey:@"alpha"];
        _shouldFill = [decoder decodeBoolForKey:@"shouldFill"];
        _shouldStrokePath = [decoder decodeBoolForKey:@"shouldStrokePath"];
        NSValue *pathValue = [decoder decodeObjectForKey:@"path"];
        _path = [pathValue pointerValue];
        NSValue *strokingPathValue = [decoder decodeObjectForKey:@"strokingPath"];
        _strokingPath = [strokingPathValue pointerValue];
        NSValue *strokeColorValue = [decoder decodeObjectForKey:@"strokeColor"];
        _strokeColor = [strokeColorValue pointerValue];
        NSValue *fillColorValue = [decoder decodeObjectForKey:@"fillColor"];
        _fillColor = [fillColorValue pointerValue];
        _delegate = [decoder decodeObjectForKey:@"delegate"];
        _view = [decoder decodeObjectForKey:@"view"];
        _transform = [decoder decodeCGAffineTransformForKey:@"transform"];
        _realLineWidth = [decoder decodeFloatForKey:@"realLineWidth"];
        _rotateDegree = [decoder decodeFloatForKey:@"rotateDegree"];
        _translation = [decoder decodeCGPointForKey:@"translation"];
        _zoomScale = [decoder decodeFloatForKey:@"zoomScale"];
        _centerPoint = [decoder decodeCGPointForKey:@"centerPoint"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeFloat:self.lineWidth forKey:@"lineWidth"];
    [encoder encodeFloat:self.alpha forKey:@"alpha"];
    [encoder encodeBool:self.shouldFill forKey:@"shouldFill"];
    [encoder encodeBool:self.shouldStrokePath forKey:@"shouldStrokePath"];
    NSValue *pathValue = [NSValue valueWithPointer:self.path];
    [encoder encodeObject:pathValue forKey:@"path"];
    NSValue *strokingPathValue = [NSValue valueWithPointer:self.strokingPath];
    [encoder encodeObject:strokingPathValue forKey:@"strokingPath"];
    NSValue *strokeColorValue = [NSValue valueWithPointer:self.strokeColor];
    [encoder encodeObject:strokeColorValue forKey:@"strokeColor"];
    NSValue *fillColorValue = [NSValue valueWithPointer:self.fillColor];
    [encoder encodeObject:fillColorValue forKey:@"fillColor"];
    if (self.delegate) {
        [encoder encodeObject:self.delegate forKey:@"delegate"];
    }
    if (self.view) {
        [encoder encodeObject:self.view forKey:@"view"];
    }
    [encoder encodeCGAffineTransform:self.transform forKey:@"transform"];
    [encoder encodeFloat:self.realLineWidth forKey:@"realLineWidth"];
    [encoder encodeFloat:self.rotateDegree forKey:@"rotateDegree"];
    [encoder encodeCGPoint:self.translation forKey:@"translation"];
    [encoder encodeFloat:self.zoomScale forKey:@"zoomScale"];
}


#pragma mark - KKSPaintingHelper

- (void)setupContext:(CGContextRef)context {
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.scaledLineWidth);
    CGContextSetStrokeColorWithColor(context, self.strokeColor);
    CGContextSetAlpha(context, self.alpha);
}

- (CGPathRef)strokePathWithContext:(CGContextRef)context {
    CGPathRef storkingPath = CGPathCreateCopyByStrokingPath(self.path,
                                                            NULL,
                                                            self.scaledLineWidth + 1.f,
                                                            kCGLineCapRound,
                                                            kCGLineJoinRound,
                                                            0.f);
    CGContextAddPath(context, storkingPath);
    CGContextSaveGState(context);
    
    CGFloat dashStyle[] = {5.0f, 5.0f};
    CGContextSetLineDash(context, 0, dashStyle, 2);
    CGFloat lineWidth = floor(self.scaledLineWidth / 4.f);
    CGContextSetLineWidth(context, MAX(1.f, lineWidth));
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:233/255.f
                                                              green:163/255.f
                                                               blue:104/255.f
                                                              alpha:1.f].CGColor);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    return storkingPath;
}

- (void)strokeBoundWithContext:(CGContextRef)context {
    CGRect bounds = CGPathGetBoundingBox(self.path);
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, NULL, bounds);
    CGContextAddPath(context, path);
    
    CGContextSaveGState(context);
    
    CGFloat dashStyle[] = {5.0f, 5.0f};
    CGContextSetLineDash(context, 0, dashStyle, 2);
    CGFloat lineWidth = floor(self.scaledLineWidth / 4.f);
    CGContextSetLineWidth(context, MAX(1.f, lineWidth));
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:233/255.f
                                                              green:163/255.f
                                                               blue:104/255.f
                                                              alpha:1.f].CGColor);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end
