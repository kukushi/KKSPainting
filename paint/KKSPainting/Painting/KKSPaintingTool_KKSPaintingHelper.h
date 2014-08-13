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

/*
 * renew the stroking path used to judge whether
 * a path is selected from current path
 */
- (void)updateSelectionStrokingPath;

- (void)strokePathBounds;

- (void)strokeBoundWithBounds:(CGRect)rect;

@end
