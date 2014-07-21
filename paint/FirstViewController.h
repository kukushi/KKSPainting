//
//  FirstViewController.h
//  paint
//
//  Created by Robin W on 14-2-28.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KKSPaintingView.h"
#import "FAFancyMenuView.h"

@interface FirstViewController : UIViewController<UIAccelerometerDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,FAFancyMenuViewDelegate,UIScrollViewDelegate>
{
    //音频检测相关
	AVAudioRecorder *recorder;
	NSTimer *levelTimer;
	double lowPassResults;
}
@property(strong,nonatomic)UIPanGestureRecognizer *panGes;//拖动对象



@property (weak, nonatomic) IBOutlet UIView *myTopBar;
@property (weak, nonatomic) IBOutlet UIView *myDownBar;
@property (weak, nonatomic) IBOutlet UIView *hiddenTools;
@property (weak, nonatomic) IBOutlet UIView *hiddenLineDegrees;
@property (weak, nonatomic) IBOutlet UIView *hiddenKeepAbout;
@property (weak, nonatomic) IBOutlet UIView *hiddenEditAbout;

@property (weak, nonatomic) IBOutlet KKSPaintingView *drawerView;
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

- (void)levelTimerCallback:(NSTimer *)timer;
- (IBAction)changeColor:(id)sender;

@property(nonatomic,strong)NSUserDefaults *userDefaults;
@end
