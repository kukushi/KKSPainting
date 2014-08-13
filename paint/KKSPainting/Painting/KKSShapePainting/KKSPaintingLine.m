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

    self.path = [UIBezierPath bezierPath];
    [self.path moveToPoint:self.firstLocation];
    [self.path addLineToPoint:self.lastLocation];

    [self setupBezierPath];
    [self.path applyTransform:[self currentTransform]];

    [self.path strokeWithBlendMode:kCGBlendModeNormal alpha:self.alpha];

    self.strokingPath = [self strokePathBoundsWithStroking:self.shouldStrokePath];
}

@end
