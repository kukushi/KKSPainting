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

- (void)paintingManagerDidCopyPainting;

@end


@class KKSPaintingScrollView;

@interface KKSPaintingManager : NSObject <UIScrollViewDelegate>

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) UIColor *color;
@property (nonatomic) CGFloat alpha;

@property (nonatomic, weak) KKSPaintingScrollView *paintingView;

@property (nonatomic) KKSPaintingType paintingType;
@property (nonatomic) KKSPaintingMode paintingMode;
@property (nonatomic) NSInteger modelIndex;



@property (nonatomic, weak) id<KKSPaintingManagerDelegate> paintingDelegate;
// @property (nonatomic, strong) UILabel *indicatorLabel;

- (void)paintingBeginWithTouch:(UITouch *)touch;

- (void)paintingMovedWithTouch:(UITouch *)touch;

- (void)paintingEndWithTouch:(UITouch *)touch;

- (void)reloadManagerWithModel:(KKSPaintingModel *)paintingModel;

- (BOOL)canUndo;
- (void)undo;

- (BOOL)canRedo;
- (void)redo;

- (BOOL)canClear;
- (void)clear;

- (UIImage *)currentImage;

- (void)setBackgroundImage:(UIImage *)image contentSize:(CGSize)size;

- (void)zoomByScale:(CGFloat)scale;

- (void)paintingFinish;

- (BOOL)hasSelectedPainting;

- (void)drawAllPaintings;

- (KKSPaintingModel *)paintingModel;

@end
