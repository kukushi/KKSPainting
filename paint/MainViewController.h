//
//  FirstViewController.h
//  paint
//
//  Created by Robin W on 14-2-28.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KKSPaintingScrollView.h"

@interface MainViewController : UIViewController<UIAccelerometerDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{

}
@property(strong,nonatomic)UIPanGestureRecognizer *panGes;//拖动对象
@property(assign,nonatomic)BOOL shouldShowSheet;

@property (weak, nonatomic) IBOutlet UIView *editBar;
- (IBAction)changeEditMode:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nowEditMode;

@property (weak, nonatomic) IBOutlet UIView *myTopBar;
@property (weak, nonatomic) IBOutlet UIView *myDownBar;
@property (weak, nonatomic) IBOutlet UIView *hiddenTools;
@property (weak, nonatomic) IBOutlet UIView *hiddenLineDegrees;
@property (weak, nonatomic) IBOutlet UIView *hiddenKeepAbout;
@property (weak, nonatomic) IBOutlet UIView *hiddenEditAbout;

@property (weak, nonatomic) IBOutlet KKSPaintingScrollView *drawerView;
@property (nonatomic, weak) KKSPaintingManager *paintingManager;


@property (weak, nonatomic) IBOutlet UIButton *selectedTool;
- (IBAction)selectedTool:(id)sender;
- (IBAction)lineTool:(id)sender;
- (IBAction)editTool:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *editTool;
- (IBAction)scrollPaint:(id)sender;
- (IBAction)editGraphic:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *selectedLine;
- (IBAction)selectedLine:(id)sender;
- (IBAction)lineDegree:(id)sender;

- (IBAction)keep:(id)sender;
- (IBAction)keepInPhoto:(id)sender;
- (IBAction)share:(id)sender;

//- (void)levelTimerCallback:(NSTimer *)timer;
- (IBAction)changeColor:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *addNameView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
- (IBAction)keepProject:(id)sender;
- (IBAction)cancelKeep:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *zoomSlider;

@property (weak, nonatomic) IBOutlet UIView *zoomView;
- (IBAction)zoomPaint:(id)sender;
- (IBAction)scrollingPaint:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *scrollButton;
@property(nonatomic,strong)NSUserDefaults *userDefaults;

@end
