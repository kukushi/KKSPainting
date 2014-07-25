//
//  KKSBrokenPainting.m
//  Drawing Demo
//
//  Created by kukushi on 3/5/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSBrokenPainting.h"
#import "KKSPointExtend.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"
#import "NSMutableArray+KKSValueSupport.h"

CGFloat const kAutoEndTime = 1.2f;
NSTimeInterval const kLongPressEndTime = 0.6f;

#pragma mark - KKSBrokenPainting

@interface KKSBrokenPainting()

@end

@implementation KKSBrokenPainting

#pragma mark - Init

- (id)initWithView:(UIScrollView *)view {
    self = [super initWithView:view];
    if (self) {
        self.isDrawingFinished = NO;
        _isFirstTap = YES;
        _isBeforeSecondTap = YES;
    }
    return self;
}

#pragma mark -

- (void)recordingBeganWithTouch:(UITouch *)touch {
    self.previousTimeStamp = touch.timestamp;
    
    if ([self.autoEndTimer isValid]) {
        [self.autoEndTimer invalidate];
    }
    
    if ([self.delegate respondsToSelector:@selector(drawingWillEndAutomatically)]) {
        self.autoEndTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoEndTime
                                                         target:self.delegate
                                                              selector:@selector(drawingWillEndAutomatically)
                                                       userInfo:nil
                                                        repeats:NO];
    }
    
    if (self.delegate) {
        self.longPressFinishTimer = [NSTimer scheduledTimerWithTimeInterval:kLongPressEndTime
                                                                     target:self
                                                                   selector:@selector(drawingEndByLongPress)
                                                                   userInfo:nil
                                                                    repeats:NO];
    }
    
    if (self.isFirstTap) {
        self.isFirstTap = NO;
        self.firstLocation = [touch locationInView:self.view];
    } else {
        self.isBeforeSecondTap = NO;
    }
}

- (void)drawingEndByLongPress {
    [self.autoEndTimer invalidate];
     if ([self.delegate respondsToSelector:@selector(drawingDidEndNormally)]) {
         [self.delegate drawingDidEndNormally];
     }
}

- (BOOL)isLongTapWithTouch:(UITouch *)touch {
    if (self.previousTimeStamp == 0) {
        return NO;
    }
    return touch.timestamp - self.previousTimeStamp > 0.4f;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    KKSBrokenPainting *painting = [super copyWithZone:zone];
    if (painting) {
        painting->_isFirstTap = self.isFirstTap;
        painting->_isBeforeSecondTap = self.isBeforeSecondTap;
        painting->_firstLocation = self.firstLocation;
        painting->_previousLocation = self.previousLocation;
        painting->_previousTimeStamp = self.previousTimeStamp;
    }
    return painting;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _isFirstTap = [decoder decodeBoolForKey:@"isFirstTap"];
        _isBeforeSecondTap = [decoder decodeBoolForKey:@"isBeforeSecondTap"];
        _firstLocation = [decoder decodeCGPointForKey:@"firstLocation"];
        _previousLocation = [decoder decodeCGPointForKey:@"previousLocation"];
        _previousTimeStamp = [decoder decodeFloatForKey:@"previousTimeStamp"];
        _autoEndTimer = [decoder decodeObjectForKey:@"autoEndTimer"];
        _longPressFinishTimer = [decoder decodeObjectForKey:@"longPressFinishTimer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.isFirstTap forKey:@"isFirstTap"];
    [encoder encodeBool:self.isBeforeSecondTap forKey:@"isBeforeSecondTap"];
    [encoder encodeCGPoint:self.firstLocation forKey:@"firstLocation"];
    [encoder encodeCGPoint:self.previousLocation forKey:@"previousLocation"];
    [encoder encodeFloat:self.previousTimeStamp forKey:@"previousTimeStamp"];
    if (self.autoEndTimer) {
        [encoder encodeObject:self.autoEndTimer forKey:@"autoEndTimer"];
    }
    if (self.longPressFinishTimer) {
        [encoder encodeObject:self.longPressFinishTimer forKey:@"longPressFinishTimer"];
    }
}

@end