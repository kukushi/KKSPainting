//
//  LoadProjectViewController.m
//  MagicPaint
//
//  Created by Robin W on 14-8-11.
//  Copyright (c) 2014年 Xing He All rights reserved.
//

#import "LoadProjectViewController.h"
#import "FTEPaintingSaver.h"
#import "KKSPaintingModel.h"
#import "KKSPaintingManager.h"
#import "MainViewController.h"
@interface LoadProjectViewController ()
@property(nonatomic,strong)NSArray *colorArray;
@property(nonatomic,strong)NSMutableArray *projectArray;
@end

@implementation LoadProjectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.projectListTable.delegate=self;
    self.projectListTable.dataSource=self;
    UIColor *color1=[UIColor colorWithRed:181.0f/255 green:239.0f/255 blue:155.0f/255 alpha:1.0];
    UIColor *color3=[UIColor colorWithRed:253.0f/255 green:245.0f/255 blue:161.0f/255 alpha:1.0];
    UIColor *color4=[UIColor colorWithRed:178.0f/255 green:225.0f/255 blue:250.0f/255 alpha:1.0];
    UIColor *color2=[UIColor colorWithRed:255.0f/255 green:185.0f/255 blue:173.0f/255 alpha:1.0];
    self.colorArray=[[NSArray alloc]initWithObjects:color1,color2,color3,color4, nil];
    self.projectArray=[[FTEPaintingSaver retrieveModels]mutableCopy];
	// Do any additional setup after loading the view.
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
    KKSPaintingModel *model=[self.projectArray objectAtIndex:[indexPath row]];
    
    UILabel *colorLabel=(UILabel *)[cell viewWithTag:100];
    colorLabel.backgroundColor=[self.colorArray objectAtIndex:[indexPath row]%4];
    
    UILabel *nameLabel=(UILabel *)[cell viewWithTag:101];
    nameLabel.text=model.name;
    
    UILabel *dateLabel=(UILabel *)[cell viewWithTag:102];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    dateLabel.text=[dateFormatter stringFromDate:model.createdDate];
    
    UIImageView *imageView=(UIImageView *)[cell viewWithTag:103];
    CALayer * layer = [imageView layer];
    layer.borderColor = [[UIColor lightGrayColor] CGColor];
    layer.borderWidth = 3.0f;
    imageView.image=model.previewImage;
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projectArray count];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
//右滑删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        UILabel *nameOfDeleteCell=(UILabel *)[[tableView cellForRowAtIndexPath:indexPath]viewWithTag:101];
        [FTEPaintingSaver deletePaintingWithName:nameOfDeleteCell.text];
        [self.projectArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];


    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.paintingManage reloadManagerWithModel:[self.projectArray objectAtIndex:[indexPath row]]];
    [self.projectListTable deselectRowAtIndexPath:indexPath animated:YES];
    self.paintingManage.modelIndex=[indexPath row];
    [self.mainViewController.zoomSlider setValue:1.0f];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
