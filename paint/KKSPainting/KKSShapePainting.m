//
//  KKSShapepainting.m
//  Drawing Demo
//
//  Created by kukushi on 3/4/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSShapePainting.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"
#import "KKSLog.h"

#pragma mark - KKSShapePainting

@interface KKSShapePainting ()

@property (nonatomic) CGPoint firstLocation;
@property (nonatomic) CGPoint lastLocation;

@end

@implementation KKSShapePainting

#pragma mark - Override

- (void)recordingBeganWithTouch:(UITouch *)touch {
    self.firstLocation = [touch locationInView:self.view];
}

- (void)recordingContinueWithTouchMoved:(UITouch *)touch {
    self.lastLocation = [touch locationInView:self.view];
    [self.view setNeedsDisplay];
}

#pragma mark - Helper

- (CGRect)rectToDraw {
    return CGRectMake(self.firstLocation.x,
                      self.firstLocation.y,
                      self.lastLocation.x - self.firstLocation.x,
                      self.lastLocation.y - self.firstLocation.y);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    KKSShapePainting *painting = [super copyWithZone:zone];
    if (painting) {
        painting->_firstLocation = _firstLocation;
        painting->_lastLocation = _lastLocation;
    }
    return painting;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeCGPoint:self.firstLocation forKey:@"firstLocation"];
    [encoder encodeCGPoint:self.lastLocation forKey:@"lastLocation"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _firstLocation = [decoder decodeCGPointForKey:@"firstLocation"];
        _lastLocation = [decoder decodeCGPointForKey:@"lastLocation"];
    }
    return self;
}


@end



#pragma mark - KKSPaintingLine

@implementation KKSPaintingLine

- (void)drawPath {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self setupContext:context];
    
    CGContextStrokePath(context);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGAffineTransform transform = [self currentTransform];
    CGPathMoveToPoint(path, &transform, self.firstLocation.x, self.firstLocation.y);
    CGPathAddLineToPoint(path, &transform, self.lastLocation.x, self.lastLocation.y);
    CGContextAddPath(context, path);
    
    CGContextStrokePath(context);
    self.path = path;
    
    if (self.shouldStrokePath) {
        self.strokingPath = [self strokePathWithContext:context];
    }
}

@end



#pragma mark - KKSPaintingRetangle

@interface KKSPaintingRectangle () <NSCopying>

@end

@implementation KKSPaintingRectangle

- (void)drawPath {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self setupContext:context];
    
    CGRect rectToDraw = [self rectToDraw];
    CGAffineTransform transform = [self currentTransform];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, &transform, rectToDraw);
    CGContextAddPath(context, path);
    
    if (self.shouldFill) {
        CGContextSetFillColorWithColor(context, self.fillColor);
        CGContextDrawPath(context, kCGPathFillStroke);
    } else {
        CGContextStrokePath(context);
    }
    
    
    self.path = path;
    
    if (self.shouldStrokePath) {        
        self.strokingPath = [self strokePathWithContext:context];
    }
}

@end



#pragma mark - KKSPaintingEllipse

@implementation KKSPaintingEllipse

- (void)drawPath {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self setupContext:context];

    CGRect rectToDraw = [self rectToDraw];
    CGAffineTransform transform = [self currentTransform];

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, &transform, rectToDraw);
    CGContextAddPath(context, path);
    
    if (self.shouldFill) {
        CGContextSetFillColorWithColor(context, self.fillColor);
        CGContextDrawPath(context, kCGPathFillStroke);
    } else {
        CGContextStrokePath(context);
    }
    
    self.path = path;
    
    if (self.shouldStrokePath) {
        self.strokingPath = [self strokePathWithContext:context];
    }
}

@end

