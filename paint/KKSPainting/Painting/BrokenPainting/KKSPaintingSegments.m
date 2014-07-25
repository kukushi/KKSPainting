//
//  KKSPaintingSegments.m
//  MagicPaint
//
//  Created by kukushi on 7/25/14.
//  Copyright (c) 2014 Robin W. All rights reserved.
//

#import "KKSPaintingSegments.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"
#import "NSMutableArray+KKSValueSupport.h"


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

- (UIImage *)recordingEndedWithTouch:(UITouch *)touch
                         cachedImage:(UIImage *)cachedImage {
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
