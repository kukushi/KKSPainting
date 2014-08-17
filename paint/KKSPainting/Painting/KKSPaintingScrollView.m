//
//  KKSDrawerView.m
//  Drawing Demo
//
//  Created by kukushi on 3/1/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingScrollView.h"
#import "KKSPaintingView.h"
#import "KKSPaintingManager.h"


@interface KKSPaintingScrollView()

@property (nonatomic, strong) KKSPaintingView *paintingView;

@property (nonatomic, strong, readwrite) KKSPaintingManager *paintingManager;

@property (nonatomic, strong) UILabel *indicatorLabel;

@end


@implementation KKSPaintingScrollView

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
    self.minimumZoomScale = .25f;
    self.maximumZoomScale = 10.f;
    self.scrollEnabled = NO;
    
    _paintingManager = [[KKSPaintingManager alloc] init];
    _paintingManager.paintingView = self;

    NSAssert(self.delegate == _paintingManager, @"");
    NSAssert(_paintingManager.paintingView.delegate == _paintingManager, @"");

    _backgroundView = [[UIImageView alloc] init];
    [self addSubview:_backgroundView];
    [self sendSubviewToBack:_backgroundView];

    _paintingView = [[KKSPaintingView alloc] init];
    _paintingView.backgroundColor = [UIColor clearColor];
    __weak KKSPaintingScrollView *weakSelf = self;
    [_paintingView needUpdatePaintingsWithBlock:^{
        [weakSelf.paintingManager drawAllPaintings];
    }];
    [self insertSubview:_paintingView aboveSubview:_backgroundView];
    
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
        if (finished) {
            [UIView animateWithDuration:1.2f animations:^{
                self.indicatorLabel.alpha = 0.f;
            }];
        }
                         }];
    }];
}

#pragma mark - Background Image

- (void)setBackgroundImage:(UIImage *)image
                       contentSize:(CGSize)size {
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);

    CGFloat contentWidth = MAX(size.width, image.size.width);
    CGFloat contentHeight = MAX(size.height, image.size.height);

    CGRect frame = CGRectMake(0, 0, screenWidth, screenHeight);
    if (contentHeight < screenHeight) {
        frame.origin.y = (screenHeight - contentHeight) * 0.5;
        frame.size.height = contentHeight;
    }
    if (contentWidth < screenWidth) {
        frame.origin.x = (screenWidth - contentWidth) * 0.5f;
        frame.size.width = contentWidth;
    }
    self.frame = frame;

    self.backgroundView.image = image;
    if (image) {
        self.backgroundView.frame = CGRectMake((contentWidth - image.size.width) * 0.5,
                (contentHeight - image.size.height) * 0.5,
                image.size.width,
                image.size.height);
    }
}

- (void)resizeFrameWithSize:(CGSize)size {

    CGFloat contentWidth = size.width;
    CGFloat contentHeight = size.height;


}

#pragma mark - Override ScrollView

- (void)setContentSize:(CGSize)contentSize {
    CGRect backgroundRect = CGRectZero;
    backgroundRect.size = contentSize;
    self.paintingView.frame = backgroundRect;
    
    [super setContentSize:contentSize];
}

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
    
    self.indicatorLabel.frame=CGRectMake(self.bounds.origin.x+60,self.bounds.origin.y+80, self.indicatorLabel.bounds.size.width, self.indicatorLabel.bounds.size.height);
    
    [self needUpdatePaintings];
}


#pragma mark - drawing

- (void)needUpdatePaintings {
    [self.paintingView setNeedsDisplay];
}

- (void)needUpdatePaintingsInRect:(CGRect)rect {
    [self.paintingView setNeedsDisplayInRect:rect];
}

@end
