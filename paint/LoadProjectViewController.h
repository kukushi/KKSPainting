//
//  LoadProjectViewController.h
//  MagicPaint
//
//  Created by Robin W on 14-8-11.
//  Copyright (c) 2014年 Xing He All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainViewController;
@class KKSPaintingManager;
@interface LoadProjectViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *projectListTable;
@property(weak,nonatomic)KKSPaintingManager *paintingManage;
@property(weak,nonatomic)MainViewController *mainViewController;

@end
