//
//  SetPaintingBgViewController.m
//  MagicPaint
//
//  Created by Robin W on 14-4-3.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import "SetPaintingBgViewController.h"
#import "KKSPaintingManager.h"
#import "KKSPaintingScrollView.h"
#import "MainViewController.h"
#define screenHeight [[UIScreen mainScreen] bounds].size.height

@interface SetPaintingBgViewController ()
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
@end

@implementation SetPaintingBgViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.paintHeight.text=[NSString stringWithFormat:@"%.0f",screenHeight];
    self.paintWidth.delegate=self;
    self.paintHeight.delegate=self;
    CALayer * layer = [self.bgImgView layer];
    layer.borderColor = [[UIColor lightGrayColor] CGColor];
    layer.borderWidth = 1.5f;
}
-(void)viewWillAppear:(BOOL)animated
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    self.mainViewController.accelerometer.delegate = nil;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    self.mainViewController.accelerometer.delegate = self.mainViewController;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.paintHeight resignFirstResponder];
    [self.paintWidth resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.paintWidth resignFirstResponder];
    [self.paintHeight resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    /*
    if ([self.paintWidth.text intValue]<320||self.paintWidth.text.length<3)
    {
        self.paintWidth.text=@"320";
    }
    if ([self.paintHeight.text intValue]<[[NSString stringWithFormat:@"%.0f",screenHeight]intValue]||self.paintWidth.text.length<3)
    {
        self.paintHeight.text=[NSString stringWithFormat:@"%.0f",screenHeight];
    }*/
}
- (IBAction)setBg:(id)sender {
//    NSLog(@"%f",self.drawerView.contentSize.width);
    // [self.paintingManager clear];
    CGSize contentSize = CGSizeMake([self.paintWidth.text floatValue],[self.paintHeight.text floatValue]);
    [self.drawerView.paintingManager setBackgroundImage:self.bgImage contentSize:contentSize];
    [self.drawerView.paintingManager reloadManagerWithImage:self.bgImage Size:contentSize];
    self.mainViewController.paintingManager.modelIndex=-1;
    [self.mainViewController.zoomSlider setValue:1.0f];
    [self dismissViewControllerAnimated:YES completion:nil];

}
#pragma  mark 改变画布背景
//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
   // picker.allowsEditing = YES;
    [self presentViewController:picker
                       animated:YES
                     completion:^(void){
                         // Code
                         
                     }];}

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
        self.bgImgView.image=image;
        
       //self.bgImage=[self scaleToSize:image size:CGSizeMake(image.size.width/2.0f, image.size.height/2.0f)];
        self.bgImage=image;
       // if (image.size.width>=320)
       // {
            self.paintWidth.text=[NSString stringWithFormat:@"%.0f",self.bgImage.size.width];
       // }

       // if (image.size.height>=[[NSString stringWithFormat:@"%.0f",screenHeight]intValue])
       //{
            self.paintHeight.text=[NSString stringWithFormat:@"%.0f",self.bgImage.size.height];
       // }*/
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


- (IBAction)setBgImg:(id)sender {
    [self LocalPhoto];
}
@end
