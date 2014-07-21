//
//  KKSPainting_KKSPaintingHelper.h
//  Drawing Demo
//
//  Created by kukushi on 3/27/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingTool.h"

@interface KKSPaintingTool ()

- (void)setupContext:(CGContextRef)context;

- (CGPathRef)strokePathWithContext:(CGContextRef)context;

- (void)strokeBoundWithContext:(CGContextRef)context;

@end
