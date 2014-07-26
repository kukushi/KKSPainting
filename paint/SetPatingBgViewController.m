//
//  SetPatingBgViewController.m
//  MagicPaint
//
//  Created by Robin W on 14-4-3.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import "SetPatingBgViewController.h"
#import "KKSPaintingManager.h"
#import "KKSPaintingView.h"

@interface SetPatingBgViewController ()

@end

@implementation SetPatingBgViewController

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
	// Do any additional setup after loading the view.
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
- (IBAction)backtoPaint:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
