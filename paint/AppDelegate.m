//
//  AppDelegate.m
//  paint
//
//  Created by Robin W on 14-2-28.
//  Copyright (c) 2014年 Robin W. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocial.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //[NSThread sleepForTimeInterval:2.0];   //设置进程停止3秒

    //友盟分享appkey
    [UMSocialData setAppKey:@"507fcab25270157b37000010"];
    
        
    
    return YES;
}

@end
