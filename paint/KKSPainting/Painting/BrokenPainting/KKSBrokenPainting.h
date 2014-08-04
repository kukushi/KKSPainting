//
//  KKSBrokenPainting.h
//  Drawing Demo
//
//  Created by kukushi on 3/5/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingBase.h"

@interface KKSBrokenPainting : KKSPaintingBase <NSCoding>

@property (nonatomic) BOOL isFirstTap;
@property (nonatomic) BOOL isBeforeSecondTap;
@property (nonatomic) CGPoint firstLocation;
@property (nonatomic) CGPoint previousLocation;

@property (nonatomic) NSTimeInterval previousTimeStamp;

@property (nonatomic, strong) NSTimer *autoEndTimer;
@property (nonatomic, strong) NSTimer *longPressFinishTimer;

- (BOOL)isLongTapWithTouch:(UITouch *)touch;

@end