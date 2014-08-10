//
//  KKSPaintingManager.h
//  Drawing Demo
//
//  Created by kukushi on 4/2/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKSPaintingConstant.h"

@class  KKSPaintingModel;

@protocol KKSPaintingManagerDelegate <NSObject>

@optional
- (void)paintingManagerWillBeginPainting;

- (void)paintingManagerDidEndedPainting;

- (void)paintingManagerDidEnterEditingMode;

- (void)paintingManagerDidLeftEditingMode;

- (void)paintingmanagerDidCopyPainting;

@end


@class KKSPaintingView;

@interface KKSPaintingManager : NSObject

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) UIColor *color;
@property (nonatomic) CGFloat alpha;

@property (nonatomic) BOOL canZoom;

@property (nonatomic, weak) KKSPaintingView *paintingView;

@property (nonatomic) KKSPaintingType paintingType;
@property (nonatomic) KKSPaintingMode paintingMode;


@property (nonatomic, weak) id<KKSPaintingManagerDelegate> paintingDelegate;

- (void)paintingBeginWithTouch:(UITouch *)touch;

- (void)paintingMovedWithTouch:(UITouch *)touch;

- (void)paintingEndWithTouch:(UITouch *)touch;

- (BOOL)canUndo;
- (void)undo;

- (BOOL)canRedo;
- (void)redo;

- (BOOL)canClear;
- (void)clear;

- (UIImage *)currentImage;

- (void)zoomByScale:(CGFloat)scale;

- (void)paintingFinish;

- (BOOL)hasSelectedPainting;

- (void)drawAllPaintings;

- (KKSPaintingModel *)paintingModel;

@end
