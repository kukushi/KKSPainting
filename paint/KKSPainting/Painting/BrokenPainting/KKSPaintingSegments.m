//
//  KKSPaintingSegments.m
//  MagicPaint
//
//  Created by kukushi on 7/25/14.
//  Copyright (c) 2014 Xing He All rights reserved.
//

#import "KKSPaintingSegments.h"
#import "KKSPaintingTool_KKSPaintingHelper.h"
#import "NSMutableArray+KKSValueSupport.h"
#import "UIBezierPath+Painting.h"


@interface KKSPaintingSegments()

@property (nonatomic, strong) NSMutableArray *points;

@end


@implementation KKSPaintingSegments

#pragma mark - Init

- (id)initWithView:(KKSPaintingScrollView *)view {
    self = [super initWithView:view];
    if (self) {
        _points = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Override Touches

- (void)recordingBeganWithTouch:(UITouch *)touch {
    
    CGPoint currentLocation = [touch locationInView:self.view];
    
    [super recordingBeganWithTouch:touch];
    
    [self.points kks_addPoint:currentLocation];
    
    [self.view needUpdatePaintings];
}

- (void)recordingContinueWithTouchMoved:(UITouch *)touch {
    // do nothing
}

- (void)recordingEndedWithTouch:(UITouch *)touch {
    [self.longPressFinishTimer invalidate];
    self.longPressFinishTimer = nil;
    
    if ([self isLongTapWithTouch:touch]) {
        // Drawing End
        self.isDrawingFinished = YES;
    }
}

- (void)endDrawing {
    self.isDrawingFinished = YES;
}

#pragma mark - Helper


- (void)drawPath {

    if (self.isBeforeSecondTap) {
        self.path = [UIBezierPath bezierPath];
        [self setupBezierPath];
        [self.path addArcWithCenter:self.firstLocation
                             radius:self.scaledLineWidth / 4.f
                         startAngle:0.f
                           endAngle:360.f * M_PI/180
                          clockwise:YES];
    }
    else {
        self.path = [UIBezierPath bezierPath];
        [self setupBezierPath];
        [self.path addLinesWithPoints:self.points];
    }

    [self.path applyTransform:[self currentTransform]];
    [self.path stroke];

    [self updateSelectionStrokingPath];

    if (self.shouldStrokePath) {
        [self strokePathBounds];
    }
}
 

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"points": @"points"};
}

@end
