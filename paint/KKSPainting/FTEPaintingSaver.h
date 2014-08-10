//
//  FTEPaintingStorer.h
//  MagicPaint
//
//  Created by kukushi on 8/10/14.
//  Copyright (c) 2014 Robin W. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FTEStoreCallback)(BOOL success);

@class KKSPaintingModel;

@interface FTEPaintingSaver : NSObject

/**
*  Store the view in the NSData format.
*  Not Executed in the main thread.
*
*  @param paintingModel model to be saved
*  @param name          name of the model
*  @param callback      callback will executed after store is complete
*/
+ (void)storePaintingManager:(KKSPaintingModel *)paintingModel
                        name:(NSString *)name
                    callback:(FTEStoreCallback)callback;

+ (NSArray *)retriveModels;

@end
