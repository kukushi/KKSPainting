//
//  FirstViewController.m
//  paint
//
//  Created by Robin W on 14-2-28.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import "MainViewController.h"
// #import <AVFoundation/AVFoundation.h>
#import "UMSocial.h"
#import "KKSPainting.h"

#define screenHeight [[UIScreen mainScreen] bounds].size.height
@interface MainViewController ()<KKSPaintingManagerDelegate>
{
    NSDate *LastMotion;
    NSString* filePath;//图片文件路径
}
@property (nonatomic, strong) FAFancyMenuView *menu;

@end

@implementation MainViewController
@synthesize panGes;

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.menu)
    {
        NSArray *images = @[[UIImage imageNamed:@"magnify.png"],[UIImage imageNamed:@"delete.png"],[UIImage imageNamed:@"copy.png"],[UIImage imageNamed:@"rotate.png"]];
        self.menu = [[FAFancyMenuView alloc] init];
        self.menu.delegate = self;
        self.menu.buttonImages = images;
        [self.drawerView addSubview:self.menu];
    }

    self.paintingManager = self.drawerView.paintingManager;
    self.drawerView.viewController = self;
    self.paintingManager.paintingDelegate = self;
    self.drawerView.delegate = self;
    self.paintingManager.paintingMode = KKSPaintingModePainting;
    
/*-------------------------------音频检测相关代码---------------------------*/
 
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
    
	NSError *error;
    
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
	if (recorder) {
        /*
		[recorder prepareToRecord];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
		recorder.meteringEnabled = YES;
		[recorder record];
		levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
         */
	} else
		NSLog(@"%@",[error description]);
/*-------------------------------音频检测相关代码---------------------------*/

    
   
    
    
/*-------------------------------颜色选择栏触摸相关---------------------------*/
    LastMotion=[NSDate date];
    self.myTopBar.userInteractionEnabled = YES;
    
    //注册触摸设置
    panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
    panGes.delegate=self;
    [panGes setEnabled:YES];
    [panGes delaysTouchesEnded];
    [panGes cancelsTouchesInView];
    [self.myTopBar addGestureRecognizer:panGes];
/*-------------------------------颜色选择栏触摸相关---------------------------*/
 

    
    
    
/*----------------------------加速计和距离传感器注册---------------------------*/
    //注册加速计，设置代理为自己
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = self;
    
    //注册近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];
/*----------------------------加速计和距离传感器注册---------------------------*/
}
-(void)viewWillAppear:(BOOL)animated
{
    if (self.drawerView.contentSize.width==0.0f) {
        [self.drawerView setContentSize:CGSizeMake(500.f, 1000.f)];
    }
}


#pragma mark    吹气相关
- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
   // NSLog(@"%f",lowPassResults);

	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
	if ([LastMotion timeIntervalSinceNow]<-1.2f)
    {
        LastMotion=[NSDate date]; //上次检测的时间设为现在时间
        if (lowPassResults >0.8)//数值越小越灵敏
        {
            NSLog(@"%f",lowPassResults);
            //在这里写吹气后执行的操作
            
            [self.paintingManager clear];

        }
    }
}

#pragma mark 改变线条颜色
- (IBAction)changeColor:(UIButton *)sender {
    self.paintingManager.color=sender.backgroundColor;

}

#pragma mark Redo undo相关
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //if ([LastMotion timeIntervalSinceNow]<-0.25f)
    //{
        LastMotion=[NSDate date]; //上次检测的时间设为现在时间
        if ([[UIDevice currentDevice] proximityState]) {
            //在此写接近时，要做的操作逻辑代码
            if (self.paintingManager.canUndo)
            {
                [self.paintingManager undo];


            }


        }else{

        }
    //}
}


#pragma mark 拖动上边栏
-(void)handelPan:(UIPanGestureRecognizer*)gestureRecognizer
{
    static BOOL right; //判断左右移动的标志
    CGPoint translatedPoint = [gestureRecognizer translationInView:self.myTopBar];
    if (fabs(translatedPoint.y)<fabs(translatedPoint.x))//如果为水平滑动
    {
        if (translatedPoint.x>0)
        {
            right=false;
        }
        else
        {
            right=true;
        }
        CGFloat y = self.myTopBar.center.y;
        CGFloat x = self.myTopBar.center.x + translatedPoint.x;
        if (x>-160+self.drawerView.bounds.origin.x&&x<480+self.drawerView.bounds.origin.x)
        {
            self.myTopBar.center = CGPointMake(x, y);
        }
    }
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.myTopBar];
    //意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加，很快你的view就会移除屏幕！
    static CGFloat CX;
    if (self.myTopBar.center.x<0+self.drawerView.bounds.origin.x) {
        CX=-160;
    }else if (self.myTopBar.center.x<320+self.drawerView.bounds.origin.x){
        CX=160;
    }else{
        CX=480;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)//如果拖动状态停止
    {
        CGFloat x;
        if (right)
        {
            if (CX==-160)
            {
                x=CX;
            }
            else
            {
                x=CX-320;
            }
        }
        else
            {
                if (CX==480)
                {
                    x=CX;
                }
                else
                {
                    x=CX+320;
                }
            }
        [UIView animateWithDuration:0.5 animations:^{
                self.myTopBar.center = CGPointMake(x
                                                   +self.drawerView.bounds.origin.x, 30+self.drawerView.bounds.origin.y);
            }];
    }
}



#pragma mark 陀螺仪相关
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    // 检测摇动, 1.5为轻摇，2.0为重摇
    

    if (fabsf(acceleration.x)>1.2||
        fabsf(acceleration.y)>1.2||
        fabsf(acceleration.z>1.2))
    {
        
        if ([LastMotion timeIntervalSinceNow]<-0.5f)
        {
            LastMotion=[NSDate date];
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"redo",@"显示/隐藏颜色栏",@"显示/隐藏工具栏",@"显示/隐藏全部", nil];
            [actionSheet showInView:self.drawerView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden  //隐藏状态栏
{
       return YES;
}



#pragma mark 选择绘制工具
/*----------------------------选择绘制工具---------------------------*/
- (IBAction)selectedTool:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [self.hiddenTools.layer addAnimation:animation forKey:nil];

    if (self.hiddenTools.hidden) {
        if (!self.hiddenKeepAbout.hidden)
        {
            self.hiddenKeepAbout.hidden=YES;
        }
        self.hiddenTools.hidden=NO;
    }
    else{
        self.hiddenTools.hidden=YES;
    }

}

- (IBAction)lineTool:(UIButton *)sender {
    [self.selectedTool setBackgroundImage:[sender backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];//更改选中工具图标
    self.paintingManager.paintingMode=KKSPaintingModePainting;
    switch ([sender.titleLabel.text intValue])
    {
        case 0:
            self.paintingManager.paintingType=KKSPaintingTypeEllipse;
            break;
        case 1:
            self.paintingManager.paintingType=KKSPaintingTypeBezier;
            break;
        case 2:
            self.paintingManager.paintingType=KKSPaintingTypeSegments;
            break;
        case 3:
            self.paintingManager.paintingType=KKSPaintingTypeLine;
            break;
        case 4:
            self.paintingManager.paintingType=KKSPaintingTypeRectangle;
            break;
        case 5:
            self.paintingManager.paintingType=KKSPaintingTypePolygon;
            break;
        case 6:
            self.paintingManager.paintingType=KKSPaintingTypePen;
            break;
        case 7:
            self.paintingManager.paintingMode=KKSPaintingModeFillColor;
            break;
        default:
            break;
    }
    
}
#pragma mark 编辑工具
- (IBAction)editTool:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [self.hiddenEditAbout.layer addAnimation:animation forKey:nil];
    if (self.hiddenEditAbout.hidden) {
        if (!self.hiddenLineDegrees.hidden)
        {
            self.hiddenLineDegrees.hidden=YES;
        }
        self.hiddenEditAbout.hidden=NO;
    }
    else{
        self.hiddenEditAbout.hidden=YES;
    }
}
- (IBAction)scrollPaint:(id)sender {
    [self.editTool setBackgroundImage:[sender backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];//更改选中工具图标
    BOOL enable = self.drawerView.scrollEnabled;
    enable ^= 1;
    self.drawerView.scrollEnabled = YES;
    self.hiddenEditAbout.hidden=YES;

}

- (IBAction)editGraphic:(id)sender {
    [self.editTool setBackgroundImage:[sender backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];//更改选中工具图标
    self.paintingManager.paintingMode=KKSPaintingModeSelection;
    self.hiddenEditAbout.hidden=YES;

}
-(void)paintingManagerDidSelectedPainting
{
    if (!self.menu.onScreen)
    {
        [self.menu show];

    }
}
-(void)paintingManagerDidLeftSelection
{
    [self.menu hide];
    NSLog(@"1111");
}

- (void)fancyMenu:(FAFancyMenuView *)menu didSelectedButtonAtIndex:(NSUInteger)index{
    NSLog(@"%i",index);
    switch (index)
    {
        case 0:
            self.paintingManager.paintingMode=KKSPaintingModeZoom;
            break;
        case 1:
            self.paintingManager.paintingMode=KKSPaintingModeRemove;
            break;
        case 2:
            self.paintingManager.paintingMode=KKSPaintingModeCopy;
            break;
        case 3:
            self.paintingManager.paintingMode=KKSPaintingModeRotate;
            break;
        default:
            break;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    self.myTopBar.frame=CGRectMake(scrollView.bounds.origin.x,scrollView.bounds.origin.y, self.myTopBar.bounds.size.width, self.myTopBar.bounds.size.height);
    self.myDownBar.frame=CGRectMake(scrollView.bounds.origin.x, screenHeight-self.myDownBar.bounds.size.height+scrollView.bounds.origin.y, self.myDownBar.bounds.size.width, self.myDownBar.bounds.size.height);
    
    self.hiddenTools.frame=CGRectMake(scrollView.bounds.origin.x, screenHeight-self.hiddenTools.bounds.size.height-60+scrollView.bounds.origin.y, self.hiddenTools.bounds.size.width, self.hiddenTools.bounds.size.height);
    self.hiddenKeepAbout.frame=CGRectMake(scrollView.bounds.origin.x, screenHeight-self.hiddenKeepAbout.bounds.size.height-60+scrollView.bounds.origin.y, self.hiddenKeepAbout.bounds.size.width, self.hiddenKeepAbout.bounds.size.height);
    self.hiddenEditAbout.frame=CGRectMake(242+scrollView.bounds.origin.x, screenHeight-self.hiddenEditAbout.bounds.size.height-60+scrollView.bounds.origin.y, self.hiddenEditAbout.bounds.size.width, self.hiddenEditAbout.bounds.size.height);

    self.hiddenLineDegrees.frame=CGRectMake(158+scrollView.bounds.origin.x, screenHeight-self.hiddenLineDegrees.bounds.size.height-60+scrollView.bounds.origin.y, self.hiddenLineDegrees.bounds.size.width, self.hiddenLineDegrees.bounds.size.height);
    
}

/*----------------------------选择绘制工具---------------------------*/



#pragma mark 选择线条长度
/*----------------------------选择线条长度---------------------------*/
- (IBAction)selectedLine:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [self.hiddenLineDegrees.layer addAnimation:animation forKey:nil];
    if (self.hiddenLineDegrees.hidden) {
        if (!self.hiddenEditAbout.hidden)
        {
            self.hiddenEditAbout.hidden=YES;
        }
        self.hiddenLineDegrees.hidden=NO;
    }
    else{
        self.hiddenLineDegrees.hidden=YES;
    }
}

- (IBAction)lineDegree:(UIButton *)sender {
    [self.selectedLine setBackgroundImage:[sender backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];//更改选中工具图标
    self.paintingManager.lineWidth=[sender.titleLabel.text intValue];
}
/*----------------------------选择线条长度---------------------------*/


#pragma mark 保存作品相关
/*----------------------------保存作品相关内容---------------------------*/
- (IBAction)keep:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [self.hiddenKeepAbout.layer addAnimation:animation forKey:nil];
    if (self.hiddenKeepAbout.hidden) {
        if (!self.hiddenTools.hidden)
        {
            self.hiddenTools.hidden=YES;
        }
        self.hiddenKeepAbout.hidden=NO;
    }
    else{
        self.hiddenKeepAbout.hidden=YES;
    }
}
//作品保存至本地
- (IBAction)keepInPhoto:(id)sender {
    self.hiddenKeepAbout.hidden=YES;

}
//作品分享到社交工具
- (IBAction)share:(id)sender {
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"507fcab25270157b37000010"
                                      shareText:@"你要分享的文字"
                                     shareImage:[UIImage imageNamed:@"share.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQzone,UMShareToQQ,UMShareToRenren,UMShareToDouban,UMShareToEmail,UMShareToSms,UMShareToFacebook,UMShareToTwitter,nil]
                                       delegate:nil];
    self.hiddenKeepAbout.hidden=YES;

}
//新建作品，可以载入，可以新建画布
- (IBAction)addFile:(id)sender {
        /*UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"新建"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:Nil
                                      otherButtonTitles:@"空白画布", @"从相册导入",nil];
        //actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];*/
    self.hiddenKeepAbout.hidden=YES;

    
}
//actionsheet项执行代码
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString:@"新建"])
    {
        if (buttonIndex == 0) {
            NSLog(@"0");
        }else if (buttonIndex == 1) {
            NSLog(@"1");
            [self LocalPhoto];
        }
    }
    else
    {
        if (buttonIndex==0)
        {
            if (self.paintingManager.canRedo)
            {
                [self.paintingManager redo];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"无撇销步骤" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else
            if (buttonIndex==1)
            {
                CATransition *animation = [CATransition animation];
                animation.type = kCATransitionFade;
                animation.duration = 0.25;
                [self.myTopBar.layer addAnimation:animation forKey:nil];
                if (self.myTopBar.hidden==NO)
                {
                    self.myTopBar.hidden=YES;
                }
                else
                {
                    self.myTopBar.hidden=NO;
                }
                //如果bar不显示就显示，显示则隐藏
            }
            else
                if (buttonIndex==2)
                {
                    CATransition *animation = [CATransition animation];
                    animation.type = kCATransitionFade;
                    animation.duration = 0.25;
                    [self.myDownBar.layer addAnimation:animation forKey:nil];
                    if (self.myDownBar.hidden==NO)
                    {
                        self.myDownBar.hidden=YES;
                    }
                    else
                    {
                        self.myDownBar.hidden=NO;
                    }
                    //如果bar不显示就显示，显示则隐藏
                }
                else
                    if (buttonIndex==3)
                    {
                        CATransition *animation = [CATransition animation];
                        animation.type = kCATransitionFade;
                        animation.duration = 0.25;
                        [self.myTopBar.layer addAnimation:animation forKey:nil];
                        [self.myDownBar.layer addAnimation:animation forKey:nil];
                        if (!self.myTopBar.hidden)
                        {
                            self.myTopBar.hidden=YES;
                            self.myDownBar.hidden=YES;
                        }
                        else
                        {
                            self.myTopBar.hidden=NO;
                            self.myDownBar.hidden=NO;
                        }

                    }

    }
}
//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker
                       animated:YES
                     completion:^(void){
                         // Code
                         
                     }];}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
        
        //得到选择后沙盒中图片的完整路径
        filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES
                                 completion:^(void){
                                     // Code
                                 }];


        [self.drawerView setBackgroundImage:image];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES
                             completion:^(void){
                                 // Code
                             }];
}
-(void)sendInfo
{
    NSLog(@"图片的路径是：%@", filePath);
    
}


//触碰其他位置隐藏工具扩展栏
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch =  [touches anyObject];
    if (touch.view!=self.hiddenTools&&touch.view!=self.hiddenLineDegrees&&touch.view!=self.hiddenKeepAbout)
    {
        if (!self.hiddenKeepAbout.hidden||!self.hiddenLineDegrees.hidden||!self.hiddenTools.hidden)
        {
            self.hiddenKeepAbout.hidden=YES;
            self.hiddenLineDegrees.hidden=YES;
            self.hiddenTools.hidden=YES;
        }

    }
    
 }

/*----------------------------保存作品相关内容---------------------------*/


- (CGContextRef)currentContext {
    
    return UIGraphicsGetCurrentContext();
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"setBg"]) {
        [[segue destinationViewController] setDrawerView:self.drawerView];
        [[segue destinationViewController] setPaintingManager:self.paintingManager];

    }
}

#pragma mark - Test

- (IBAction)undoChangeButtonFired:(id)sender {
    [self.paintingManager undo];
}


@end
