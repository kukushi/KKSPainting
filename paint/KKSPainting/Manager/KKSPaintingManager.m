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
#import "KKSLog.h"

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

@property (nonatomic, strong) UILabel *indicatorLabel;

@property (nonatomic) BOOL isActive;

@property (nonatomic) BOOL canChangeContentSize;



@end

@implementation KKSPaintingManager

#pragma mark - Init

void KKSViewBeginImageContextWithImage(UIScrollView *view) {
    CGSize imageSize;
    if (CGSizeEqualToSize(CGSizeZero, view.contentSize)) {
        imageSize = view.bounds.size;
    }
    else {
        imageSize = view.contentSize;
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.f);
}

- (id)init {
    if (self = [super init]) {
        _lineWidth = 5.f;
        _alpha = 1.f;
        _color = [UIColor blackColor];
        _paintingModel = [[KKSPaintingModel alloc] init];
        _undoManager = [[NSUndoManager alloc] init];
        _modelIndex = -1;
    }
    return self;
}

#pragma mark -

- (void)reloadManagerWithModel:(KKSPaintingModel *)paintingModel {
    for (KKSPaintingBase *painting in paintingModel.usedPaintings) {
        painting.delegate = self;
        painting.view = self.paintingView;
    }
    
    self.paintingModel = paintingModel;
    self.painting = nil;
    self.selectedPainting = nil;
    self.paintingToFill = nil;
    self.undoManager = [[NSUndoManager alloc] init];
    [self.paintingView setBackgroundImage:paintingModel.backgroundImage
                              contentSize:self.paintingModel.originalContentSize];
    
    
    [self.paintingView needUpdatePaintings];
}

#pragma mark - Selected Painting

- (BOOL)hasSelectedPainting {
    return self.selectedPainting != nil;
}

- (void)updateSelectedPaintingWithPoint:(CGPoint)point {
    self.selectedPainting = nil;
    
    BOOL willSelectPainting = NO;
    for (KKSPaintingBase *painting in self.paintingModel.usedPaintings) {
        if ([painting pathContainsPoint:point]) {
            self.selectedPainting = painting;
            willSelectPainting = YES;
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
        [self updateCachedImageWithPainting:painting cachedImage:self.paintingModel.cachedImage];
        [self.paintingView needUpdatePaintings];
    }
    else {
        // Editing Mode
        [self updateSelectedPaintingWithPoint:touchedLocation];
        if (self.selectedPainting) {
            self.selectedPainting.shouldStrokePath = YES;
            [self redrawViewWithPaintings:self.paintingModel.usedPaintings];
            
            if (paintingMode == KKSPaintingModeMove ||
                paintingMode == KKSPaintingModeRotateZoom) {
                self.paintingModel.cachedImage = [self imageBeforePaintingComplete:self.selectedPainting];
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
                [self redrawViewWithPaintings:self.paintingModel.usedPaintings];
            }
            else if (paintingMode == KKSPaintingModeCopy) {
                self.firstTouchLocation = touchedLocation;
            }
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
            [self.selectedPainting rotateByIncreasingDegree:degree];

            CGPoint basicPoint = self.firstTouchLocation;
            CGFloat scale = scaleChangeBetweenPoints(origin, basicPoint, initialPosition, touchedLocation);

            [self.selectedPainting zoomByPlusCurrentScale:scale];

            KKSDLog("%f %f", degree, scale);

            [self.paintingView needUpdatePaintings];
        }
    }
    self.previousLocation = touchedLocation;
}

- (void)paintingEndWithTouch:(UITouch *)touch {
    if (self.paintingMode == KKSPaintingModePainting) {
        [self paintingMovedWithTouch:touch];
        // make sure at least one point is recorded
        
        self.paintingModel.cachedImage = [self.painting recordingEndedWithTouch:touch cachedImage:self.paintingModel.cachedImage];
        
        if (self.painting.isDrawingFinished) {
            
            [self.paintingModel addPainting:self.painting];
            
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
            [self updateCachedImageWithPaintingsAfterPainting:self.selectedPainting];
            
            [self.paintingView needUpdatePaintings];
            
            self.isActive = NO;

            // after editing end, mode should be changed to selection
            // self.paintingMode = KKSPaintingModeMove;
        }
    }
    else if (self.paintingMode == KKSPaintingModeFillColor) {
        if (self.paintingToFill) {
            [self updateCachedImageWithPainting:self.paintingToFill
                                    cachedImage:self.paintingModel.cachedImage];
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
        [painting zoomBySettingScale:scale];
    }
}

- (void)zoomByScale:(CGFloat)scale {
    /*
    if (CGSizeEqualToSize(self.paintingModel.originalContentSize, CGSizeZero)) {
        self.paintingModel.originalContentSize = self.paintingView.contentSize;
    }
    */

    CGFloat contentWidth = self.paintingModel.originalContentSize.width * scale;
    CGFloat contentHeight = self.paintingModel.originalContentSize.height * scale;

    [self setBackgroundImage:self.paintingModel.backgroundImage
                 contentSize:CGSizeMake(contentWidth,  contentHeight)];

    [self zoomAllPaintingsByScale:scale];
    [self redrawViewWithPaintings:self.paintingModel.usedPaintings];
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
    
    self.paintingModel.usedPaintings = [NSMutableArray arrayWithArray:object];
    
    [self redrawViewWithPaintings:paintings];
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
    
    [self redrawViewWithPaintings:self.paintingModel.usedPaintings];
    
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

    [painting rotateBySettingDegree:newDegree];
    [painting zoomBySettingScale:newScale];
    
    [self redrawViewWithPaintings:self.paintingModel.usedPaintings];
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
    
    [self redrawViewWithPaintings:self.paintingModel.usedPaintings];
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
        self.paintingModel.cachedImage = nil;
        [self.paintingView needUpdatePaintings];
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
        
        self.paintingModel.cachedImage = [self.painting endDrawingWithCacheImage:self.paintingModel.cachedImage];
        
        self.painting.isDrawingFinished = YES;
        
        [self.paintingModel addPainting:self.painting];
        
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

- (void)updateCachedImageWithPaintingsAfterPainting:(KKSPaintingBase *)painting {
    NSInteger startIndex = [self.paintingModel.usedPaintings indexOfObject:painting];
    NSInteger count = [self.paintingModel.usedPaintings count];

    KKSViewBeginImageContextWithImage(self.paintingView);
    [self.paintingModel.cachedImage drawAtPoint:CGPointZero];
    for (NSInteger index = startIndex; index<count; ++index) {
        KKSPaintingBase *usedPainting = self.paintingModel.usedPaintings[index];
        [usedPainting drawPath];
    }
    
    self.paintingModel.cachedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
}

- (void)redrawViewWithPaintings:(NSArray *)paintings {
    KKSViewBeginImageContextWithImage(self.paintingView);
    
    for (KKSPaintingBase *painting in paintings) {
        [painting drawPath];
    }
    
    self.paintingModel.cachedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.paintingView needUpdatePaintings];
}

- (void)updateCachedImageWithPainting:(KKSPaintingBase *)painting
                          cachedImage:(UIImage *)cachedImage {
    KKSViewBeginImageContextWithImage(self.paintingView);
    
    [cachedImage drawAtPoint:CGPointZero];
    
    [painting drawPath];
    
    self.paintingModel.cachedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

- (UIImage *)currentImage {
    return self.paintingModel.cachedImage;
}

#pragma mark -

- (void)clearSelectedPaintingStrokePath {
    self.selectedPainting.shouldStrokePath = NO;
    [self redrawViewWithPaintings:self.paintingModel.usedPaintings];
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
    [self.paintingModel.cachedImage drawAtPoint:CGPointZero];
    
    if (self.isActive) {
        if (self.paintingMode == KKSPaintingModePainting) {
            [self.painting drawPath];
        }
        else if (self.paintingMode == KKSPaintingModeMove ||
                 self.paintingMode == KKSPaintingModeRotateZoom) {
            [self redrawPaintingsFromSelectedPainting];
            
        }
    }
}

#pragma mark - UIScrollView Delegate

@end
