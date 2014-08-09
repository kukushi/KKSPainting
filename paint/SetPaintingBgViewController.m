//
//  SetPaintingBgViewController.m
//  MagicPaint
//
//  Created by Robin W on 14-4-3.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import "SetPaintingBgViewController.h"
#import "KKSPaintingManager.h"
#import "KKSPaintingView.h"

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

- (IBAction)setBg:(id)sender {
    NSLog(@"%f",self.drawerView.contentSize.width);
    if (![self.paintWidth.text length]||![self.paintWidth.text length])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"请输入大小" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        if ([self.paintWidth.text intValue]<=320||[self.paintWidth.text intValue]<=568)
        {
            [self.drawerView setContentSize:CGSizeMake(320,568)];
        }
        else
        {
            [self.drawerView setContentSize:CGSizeMake([self.paintWidth.text floatValue],[self.paintHeight.text floatValue])];
        }
        [self.paintingManager clear];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

@end
