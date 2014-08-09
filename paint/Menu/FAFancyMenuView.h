//
//  FAFancyMenuView.h
//  paint
//
//  Created by Robin W on 14-2-28.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAFancyButton.h"
@class FAFancyMenuView;
@protocol FAFancyMenuViewDelegate <NSObject>
- (void)fancyMenu:(FAFancyMenuView *)menu didSelectedButtonAtIndex:(NSUInteger)index;
@end

@interface FAFancyMenuView : UIView
@property (nonatomic, assign) id<FAFancyMenuViewDelegate> delegate;
@property (nonatomic, strong) NSArray *buttonImages;
@property (nonatomic) BOOL onScreen;
@property(nonatomic,strong)UILongPressGestureRecognizer *longPress;
- (void)show;
- (void)hide;
- (void)addGestureRecognizerForView:(UIView *)view;
@property(nonatomic)CGPoint showInPoint;
@end

