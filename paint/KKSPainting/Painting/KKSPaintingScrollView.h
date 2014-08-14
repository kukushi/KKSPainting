//
//  KKSDrawerView.h
//  Drawing Demo
//
//  Created by kukushi on 3/1/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKSPaintingManager;


@interface KKSPaintingScrollView : UIScrollView

@property (nonatomic, strong, readonly) KKSPaintingManager *paintingManager;

@property (nonatomic, weak) UIViewController *viewController;


- (void)setBackgroundImage:(UIImage *)image;


- (void)showIndicatorLabelWithText:(NSString *)text;

- (void)needUpdatePaintings;

- (void)needUpdatePaintingsInRect:(CGRect)rect;

@end



