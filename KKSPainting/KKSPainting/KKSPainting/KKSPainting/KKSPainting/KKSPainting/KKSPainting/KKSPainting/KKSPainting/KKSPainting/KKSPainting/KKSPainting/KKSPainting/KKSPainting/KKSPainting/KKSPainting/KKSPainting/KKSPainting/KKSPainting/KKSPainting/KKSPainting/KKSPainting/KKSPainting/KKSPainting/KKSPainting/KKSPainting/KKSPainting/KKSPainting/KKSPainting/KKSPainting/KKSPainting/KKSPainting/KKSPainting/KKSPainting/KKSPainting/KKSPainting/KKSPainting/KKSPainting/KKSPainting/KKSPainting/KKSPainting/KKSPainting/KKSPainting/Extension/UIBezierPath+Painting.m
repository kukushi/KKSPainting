//
//  UIBezierPath+Painting.m
//  MagicPaint
//
//  Created by kukushi on 8/12/14.
//  Copyright (c) 2014 Xing He All rights reserved.
//

#import "UIBezierPath+Painting.h"

@implementation UIBezierPath (Painting)

- (void)addLinesWithPoints:(NSArray *)points {
    BOOL passFirst = NO;
    for (NSValue *pointValue in points) {
        CGPoint point = [pointValue CGPointValue];
        if (!passFirst) {
            passFirst = YES;
            [self moveToPoint:point];
        }
        [self addLineToPoint:point];
    }
}

@end
