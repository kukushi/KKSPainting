//
//  SetPaintingBgViewController.h
//  MagicPaint
//
//  Created by Robin W on 14-4-3.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KKSPaintingScrollView;
@class KKSPaintingManager;
@class MainViewController;
@interface SetPaintingBgViewController : UIViewController<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *paintWidth;
@property (weak, nonatomic) IBOutlet UITextField *paintHeight;
- (IBAction)setBg:(id)sender;
@property (weak, nonatomic) KKSPaintingScrollView *drawerView;
@property (weak,nonatomic)KKSPaintingManager *paintingManager;
@property(nonatomic,strong)UIImage *bgImage;
- (IBAction)setBgImg:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property(weak,nonatomic)MainViewController *mainViewController;
@end
