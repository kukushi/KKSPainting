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
#define screenHeight [[UIScreen mainScreen] bounds].size.height

@interface SetPaintingBgViewController ()

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
    if ([self.paintWidth.text intValue]<320||self.paintWidth.text.length<3)
    {
        self.paintWidth.text=@"320";
    }
    if ([self.paintHeight.text intValue]<[[NSString stringWithFormat:@"%.0f",screenHeight]intValue]||self.paintWidth.text.length<3)
    {
        self.paintHeight.text=[NSString stringWithFormat:@"%.0f",screenHeight];
    }
}
- (IBAction)setBg:(id)sender {
    NSLog(@"%f",self.drawerView.contentSize.width);
    [self.drawerView setContentSize:CGSizeMake([self.paintWidth.text floatValue],[self.paintHeight.text floatValue])];
    [self.paintingManager clear];
    [self.drawerView.paintingManager setPaintingBackground:self.bgImage];

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
        
        self.bgImage=image;
        if (image.size.width>=320)
        {
            self.paintWidth.text=[NSString stringWithFormat:@"%.0f",image.size.width];
        }

        if (image.size.height>=[[NSString stringWithFormat:@"%.0f",screenHeight]intValue])
        {
            self.paintHeight.text=[NSString stringWithFormat:@"%.0f",image.size.height];
        }
    }
    
}



- (IBAction)setBgImg:(id)sender {
    [self LocalPhoto];
}
@end
