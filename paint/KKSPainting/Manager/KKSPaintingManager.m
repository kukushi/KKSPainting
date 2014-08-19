//
//  KKSPaintingManager.m
//  Drawing Demo
//
//  Created by kukushi on 4/2/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "KKSPaintingManager.h"

#import "KKSPaintingPen.h"
#import "KKSPaintingTool.h"

#import "KKSPaintingModel.h"

#import "KKSPointExtend.h"

static NSString * const KKSPaintingUndoKeyPainting = @"KKSPaintingUndoKeyPainting";
static NSString * const KKSPaintingUndoKeyTranslation = @"KKSPaintingUndoKeyTranslation";
static NSString * const KKSPaintingUndoKeyDegree = @"KKSPaintingUndoKeyDegree";
static NSString * const KKSPaintingUndoKeyZoomScale = @"KKSPaintingUndoKeyZoomScale";
static NSString * const KKSPaintingUndoKeyShouldFill = @"KKSPaintingUndoKeyShouldFill";
static NSString * const KKSPaintingUndoKeyFillColor = @"KKSPaintingUndoKeyFillColor";


@interface KKSPaintingManager () <KKSPaintingDelegate>

@property (nonatomic, strong) KKSPaintingModel *paintingModel;

@property (nonatomic, strong) NSUndoManager *undoManager;

@property (nonatomic, strong) KKSPaintingBase *painting;
@property (nonatomic, weak) KKSPaintingBase *selectedPainting;
@property (nonatomic, weak) KKSPaintingBase *paintingToFill;

@property (nonatomic) CGPoint firstTouchLocation;
@property (nonatomic) CGPoint previousLocation;

@property (nonatomic) BOOL isActive;

@property (nonatomic) CGFloat currentZoomScale;



@end

@implementation KKSPaintingManager

#pragma mark - Init

void KKSViewBeginImageContextWithImage(KKSPaintingScrollView *view) {
    UIGraphicsBeginImageContextWithOptions(view.visibleContentSize.size, NO, 0.f);
}

- (id)init {
    if (self = [super init]) {
        _lineWidth = 5.f;
        _alpha = 1.f;
        _color = [UIColor blackColor];
        _paintingModel = [[KKSPaintingModel alloc] init];
        _undoManager = [[NSUndoManager alloc] init];
        _modelIndex = -1;
        _currentZoomScale = 1.f;
    }
    return self;
}

#pragma mark - Reload

- (void)reloadManagerWithModel:(KKSPaintingModel *)paintingModel {
    for (KKSPaintingBase *painting in paintingModel.usedPaintings) {
        painting.delegate = self;
        painting.view = self.paintingView;
    }
    self.paintingModel = paintingModel;
    [self resetProperties];
    [self.paintingView setBackgroundImage:paintingModel.backgroundImage
                              contentSize:self.paintingModel.originalContentSize];
    
    
    [self.paintingView needUpdatePaintings];
}

- (void)reloadManagerWithImage:(UIImage *)image Size:(CGSize)size {
    self.paintingModel = [[KKSPaintingModel alloc] init];
    self.paintingModel.backgroundImage = image;
    self.paintingModel.originalContentSize = size;
    [self resetProperties];
    [self.paintingView needUpdatePaintings];
}

- (void)resetProperties {
    self.currentZoomScale = 1.f;
    self.painting = nil;
    self.selectedPainting = nil;
    self.paintingToFill = nil;
    self.undoManager = [[NSUndoManager alloc] init];
}

#pragma mark - Selected Painting

- (BOOL)hasSelectedPainting {
    return self.selectedPainting != nil;
}

- (void)updateSelectedPaintingWithPoint:(CGPoint)point {
    self.selectedPainting = nil;

    // keep the last one selected
    for (KKSPaintingBase *painting in self.paintingModel.usedPaintings) {
        if ([painting pathContainsPoint:point]) {
            self.selectedPainting = painting;
        }
    }
}

- (KKSPaintingBase *)paintingContainedInAreaWithPoint:(CGPoint)point {
    __block KKSPaintingBase* containedPainting = nil;
    [self.paintingModel.usedPaintings enumerateObjectsWithOptions:NSEnumerationReverse
                                         usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                             KKSPaintingBase *painting = (KKSPaintingBase *)obj;
                                             if ([painting areaContainsPoint:point]) {
                                                 containedPainting = painting;
                                                 *stop = YES;
                                             }
                                         }];
    return containedPainting;
}

#pragma mark - Touches

- (void)paintingBeginWithTouch:(UITouch *)touch {
    KKSPaintingMode paintingMode = self.paintingMode;
    CGPoint touchedLocation = [touch locationInView:self.paintingView];
    
    if (paintingMode == KKSPaintingModePainting) {
        if (!self.isActive) {
            self.isActive = YES;
            [self renewPainting];
            
            if ([self.paintingDelegate respondsToSelector:@selector(paintingManagerWillBeginPainting)]) {
                [self.paintingDelegate paintingManagerWillBeginPainting];
            }
            [self registerUndoForPaintingWithPaintings:[self.paintingModel.usedPaintings copy]];
        }
        [self.painting recordingBeganWithTouch:touch];
    }
    else if (paintingMode == KKSPaintingModeFillColor) {
        self.paintingToFill = [self paintingContainedInAreaWithPoint:touchedLocation];
        if (self.paintingToFill) {
            self.isActive = YES;
            [self registerUndoForFillColorWithPainting:self.paintingToFill];
            [self.paintingToFill setFill:YES color:self.color];
        }
    }
    else if (paintingMode == KKSPaintingModePaste) {
        [self registerUndoForPaintingWithPaintings:[self.paintingModel.usedPaintings copy]];
        
        KKSPaintingBase *painting = [self.selectedPainting copy];
        CGPoint translation = translationBetweenPoints(self.firstTouchLocation, touchedLocation);
        [painting moveByIncreasingTranslation:translation];
        [self.paintingModel addPainting:painting];
        [self.paintingView needUpdatePaintings];
    }
    else {
        // Editing Mode
        [self updateSelectedPaintingWithPoint:touchedLocation];
        if (self.selectedPainting) {
            self.selectedPainting.shouldStrokePath = YES;
            
            if (paintingMode == KKSPaintingModeMove ||
                paintingMode == KKSPaintingModeRotateZoom) {
                self.isActive = YES;
                self.previousLocation = touchedLocation;
                self.firstTouchLocation = touchedLocation;
                
                if (paintingMode == KKSPaintingModeMove) {
                    [self registerUndoForMovingWithPainting:self.selectedPainting];
                }
                else if (paintingMode == KKSPaintingModeRotateZoom) {
                    [self registerUndoForRotatingZoomingWithPainting:self.selectedPainting];
                }
            }
            else if (paintingMode == KKSPaintingModeRemove) {
                [self registerUndoForPaintingWithPaintings:[self.paintingModel.usedPaintings copy]];
                [self.paintingModel removePainting:self.selectedPainting];
                self.selectedPainting.shouldStrokePath = NO;
//                [self redrawViewWithPaintings:self.paintingModel.usedPaintings];
            }
            else if (paintingMode == KKSPaintingModeCopy) {
                self.firstTouchLocation = touchedLocation;
            }
            
            [self.paintingView needUpdatePaintings];
        }
    }
}

- (void)paintingMovedWithTouch:(UITouch *)touch {
    CGPoint touchedLocation = [touch locationInView:self.paintingView];
    KKSPaintingMode paintingMode = self.paintingMode;
    
    if (paintingMode == KKSPaintingModePainting) {
        [self.painting recordingContinueWithTouchMoved:touch];
    }
    else if (self.selectedPainting) {
        if (paintingMode == KKSPaintingModeMove) {
            CGPoint translation = translationBetweenPoints(self.previousLocation, touchedLocation);
            [self.selectedPainting moveByIncreasingTranslation:translation];
            [self.paintingView needUpdatePaintings];
        }
        else if (paintingMode == KKSPaintingModeRotateZoom) {
            CGPoint origin = [self.selectedPainting pathCenterPoint];
            CGPoint initialPosition = self.previousLocation;
            
            CGFloat degree = degreeWithPoints(origin, initialPosition, touchedLocation);
            self.previousLocation = touchedLocation;
            [self.selectedPainting rotateAroundByIncreasingDegree:degree];

            CGPoint basicPoint = self.firstTouchLocation;
            CGFloat scale = scaleChangeBetweenPoints(origin, basicPoint, initialPosition, touchedLocation);

            [self.selectedPainting zoomAroundCenterByIncreasingCurrentScale:scale];

            [self.paintingView needUpdatePaintings];
        }
    }
    self.previousLocation = touchedLocation;
}

- (void)paintingEndWithTouch:(UITouch *)touch {
    if (self.paintingMode == KKSPaintingModePainting) {
        [self.painting recordingEndedWithTouch:touch];
        // make sure at least one point is recorded
        
        if (self.painting.isDrawingFinished) {
            [self.painting recordingEndedWithTouch:touch];
            [self.paintingModel addPainting:self.painting];
            self.painting = nil;
            self.isActive = NO;
            
            if ([self.paintingDelegate respondsToSelector:@selector(paintingManagerDidEndedPainting)]) {
                [self.paintingDelegate paintingManagerDidEndedPainting];
            }
        }
    }
    else if (self.paintingMode == KKSPaintingModeMove ||
             self.paintingMode == KKSPaintingModeRotateZoom) {
        if (self.selectedPainting) {
            self.selectedPainting.shouldStrokePath = NO;
//            [self updateCachedImageWithPaintingsAfterPainting:self.selectedPainting];
            
            [self.paintingView needUpdatePaintings];
            
            self.isActive = NO;
        }
    }
    else if (self.paintingMode == KKSPaintingModeFillColor) {
        if (self.paintingToFill) {
//            [self updateCachedImageWithPainting:self.paintingToFill
//                                    cachedImage:self.paintingModel.cachedImage];
            [self.paintingView needUpdatePaintings];
            self.isActive = NO;
            self.paintingToFill = nil;
        }
    }
    else if (self.paintingMode == KKSPaintingModeCopy) {
        if (self.selectedPainting) {
            if ([self.paintingDelegate respondsToSelector:@selector(paintingManagerDidCopyPainting)]) {
                [self.paintingDelegate paintingManagerDidCopyPainting];
            }
            [self clearSelectedPaintingStrokePath];
            self.paintingMode = KKSPaintingModePaste;
        }
    }
    else if (self.paintingMode == KKSPaintingModeRemove) {
        [self.paintingView needUpdatePaintings];
    }
}

#pragma mark - Painting

- (void)renewPainting {
    switch (self.paintingType) {
        case KKSPaintingTypePen:
            self.painting = [[KKSPaintingPen alloc] initWithView:self.paintingView];
            break;
        case KKSPaintingTypeLine:
            self.painting = [[KKSPaintingLine alloc] initWithView:self.paintingView];
            break;
        case KKSPaintingTypeRectangle:
            self.painting = [[KKSPaintingRectangle alloc] initWithView:self.paintingView];
            break;
        case KKSPaintingTypeEllipse:
            self.painting = [[KKSPaintingEllipse alloc] initWithView:self.paintingView];
            break;
        case KKSPaintingTypeSegments:
            self.painting = [[KKSPaintingSegments alloc] initWithView:self.paintingView];
            break;
        case KKSPaintingTypeBezier:
            self.painting = [[KKSPaintingBezier alloc] initWithView:self.paintingView];
            break;
        case KKSPaintingTypePolygon:
            self.painting = [[KKSPaintingPolygon alloc] initWithView:self.paintingView];
            break;
        default:
            break;
    }
    
    self.painting.delegate = self;
    [self.painting setLineWidth:self.lineWidth
                          color:self.color
                          alpha:self.alpha];
}

#pragma mark - Zoom

- (void)zoomAllPaintingsByScale:(CGFloat)scale {
    for (KKSPaintingBase *painting in self.paintingModel.usedPaintings) {
        [painting setBaseZoomScale:self.currentZoomScale];
        [painting zoomBySettingScale:scale];
    }
}

- (void)zoomByScale:(CGFloat)scale {

    CGFloat contentWidth = self.paintingModel.originalContentSize.width * scale;
    CGFloat contentHeight = self.paintingModel.originalContentSize.height * scale;

    [self.paintingView adjustFrameWithSize:CGSizeMake(contentWidth, contentHeight)];

    if (self.paintingView.backgroundView.image) {
        self.paintingView.zoomScale = scale;
    }

    [self zoomAllPaintingsByScale:scale];

    [self.paintingView needUpdatePaintings];

    self.currentZoomScale = scale;
}

#pragma mark - Undo & Redo & Clear

- (BOOL)canUndo {
    return ([self.undoManager canUndo] && !self.isActive);
}

- (BOOL)canClear {
    return !self.isActive;
}

- (BOOL)canRedo {
    return ([self.undoManager canRedo] && !self.isActive);
}

- (void)undo {
    [self.undoManager undo];
}

- (void)undoPainting:(id)object {
    
    [self registerUndoForPaintingWithPaintings:[self.paintingModel.usedPaintings copy]];
    
    NSArray *paintings = (NSArray *)object;
    self.paintingModel.usedPaintings = [NSMutableArray arrayWithArray:paintings];

    [self.paintingView needUpdatePaintings];
}

- (void)registerUndoForPaintingWithPaintings:(NSArray *)paintings {
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(undoPainting:)
                                      object:paintings];
}

- (void)undoMoving:(id)object {
    KKSPaintingBase *painting = object[KKSPaintingUndoKeyPainting];
    [self registerUndoForMovingWithPainting:painting];
    
    NSValue *newValue = object[KKSPaintingUndoKeyTranslation];
    CGPoint newTranslation = [newValue CGPointValue];

    [painting moveBySettingTranslation:newTranslation];

    [self.paintingView needUpdatePaintings];
}

- (void)registerUndoForMovingWithPainting:(KKSPaintingBase *)painting {
    CGPoint translation = [painting currentTranslation];
    NSValue *value = [NSValue valueWithCGPoint:translation];
    
    NSDictionary *dict = @{KKSPaintingUndoKeyPainting: painting,
                           KKSPaintingUndoKeyTranslation: value};
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(undoMoving:)
                                      object:dict];
}


- (void)undoRotatingZooming:(id)object {
    
    KKSPaintingBase *painting = object[KKSPaintingUndoKeyPainting];
    [self registerUndoForRotatingZoomingWithPainting:painting];
    
    NSNumber *degreeNumber = object[KKSPaintingUndoKeyDegree];
    CGFloat newDegree = [degreeNumber floatValue];
    NSNumber *scaleNumber = object[KKSPaintingUndoKeyZoomScale];
    CGFloat newScale = [scaleNumber floatValue];

    [painting rotateAroundCenterBySettingDegree:newDegree];
    [painting zoomAroundCenterBySettingScale:newScale];

    [self.paintingView needUpdatePaintings];
}

- (void)registerUndoForRotatingZoomingWithPainting:(KKSPaintingBase *)painting {
    CGFloat degree = [painting currentRotateDegree];
    CGFloat scale = [painting currentZoomScale];
    
    NSDictionary *dict = @{KKSPaintingUndoKeyPainting: painting,
                           KKSPaintingUndoKeyDegree: @(degree),
                           KKSPaintingUndoKeyZoomScale: @(scale)
    };
    
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(undoRotatingZooming:)
                                      object:dict];
}

- (void)undoFillColor:(id)object {
    KKSPaintingBase *painting = object[KKSPaintingUndoKeyPainting];
    [self registerUndoForFillColorWithPainting:painting];
    
    NSNumber *shouldFillValue = object[KKSPaintingUndoKeyShouldFill];
    BOOL shouldFill = [shouldFillValue boolValue];
    
    [painting setFill:shouldFill color:painting.fillColor];

    [self.paintingView needUpdatePaintings];
}

- (void)registerUndoForFillColorWithPainting:(KKSPaintingBase *)painting {
    BOOL shouldFill = painting.shouldFill;
    NSNumber *shouldFillValue = @(shouldFill);
    
    NSDictionary *dict = @{KKSPaintingUndoKeyPainting: painting,
                           KKSPaintingUndoKeyShouldFill: shouldFillValue,
                           KKSPaintingUndoKeyFillColor: painting.fillColor};
    
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(undoFillColor:)
                                      object:dict];
}

- (void)redo {
    [self.undoManager redo];
}

- (void)clear {
    if ([self canClear]) {
        [self.paintingModel removeAllPaintings];
        [self.undoManager removeAllActions];
        [self.paintingView needUpdatePaintings];
        self.painting = nil;
    }
}

- (BOOL)canChangePaintingState {
    return !self.isActive;
}

#pragma mark - KKSPaintingDelegate

- (void)drawingWillEndAutomatically {
    [self paintingFinish];
}

- (void)drawingDidEndNormally {
    [self.paintingView showIndicatorLabelWithText:@"绘制结束"];
}

- (void)paintingFinish {
    if (self.paintingMode == KKSPaintingModePainting &&
        !self.painting.isDrawingFinished &&
        ([self.painting isKindOfClass:[KKSPaintingSegments class]]
         || [self.painting isKindOfClass:[KKSPaintingPolygon class]]) &&
        self.isActive) {
        
        self.painting.isDrawingFinished = YES;

        [self.paintingView needUpdatePaintings];
        
        [self.paintingModel addPainting:self.painting];
        self.painting = nil;
        
        self.isActive = NO;
        
        if (self.paintingType == KKSPaintingTypePolygon ||
            self.paintingType == KKSPaintingTypeSegments) {
            [self.paintingView showIndicatorLabelWithText:@"绘制结束!"];
        }
        
        if ([self.paintingDelegate respondsToSelector:@selector(paintingManagerDidEndedPainting)]) {
            [self.paintingDelegate paintingManagerDidEndedPainting];
        }
    }
}

#pragma mark - drawing & Image Caching


- (void)redrawPaintingsFromSelectedPainting {
    NSInteger startIndex = [self.paintingModel.usedPaintings indexOfObject:self.selectedPainting];
    NSInteger count = [self.paintingModel.usedPaintings count];
    for (NSInteger index = startIndex; index<count; ++index) {
        KKSPaintingBase *painting = self.paintingModel.usedPaintings[index];
        [painting drawPath];
    }
}

- (UIImage *)imageBeforePaintingComplete:(KKSPaintingBase *)painting {
    NSInteger endIndex = [self.paintingModel.usedPaintings indexOfObject:painting];

    KKSViewBeginImageContextWithImage(self.paintingView);
    
    for (NSInteger index = 0; index<endIndex; ++index) {
        KKSPaintingBase *usedPainting = self.paintingModel.usedPaintings[index];
        [usedPainting drawPath];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark -

- (void)clearSelectedPaintingStrokePath {
    self.selectedPainting.shouldStrokePath = NO;
}

#pragma mark - 

- (BOOL)isPaintingModeEditing:(KKSPaintingMode)paintingMode {

    return (paintingMode == KKSPaintingModeRemove ||
            paintingMode == KKSPaintingModeCopy ||
            paintingMode == KKSPaintingModeRotateZoom ||
            paintingMode == KKSPaintingModeMove ||
            paintingMode == KKSPaintingModePaste);
}

#pragma mark - Background

- (void)setBackgroundImage:(UIImage *)image contentSize:(CGSize)size {
    self.paintingModel.backgroundImage = image;
    self.paintingModel.originalContentSize = size;
    [self.paintingView setBackgroundImage:image contentSize:size];
}

#pragma mark - Accessor & Setter

- (void)paintingViewDidChangeState {
    [self paintingFinish];
    
    if (self.paintingView.scrollEnabled) {
        self.paintingView.scrollEnabled = NO;
    }
}

- (void)setPaintingView:(KKSPaintingScrollView *)paintingView {
    paintingView.delegate = self;
    _paintingView = paintingView;
}

- (void)setPaintingType:(KKSPaintingType)paintingType {
    [self paintingViewDidChangeState];
    self.paintingMode = KKSPaintingModePainting;
    _paintingType = paintingType;
}

- (void)setPaintingMode:(KKSPaintingMode)paintingMode {
    
    if (_paintingMode == KKSPaintingModeNone) {
        self.paintingView.scrollEnabled = (paintingMode == KKSPaintingModeNone);
    }
    else {
        [self paintingViewDidChangeState];
    }

    if (_paintingMode != KKSPaintingModeMove &&
        paintingMode == KKSPaintingModeMove) {
        if ([self.paintingDelegate respondsToSelector:@selector(paintingManagerDidEnterEditingMode)]) {
            [self.paintingDelegate paintingManagerDidEnterEditingMode];
        }
    }
    else if ([self isPaintingModeEditing:_paintingMode] &&
        ![self isPaintingModeEditing:paintingMode]) {
        if ([self.paintingDelegate respondsToSelector:@selector(paintingManagerDidLeftEditingMode)]) {
            [self.paintingDelegate paintingManagerDidLeftEditingMode];
        }
    }

    _paintingMode = paintingMode;
}

- (void)setColor:(UIColor *)color {
    [self paintingViewDidChangeState];
    _color = color;
}

- (void)setAlpha:(CGFloat)alpha {
    [self paintingViewDidChangeState];
    _alpha = alpha;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    [self paintingViewDidChangeState];
    _lineWidth = lineWidth;
}

- (void)drawAllPaintings {
    for (KKSPaintingBase *painting in self.paintingModel.usedPaintings) {
        [painting drawPath];
    }
    
    if (self.painting) {
        [self.painting drawPath];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.paintingView.backgroundView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frame = self.paintingView.backgroundView.frame;
    frame.origin.x = (CGRectGetWidth(scrollView.frame) - CGRectGetWidth(self.paintingView.backgroundView.frame)) / 2.f;
    frame.origin.y = (CGRectGetHeight(scrollView.frame) - CGRectGetHeight(self.paintingView.backgroundView.frame)) / 2.f;
    self.paintingView.backgroundView.frame = frame;
}

@end
