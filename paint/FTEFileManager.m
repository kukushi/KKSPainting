//
//  FTEFileManager.m
//  BangumiPush
//
//  Created by kukushi on 5/2/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "FTEFileManager.h"

@interface FTEFileManager ()

@end

@implementation FTEFileManager

+ (NSString *)pathWithFilename:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *basicURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *filePath = [NSString stringWithFormat:@"/%@", filename];
    NSString *filePathString = [[basicURL path] stringByAppendingString:filePath];
    return filePathString;
}

+ (BOOL)writeData:(NSData *)data toFile:(NSString *)filename {
    NSString *path = [self pathWithFilename:filename];
    BOOL result = [data writeToFile:path atomically:NO];
    return result;
}

+ (BOOL)writeObject:(NSObject *)object toFile:(NSString *)filename {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    BOOL result = [self writeData:data toFile:filename];
    return result;
}

+ (BOOL)fileExistsAtDirectoryWithFilename:(NSString *)filename {
    NSString *filePath = [self pathWithFilename:filename];
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return result;
}

+ (BOOL)removeFileAtDirectoryWithFilename:(NSString *)filename {
    NSString *path = [self pathWithFilename:filename];
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    return success;
}

+ (NSArray *)itemsInDirectory:(NSString *)directoryName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self pathWithFilename:directoryName?:@""];
    NSURL *URL = [NSURL fileURLWithPath:filePath];
    NSError *error;
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:URL
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:&error];
    if (!error) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in contents) {
            NSData *data = [NSData dataWithContentsOfURL:fileURL];
            if (data) {
                id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [items addObject:obj];
            }
        }
        return items;
    }
    return nil;
}

@end
