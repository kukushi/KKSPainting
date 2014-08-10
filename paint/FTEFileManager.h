//
//  FTEFileManager.h
//  BangumiPush
//
//  Created by kukushi on 5/2/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTEFileManager : NSObject

+ (NSString *)pathWithFilename:(NSString *)fileName;

+ (BOOL)writeData:(NSData *)data toFile:(NSString *)filename;

+ (BOOL)writeObject:(NSObject *)object toFile:(NSString *)filename;

+ (BOOL)fileExistsAtDirectoryWithFilename:(NSString *)filename;

+ (BOOL)removeFileAtDirectoryWithFilename:(NSString *)filename;

+ (NSArray *)itemsInDirectory:(NSString *)directoryName;

@end
