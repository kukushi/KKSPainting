//
//  KKSPainting.h
//  Drawing Demo
//
//  Created by kukushi on 3/3/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKSPaintingScrollView.h"
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@protocol KKSPaintingDelegate;

@interface KKSPaintingBase : MTLModel <MTLJSONSerializing>

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGFloat alpha;

@property (nonatomic) BOOL shouldFill;
@property (nonatomic) BOOL shouldStrokePath;

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) UIBezierPath *strokingPath;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, weak) id<KKSPaintingDelegate> delegate;

@property (nonatomic, weak) KKSPaintingScrollView *view;


/**
 *  Indicate whether drawing is finished.
 */
@property (nonatomic) BOOL isDrawingFinished;


- (id)initWithView:(KKSPaintingScrollView *)view;

- (void)setLineWidth:(CGFloat)lineWidth
               color:(UIColor *)color
               alpha:(CGFloat)alpha;

- (CGPoint)pathCenterPoint;

- (void)recordingBeganWithTouch:(UITouch *)touch;

- (void)recordingContinueWithTouchMoved:(UITouch *)touch;

- (UIImage *)recordingEndedWithTouch:(UITouch *)touch cachedImage:(UIImage *)cachedImage;

- (BOOL)pathContainsPoint:(CGPoint)point;

- (BOOL)areaContainsPoint:(CGPoint)point;

- (void)drawPath;

/**
 *  end the painting directly.
 *  only work in Segment and Plo.
 */
- (UIImage *)endDrawingWithCacheImage:(UIImage *)cachedImage;

- (CGPoint)currentTranslation;

- (void)moveBySettingTranslation:(CGPoint)translation;

- (void)moveByIncreasingTranslation:(CGPoint)translation;

- (CGFloat)currentRotateDegree;

- (void)rotateAroundCenterBySettingDegree:(CGFloat)degree;

- (void)rotateAroundByIncreasingDegree:(CGFloat)degree;

- (CGFloat)currentZoomScale;

- (void)zoomAroundCenterBySettingScale:(CGFloat)scale;

- (void)zoomAroundCenterByIncreasingCurrentScale:(CGFloat)scale;

- (void)zoomBySettingScale:(CGFloat)scale;

- (void)zoomByIncreasingScale:(CGFloat)scale;

- (void)setFill:(BOOL)shouldFill color:(UIColor *)fillColor;

- (CGAffineTransform)currentTransform;

- (CGFloat)scaledLineWidth;

@end


@protocol KKSPaintingDelegate <NSObject>

/**
 *  Tell the delegate drawing is about to end automatically.
 *
 *  It'll happen when user leave screen for a long time while
 *  drawing is not yet finished.
 */
- (void)drawingWillEndAutomatically;

/**
 *  Tell the delegate drawing have ended normally.
 *
 */
- (void)drawingDidEndNormally;

@end