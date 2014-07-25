//
//  KKSLog.h
//  Drawing Demo
//
//  Created by kukushi on 3/16/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#ifndef Drawing_Demo_KKSLog_h
#define Drawing_Demo_KKSLog_h

#ifdef DEBUG
#   define KKSDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define KKSDLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define KKSALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#endif
