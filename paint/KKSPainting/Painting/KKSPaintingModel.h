//
//  FTEPaintingStoreModel.h
//  MagicPaint
//
//  Created by kukushi on 8/10/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@class KKSPaintingManager;

@interface KKSPaintingModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSDate *createdDate;

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, copy) NSArray *usedPaintings;

@property (nonatomic, weak) KKSPaintingManager *paintingManager;

@property (nonatomic) CGSize originalContentSize;

- (void)removePainting:(id)painting;

- (void)addPainting:(id)painting;

- (void)removeAllPaintings;

- (UIImage *)previewImage;

@end
