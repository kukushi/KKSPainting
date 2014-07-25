//
//  KKSPaintingLine.m
//  MagicPaint
//
//  Created by kukushi on 7/25/14.
//  Copyright (c) 2014 Robin W. All rights reserved.
//

#import "KKSPaintingLine.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"

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
