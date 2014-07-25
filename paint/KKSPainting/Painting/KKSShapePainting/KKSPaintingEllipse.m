//
//  KKSPaintingEllipse.m
//  MagicPaint
//
//  Created by kukushi on 7/25/14.
//  Copyright (c) 2014 Robin W. All rights reserved.
//

#import "KKSPaintingEllipse.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"

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
