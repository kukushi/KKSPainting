//
//  NSArray+KKSEnumSupport.h
//  Drawing Demo
//
//  Created by kukushi on 3/15/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (KKSValueSupport)

- (void)kks_addInteger:(NSInteger)integerValue;
- (void)kks_insertInteger:(NSInteger)integerValue atIndex:(NSInteger)index;
- (NSInteger)kks_lastInteger;
- (NSInteger)kks_firstInteger;
- (NSInteger)kks_integerAtIndex:(NSInteger)index;

- (void)kks_addPoint:(CGPoint)point;
- (NSInteger)kks_cArrayWithCGPoint:(CGPoint *)pointArray;

@end
