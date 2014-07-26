//
//  SetPatingBgViewController.h
//  MagicPaint
//
//  Created by Robin W on 14-4-3.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KKSPaintingView;
@class KKSPaintingManager;
@interface SetPatingBgViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *paintWidth;
@property (weak, nonatomic) IBOutlet UITextField *paintHeight;
- (IBAction)setBg:(id)sender;
@property (strong, nonatomic) KKSPaintingView *drawerView;
@property (strong,nonatomic)KKSPaintingManager *paintingManager;
@end
