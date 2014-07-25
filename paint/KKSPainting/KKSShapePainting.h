//
//  KKSShapepainting.h
//  Drawing Demo
//
//  Created by kukushi on 3/4/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingBase.h"

@interface KKSShapePainting : KKSPaintingBase

@property (nonatomic) CGPoint firstLocation;
@property (nonatomic) CGPoint lastLocation;

- (CGRect)rectToDraw;

@end