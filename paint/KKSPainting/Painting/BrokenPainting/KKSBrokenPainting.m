//
//  KKSBrokenPainting.m
//  Drawing Demo
//
//  Created by kukushi on 3/5/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSBrokenPainting.h"


CGFloat const kAutoEndTime = 1.2f;
NSTimeInterval const kLongPressEndTime = 0.6f;

#pragma mark - KKSBrokenPainting

@interface KKSBrokenPainting()

@end

@implementation KKSBrokenPainting

#pragma mark - Init

- (id)initWithView:(KKSPaintingScrollView *)view {
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

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"firstLocation": @"firstLocation",
             @"previousLocation": @"previousLocation"};
}

@end