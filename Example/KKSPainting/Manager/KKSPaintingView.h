//
//  KKSPaintingView.h
//  MagicPaint
//
//  Created by kukushi on 8/12/14.
//  Copyright (c) 2014 Xing He All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KKSDrawRectBlock)();

@interface KKSPaintingView : UIView

- (void)needUpdatePaintingsWithBlock:(KKSDrawRectBlock)block;

@end
