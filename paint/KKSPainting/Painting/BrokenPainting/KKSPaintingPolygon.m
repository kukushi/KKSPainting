//
//  KKSPaintingPolygon.m
//  MagicPaint
//
//  Created by kukushi on 7/25/14.
//  Copyright (c) 2014 Robin W. All rights reserved.
//

#import "KKSPaintingPolygon.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"
#import "KKSPointExtend.h"
#import "NSMutableArray+KKSValueSupport.h"
#import "UIBezierPath+Painting.h"

@interface KKSPaintingPolygon ()

@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic) BOOL isLastDrawing;

@end

@implementation KKSPaintingPolygon

#pragma mark - Init

- (id)initWithView:(KKSPaintingScrollView *)view {
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
    
    [self.view needUpdatePaintings];
}

- (UIImage *)endDrawingWithCacheImage:(UIImage *)cachedImage {
    self.isDrawingFinished = YES;
    [self.view needUpdatePaintings];
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
    if (self.isBeforeSecondTap) {
        self.path = [UIBezierPath bezierPath];
        [self setupBezierPath];
        [self.path addArcWithCenter:self.firstLocation
                             radius:self.scaledLineWidth / 4.f
                         startAngle:0.f
                           endAngle:360.f * M_PI/180
                          clockwise:YES];
    } else if (!self.isDrawingFinished) {
        self.path = [UIBezierPath bezierPath];
        [self setupBezierPath];
        [self.path addLinesWithPoints:self.points];
    } else {
        self.path = [UIBezierPath bezierPath];
        [self setupBezierPath];
        [self.path addLinesWithPoints:self.points];
        [self.path closePath];
    }

    [self.path applyTransform:[self currentTransform]];

    if (self.shouldFill) {
        [self.path fillWithBlendMode:kCGBlendModeNormal alpha:self.alpha];
    }

    [self.path strokeWithBlendMode:kCGBlendModeNormal alpha:self.alpha];

    self.strokingPath = [self strokePathBoundsWithStroking:self.shouldStrokePath];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"points": @"points",
             @"isBeforeSecondTap": @"isBeforeSecondTap",
             @"isDrawingFinished": @"isDrawingFinished"};
}

/*
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
 */

@end


