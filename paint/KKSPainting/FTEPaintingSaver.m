//
//  FTEPaintingStorer.m
//  MagicPaint
//
//  Created by kukushi on 8/10/14.
//  Copyright (c) 2014 Robin W. All rights reserved.
//

#import "FTEPaintingSaver.h"
#import "FTEFileManager.h"
#import "KKSPaintingModel.h"

@implementation FTEPaintingSaver

+ (void)storePaintingManager:(KKSPaintingModel *)paintingModel
                        name:(NSString *)name
                    callback:(FTEStoreCallback)callback {
    NSString *filePath = [FTEFileManager pathWithFilename:name];
    
    paintingModel.name = name;
    paintingModel.createdDate = [NSDate date];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL writeDataSuccess = [NSKeyedArchiver archiveRootObject:paintingModel toFile:filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(writeDataSuccess);
        });
    });
}

+ (NSArray *)retriveModels {
    return [FTEFileManager itemsInDirectory:nil];
}

+ (BOOL)deletePaintingWithName:(NSString *)name {
    return [FTEFileManager deleteFileWithName:name];
}

@end
