//
//  FirstViewController.m
//  paint
//
//  Created by Robin W on 14-2-28.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import "MainViewController.h"
#import "FTEPaintingSaver.h"
#import "UMSocial.h"
#import "KKSPainting.h"
#import "SetPaintingBgViewController.h"
#import "LoadProjectViewController.h"
#import "KKSPaintingModel.h"
#import "KKSLog.h"

#define screenHeight [[UIScreen mainScreen] bounds].size.height
@interface MainViewController ()<KKSPaintingManagerDelegate>
{
    NSDate *LastMotion;
}
@property(nonatomic,strong)NSMutableArray *projectArray;
@property(nonatomic,strong)NSTimer *timer;
@property (nonatomic, strong) UILabel *indicatorLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation MainViewController
@synthesize panGes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.indicatorLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(57, 80, 206, 330)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.alpha = 0.f;
        label;
    });
    [self.view insertSubview:self.indicatorLabel aboveSubview:self.drawerView];

    
    
    
    self.nameTextField.delegate=self;

    self.shouldShowSheet=YES;

    self.paintingManager = self.drawerView.paintingManager;
    self.drawerView.viewController = self;
    self.paintingManager.paintingDelegate = self;
    self.drawerView.indicatorLabel=self.indicatorLabel;
    self.paintingManager.paintingMode = KKSPaintingModePainting;
    [self.drawerView.paintingManager setBackgroundImage:nil contentSize:CGSizeMake(320.f, screenHeight)];

    
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
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.delegate = self;
    
    //注册近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];
/*----------------------------加速计和距离传感器注册---------------------------*/
}
-(void)viewDidAppear:(BOOL)animated
{

    KKSDLog(@"appear");

    if (self.shouldShowSheet)
    {
        [self addFile:nil];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{

    KKSDLog(@"disappear");

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
            KKSDLog(@"across");
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.70 target:self selector:@selector(clearAllOperation) userInfo:nil repeats:NO];

        }else{
            if (self.paintingManager.canUndo)
            {
                [self.paintingManager undo];
            }
            KKSDLog(@"No across");
            [self.timer invalidate];
            self.timer=nil;
        }
    //}
}
-(void)clearAllOperation
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"是否清除所有操作？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清除", nil];
    [alert show];

}

#pragma mark 拖动上边栏
-(void)handelPan:(UIPanGestureRecognizer*)gestureRecognizer
{
    
    if (self.zoomView.hidden)
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
}



#pragma mark 陀螺仪相关
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    // 检测摇动, 1.5为轻摇，2.0为重摇
    

    if (fabsf(acceleration.x)>1.4||
        fabsf(acceleration.y)>1.4||
        fabsf(acceleration.z>1.4))
    {
        
        if ([LastMotion timeIntervalSinceNow]<-0.5f)
        {
            LastMotion=[NSDate date];
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"redo",@"显示/隐藏颜色栏",@"显示/隐藏工具栏",@"显示/隐藏全部" ,nil];
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
    self.nowEditMode.text=@"模式:绘制图元";
    self.zoomView.hidden=YES;
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
    self.hiddenTools.hidden=YES;
    
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
    self.hiddenEditAbout.hidden=YES;
    self.nowEditMode.text=@"模式:缩放画布";
    self.zoomView.hidden=NO;
    self.zoomView.hidden=NO;
    self.editBar.hidden=YES;
}

- (IBAction)editGraphic:(id)sender {
    [self.editTool setBackgroundImage:[sender backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];//更改选中工具图标
    self.drawerView.scrollEnabled = NO;
    self.paintingManager.paintingMode= KKSPaintingModeMove;
    self.hiddenEditAbout.hidden=YES;
    self.nowEditMode.text=@"模式:拖动图元";
    self.zoomView.hidden=YES;
    self.editBar.hidden=NO;
}

#pragma mark - 编辑菜单相关

//你在切换到编辑模式和离开编辑模式的时候给个委托方法，然后替换下面这两个。一个是进入编辑模式，一个是离开编辑模式
- (void)paintingManagerDidEnterEditingMode {
    self.editBar.hidden=NO;
    self.nowEditMode.text=@"模式:拖动图元";
}

- (void)paintingManagerDidLeftEditingMode {
    self.editBar.hidden=YES;
}
- (void)paintingManagerDidCopyPainting
{
    self.nowEditMode.text=@"模式:黏贴图元";

}



#pragma mark - UIScrollViewDelegate

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
    self.hiddenLineDegrees.hidden=YES;
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"保存"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:Nil
                                  otherButtonTitles:@"保存到相册", @"保存工程",nil];
    //actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    self.hiddenKeepAbout.hidden=YES;



}

//作品分享到社交工具
- (IBAction)share:(id)sender {
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"507fcab25270157b37000010"
                                      shareText:@"我正在使用MagicPaint作画哦，单手就能涂鸦实在太方便啦，快看看我的作品吧~"
                                     shareImage:[self.paintingManager.paintingModel previewImage]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToQzone,UMShareToRenren,UMShareToDouban,UMShareToEmail,UMShareToSms,UMShareToFacebook,UMShareToTwitter,nil]
                                       delegate:nil];
    self.hiddenKeepAbout.hidden=YES;
    self.shouldShowSheet=NO;
}
//新建作品，可以载入，可以新建画布
- (IBAction)addFile:(id)sender {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"新建"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:Nil
                                      otherButtonTitles:@"空白画布", @"加载工程",@"拍照涂鸦",nil];
        //actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
    self.hiddenKeepAbout.hidden=YES;

    
}
//actionsheet项执行代码
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.shouldShowSheet=NO;
    if ([actionSheet.title isEqualToString:@"新建"])
    {
        if (buttonIndex == 0) {
            SetPaintingBgViewController *patingBg=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"setBg"];
            patingBg.modalTransitionStyle=UIModalTransitionStylePartialCurl;
            patingBg.paintingManager=self.paintingManager;
            patingBg.drawerView=self.drawerView;
            patingBg.mainViewController=self;
            [self presentViewController:patingBg animated:YES completion:nil];
        }else if (buttonIndex == 1) {
            LoadProjectViewController *loadProjectViewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ProjectView"];
            loadProjectViewController.paintingManage=self.paintingManager;
            loadProjectViewController.mainViewController=self;
            loadProjectViewController.modalTransitionStyle=UIModalTransitionStylePartialCurl;
            [self presentViewController:loadProjectViewController animated:YES completion:nil];
        }else if(buttonIndex==2){
            UIImagePickerControllerSourceType sourceType =UIImagePickerControllerSourceTypeCamera;
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:nil];
            }
    }
    else if([actionSheet.title isEqualToString:@"保存"])
    {
        if (buttonIndex == 0) {
            UIImageWriteToSavedPhotosAlbum([self.paintingManager.paintingModel previewImage], nil, nil,nil);
            [self.drawerView showIndicatorLabelWithText:@"已保存到相册"];
            self.hiddenKeepAbout.hidden=YES;
        }else if (buttonIndex == 1) {
            self.addNameView.hidden=NO;
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            self.accelerometer.delegate = nil;
            [self.nameTextField becomeFirstResponder];
            self.projectArray=[[FTEPaintingSaver retrieveModels]mutableCopy];
            if (self.paintingManager.modelIndex!=-1)
            {
                KKSPaintingModel *model=[self.projectArray objectAtIndex:self.paintingManager.modelIndex];
                [self.nameTextField setText:[NSString stringWithFormat:@"%@",model.name]];
            }else
            {
                [self.nameTextField setText:[NSString stringWithFormat:@"工程%td号",[self.projectArray count]]];
            }
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex)
    {
        [self.paintingManager clear];
    }
}


//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        image=[self scaleToSize:image size:CGSizeMake(320,image.size.height/image.size.width*320)];
       // [self.drawerView setContentSize:CGSizeMake(320,image.size.height)];
        [self.paintingManager clear];
        self.paintingManager.modelIndex=-1;
        [self.drawerView.paintingManager setBackgroundImage:image contentSize:CGSizeMake(320,image.size.height)];
    }
    
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
         // 创建一个bitmap的context
     // 并把它设置成为当前正在使用的context
         UIGraphicsBeginImageContext(size);
         // 绘制改变大小的图片
         [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
         // 从当前context中创建一个改变大小后的图片
         UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
         // 使当前的context出堆栈
         UIGraphicsEndImageContext();
        // 返回新的改变大小后的图片
         return scaledImage;
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

#pragma mark - 改变编辑模式

- (IBAction)changeEditMode:(UIButton *)sender {
    switch (sender.tag)
    {
        case 0:
            self.paintingManager.paintingMode=KKSPaintingModeRemove;
            self.nowEditMode.text=@"模式:删除图元";
            break;
        case 1:
            self.paintingManager.paintingMode= KKSPaintingModeRotateZoom;
            self.nowEditMode.text=@"模式:旋转图元";
            break;
        case 2:
            self.paintingManager.paintingMode=KKSPaintingModeCopy;
            self.nowEditMode.text=@"模式:复制图元";
            break;
        case 3:
            self.paintingManager.paintingMode=KKSPaintingModeRotateZoom;
            self.nowEditMode.text=@"模式:缩放图元";
            break;
        case 4:
            self.paintingManager.paintingMode=KKSPaintingModeMove;
            self.nowEditMode.text=@"模式:拖动图元";
            break;
        default:
            break;
    }
}
- (IBAction)keepProject:(id)sender {
    BOOL isTheSameName=NO;
    for (KKSPaintingModel *model in self.projectArray)
    {
        if ([model.name isEqualToString:self.nameTextField.text])
        {
            isTheSameName=YES;
            KKSDLog(@"%@    /n %@",model.name,self.nameTextField.text);
        }
    }
    if (!self.nameTextField.text.length)
    {
        [[[UIAlertView alloc]initWithTitle:nil message:@"项目名不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
    else if (isTheSameName==YES&&self.paintingManager.modelIndex==-1)
    {
        [[[UIAlertView alloc]initWithTitle:nil message:@"工程名重复，请重新输入" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
    else
    {
        [FTEPaintingSaver storePaintingManager:[self.paintingManager paintingModel] name:[self.nameTextField text] callback:^(BOOL success) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"保存成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self.nameTextField resignFirstResponder];
            self.addNameView.hidden=YES;
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            self.accelerometer.delegate = self;
        }  ];
    }
    
}

- (IBAction)cancelKeep:(id)sender {
    self.addNameView.hidden=YES;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    self.accelerometer.delegate = self;
    [self.nameTextField resignFirstResponder];

}
#pragma mark 缩放
- (IBAction)zoomPaint:(UISlider *)sender {
    KKSDLog(@"%f",sender.value);
    self.drawerView.scrollEnabled=NO;
    [self.scrollButton setBackgroundImage:[UIImage imageNamed:@"hand.png"] forState:UIControlStateNormal];

    [self.paintingManager zoomByScale:sender.value];

}

- (IBAction)scrollingPaint:(UIButton *)sender {
    if (self.drawerView.scrollEnabled)
    {
        self.drawerView.scrollEnabled=NO;
        [sender setBackgroundImage:[UIImage imageNamed:@"hand.png"] forState:UIControlStateNormal];

    }else{
        self.drawerView.scrollEnabled=YES;
        [sender setBackgroundImage:[UIImage imageNamed:@"noScroll.png"] forState:UIControlStateNormal];


    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nameTextField resignFirstResponder];
}
@end
