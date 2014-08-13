//
//  KKSPainting_KKSPaintingHelper.h
//  Drawing Demo
//
//  Created by kukushi on 3/27/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingBase.h"

@interface KKSPaintingBase ()

- (void)setupBezierPath;

- (void)setupContext:(CGContextRef)context;

- (UIBezierPath *)strokePathBoundsWithStroking:(BOOL)shouldStroking;

- (void)strokeBoundWithBounds:(CGRect)rect;

@end
