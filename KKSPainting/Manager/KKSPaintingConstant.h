//
//  KKSPaintingConstant.h
//  Drawing Demo
//
//  Created by kukushi on 4/2/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#ifndef Drawing_Demo_KKSPaintingConstant_h
#define Drawing_Demo_KKSPaintingConstant_h

typedef NS_ENUM(NSInteger, KKSPaintingMode) {
    // you can scroll only in this mode
    KKSPaintingModeNone,

    // Drawing Mode
    KKSPaintingModePainting,
    KKSPaintingModeFillColor,

    // Editing Mode
    KKSPaintingModeMove,

    KKSPaintingModeRotateZoom,
    KKSPaintingModeRemove,
    KKSPaintingModeCopy,
    KKSPaintingModePaste,
};

typedef NS_ENUM(NSInteger, KKSPaintingType) {
    KKSPaintingTypePen,
    KKSPaintingTypeLine,
    KKSPaintingTypeSegments,
    KKSPaintingTypeRectangle,
    KKSPaintingTypeEllipse,
    KKSPaintingTypeBezier,
    KKSPaintingTypePolygon,
};

#endif
