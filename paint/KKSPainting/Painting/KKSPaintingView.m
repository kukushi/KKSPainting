//
//  KKSDrawerView.m
//  Drawing Demo
//
//  Created by kukushi on 3/1/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingView.h"
#import "KKSPaintingManager.h"


@interface KKSPaintingView() <NSCoding>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong, readwrite) KKSPaintingManager *paintingManager;

@end


@implementation KKSPaintingView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSelf];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeSelf];
    }
    return self;
}

- (void)initializeSelf {
    self.backgroundColor = [UIColor clearColor];
    self.scrollEnabled = NO;
    
    _paintingManager = [[KKSPaintingManager alloc] init];
    _paintingManager.paintingView = self;
    
    
    _indicatorLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(57, 80, 206, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.alpha = 0.f;
        [self addSubview:label];
        label;
    });
}

#pragma mark - Painting Manager

- (void)refreshPaintingManager:(KKSPaintingManager *)paintingManager {
    self.paintingManager = paintingManager;
    self.paintingManager.paintingView = self;
    [self setNeedsDisplay];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollEnabled) {
        UITouch *touch = [touches anyObject];
        [self.paintingManager paintingBeginWithTouch:touch];
    }
    if (self.viewController) {
        [self.viewController touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollEnabled) {
        UITouch *touch = [touches anyObject];
        [self.paintingManager paintingMovedWithTouch:touch];
    }
    if (self.viewController) {
        [self.viewController touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollEnabled) {
        UITouch *touch = [touches anyObject];
        [self.paintingManager paintingEndWithTouch:touch];
    }
    if (self.viewController) {
        [self.viewController touchesMoved:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
    
    if (self.viewController) {
        [self.viewController touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - Indicator Label

- (void)showIndicatorLabelWithText:(NSString *)text {
    
    self.indicatorLabel.text = text;

    [UIView animateWithDuration:.5f animations:^{
        self.indicatorLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2.f
                         animations:^{
                             //
                         } completion:^(BOOL finished) {
        if (finished == YES) {
            [UIView animateWithDuration:1.2f animations:^{
                self.indicatorLabel.alpha = 0.f;
            }];
        }
                         }];
    }];
}

#pragma mark - Background Image

- (void)setBackgroundImage:(UIImage *)image {

    if (!image && self.backgroundImageView) {
        [self.backgroundImageView removeFromSuperview];
        self.backgroundImageView = nil;
    }
    else if (image && !self.backgroundImageView) {
        self.contentSize = self.bounds.size;
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        [self addSubview:self.backgroundImageView];
        [self sendSubviewToBack:self.backgroundImageView];
        self.backgroundImageView.image = image;
    }
    else if (image && self.backgroundImageView) {
        self.backgroundImageView.image = image;
    }
}

#pragma mark - Override ScrollView

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
    [self setNeedsDisplay];
}


#pragma mark - drawing

- (void)drawRect:(CGRect)rect {
    [self.paintingManager drawAllPaintings];
}

@end
