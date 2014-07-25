//
//  NSArray+KKSEnumSupport.m
//  Drawing Demo
//
//  Created by kukushi on 3/15/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "NSMutableArray+KKSValueSupport.h"

#pragma mark - NSInteger

@implementation NSMutableArray (KKSValueSupport)

- (void)kks_addInteger:(NSInteger)integerValue {
    NSValue *value = [NSValue valueWithBytes:&integerValue objCType:@encode(NSInteger)];
    [self addObject:value];
}

- (void)kks_insertInteger:(NSInteger)integerValue atIndex:(NSInteger)index {
    NSValue *value = [NSValue valueWithBytes:&integerValue objCType:@encode(NSInteger)];
    [self insertObject:value atIndex:index];
}

- (NSInteger)kks_lastInteger {
    NSValue *value = [self lastObject];
    NSInteger integer = [self integerFromValue:value];
    return integer;
}

- (NSInteger)kks_firstInteger {
    NSValue *value = [self firstObject];
    NSInteger integer = [self integerFromValue:value];
    return integer;
}

- (NSInteger)kks_integerAtIndex:(NSInteger)index {
    NSValue *value = [self objectAtIndex:index];
    NSInteger integer = [self integerFromValue:value];
    return integer;
}

#

- (void)kks_addPoint:(CGPoint)point {
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    [self addObject:pointValue];
}

- (NSInteger)kks_cArrayWithCGPoint:(CGPoint *)pointArray {
    NSInteger pointArrayCount = 0;
    for (NSValue *pointValue in self) {
        if ([pointValue isKindOfClass:[NSValue class]]) {
            CGPoint point = [pointValue CGPointValue];
            pointArray[pointArrayCount++] = point;
        }
    }
    return pointArrayCount;
}

#pragma mark - Helper

- (NSInteger)integerFromValue:(NSValue *)value {
    NSInteger integerValue;
    [value getValue:&integerValue];
    return integerValue;
}

@end
