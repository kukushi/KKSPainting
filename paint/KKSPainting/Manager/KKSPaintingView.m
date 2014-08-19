//
//  KKSPaintingView.m
//  MagicPaint
//
//  Created by kukushi on 8/12/14.
//  Copyright (c) 2014 Xing He All rights reserved.
//

#import "KKSPaintingView.h"

@interface KKSPaintingView ()

@property (nonatomic, strong) KKSDrawRectBlock drawRectBlock;

@end

@implementation KKSPaintingView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)needUpdatePaintingsWithBlock:(void (^)())block {
    self.drawRectBlock = block;
}

#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect {
    self.drawRectBlock();
}

@end
