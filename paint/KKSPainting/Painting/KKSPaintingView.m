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

@property (nonatomic, strong) UILabel *indicatorLabel;

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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(57, 65, 206, 30)];
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
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollEnabled) {
        UITouch *touch = [touches anyObject];
        [self.paintingManager paintingMovedWithTouch:touch];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollEnabled) {
        UITouch *touch = [touches anyObject];
        [self.paintingManager paintingEndWithTouch:touch];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
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
            [UIView animateWithDuration:1.f animations:^{
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
        self.paintingManager.canZoom = YES;
    }
    else if (image && !self.backgroundImageView) {
        self.contentSize = self.bounds.size;
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        [self addSubview:self.backgroundImageView];
        [self sendSubviewToBack:self.backgroundImageView];
        self.backgroundImageView.image = image;
        
        self.paintingManager.canZoom = NO;
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


/*
#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        _lineWidth = [decoder decodeFloatForKey:@"lineWidth"];
        _color = [decoder decodeObjectForKey:@"color"];
        _alpha = [decoder decodeFloatForKey:@"alpha"];
        _paintingType = [decoder decodeIntegerForKey:@"paintingType"];
        _paintingMode = [decoder decodeIntegerForKey:@"paintingMode"];
        _paintingDelegate = [decoder decodeObjectForKey:@"paintingDelegate"];
        _painting = [decoder decodeObjectForKey:@"painting"];
        _cachedImage = [decoder decodeObjectForKey:@"cachedImage"];
        _usedPaintings = [decoder decodeObjectForKey:@"usedPaintings"];
        _selectedPainting = [decoder decodeObjectForKey:@"selectedPainting"];
        _firstTouchLocation = [decoder decodeCGPointForKey:@"firstTouchLocation"];
        _previousLocation = [decoder decodeCGPointForKey:@"previousLocation"];
        _indicatorLabel = [decoder decodeObjectForKey:@"indicatorLabel"];
        _isActive = [decoder decodeBoolForKey:@"isActive"];
        _originalContentSize = [decoder decodeCGSizeForKey:@"originalContentSize"];
        _canChangeContentSize = [decoder decodeBoolForKey:@"canChangeContentSize"];
        _backgroundImageView = [decoder decodeObjectForKey:@"backgroundImageView"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeFloat:self.lineWidth forKey:@"lineWidth"];
    if (self.color) {
        [encoder encodeObject:self.color forKey:@"color"];
    }
    [encoder encodeFloat:self.alpha forKey:@"alpha"];
    [encoder encodeInteger:self.paintingType forKey:@"paintingType"];
    [encoder encodeInteger:self.paintingMode forKey:@"paintingMode"];
    if (self.paintingDelegate) {
        [encoder encodeObject:self.paintingDelegate forKey:@"paintingDelegate"];
    }
    if (self.painting) {
        [encoder encodeObject:self.painting forKey:@"painting"];
    }
    if (self.cachedImage) {
        [encoder encodeObject:self.cachedImage forKey:@"cachedImage"];
    }
    if (self.usedPaintings) {
        [encoder encodeObject:self.usedPaintings forKey:@"usedPaintings"];
    }
    if (self.selectedPainting) {
        [encoder encodeObject:self.selectedPainting forKey:@"selectedPainting"];
    }
    [encoder encodeCGPoint:self.firstTouchLocation forKey:@"firstTouchLocation"];
    [encoder encodeCGPoint:self.previousLocation forKey:@"previousLocation"];
    if (self.indicatorLabel) {
        [encoder encodeObject:self.indicatorLabel forKey:@"indicatorLabel"];
    }
    [encoder encodeBool:self.isActive forKey:@"isActive"];
    [encoder encodeCGSize:self.originalContentSize forKey:@"originalContentSize"];
    [encoder encodeBool:self.canChangeContentSize forKey:@"canChangeContentSize"];
    if (self.backgroundImageView) {
        [encoder encodeObject:self.backgroundImageView forKey:@"backgroundImageView"];
    }
}
 */

#pragma mark - drawing

- (void)drawRect:(CGRect)rect {
    [self.paintingManager drawAllPaintings];
}

@end
