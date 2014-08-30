//
//  FTEViewController.m
//  PaintExample
//
//  Created by kukushi on 8/29/14.
//  Copyright (c) 2014 Xing He. All rights reserved.
//

#import "FTEViewController.h"
#import "KKSPainting.h"

typedef NS_ENUM(NSInteger, FTEPopupType) {
    FTEPopupTypeNone,
    FTEPopupTypePainting,
    FTEPopupTypeLineWidth,
    FTEPopupTypePan,
    FTEPopupTypeEditing
};

@interface FTEViewController () <KKSPaintingManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet KKSPaintingScrollView *paintingView;

@property (nonatomic, weak) KKSPaintingManager *paintingManager;
@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic) FTEPopupType selectionType;
@property (weak, nonatomic) IBOutlet UICollectionView *popupView;

@end

@implementation FTEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.paintingManager = self.paintingView.paintingManager;
    self.paintingView.viewController = self;
    self.paintingManager.paintingDelegate = self;
    
    self.paintingManager.paintingMode = KKSPaintingModePainting;
    
    [self.paintingManager setBackgroundImage:nil contentSize:self.paintingView.bounds.size];
}

- (IBAction)changePaintingColor:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        UIColor *backgroundColor = button.backgroundColor;
        self.paintingManager.color = backgroundColor;
    }
}

- (IBAction)changePaintingType:(id)sender {
    self.selectionType = FTEPopupTypePainting;
}

- (IBAction)changeLineWidthType:(id)sender {
    self.selectionType = FTEPopupTypeLineWidth;
}

- (IBAction)changePanType:(id)sender {
    self.selectionType = FTEPopupTypePan;
}

- (IBAction)changeEditingType:(id)sender {
    self.selectionType = FTEPopupTypeEditing;
}

- (void)changePopupType:(FTEPopupType)selectionType {
    if (selectionType == FTEPopupTypePainting) {
        self.dataSourceArray = @[[UIImage imageNamed:@"PencilIcon"],
                                 [UIImage imageNamed:@"lineWidth"],
                                 [UIImage imageNamed:@"Segment"],
                                 [UIImage imageNamed:@"rectangle"],
                                 [UIImage imageNamed:@"ellipse"],
                                 [UIImage imageNamed:@"bezier"],
                                 [UIImage imageNamed:@"polygon"]];
    }
    else if (selectionType == FTEPopupTypeLineWidth) {
        self.dataSourceArray = @[[UIImage imageNamed:@"degree1"],
                                 [UIImage imageNamed:@"degree2"],
                                 [UIImage imageNamed:@"degree3"],
                                 [UIImage imageNamed:@"degree4"],
                                 [UIImage imageNamed:@"degree5"],
                                 [UIImage imageNamed:@"degree6"]];
    }
    else if (selectionType == FTEPopupTypePan){
        self.dataSourceArray = @[[UIImage imageNamed:@"select"],
                                 [UIImage imageNamed:@"rotate"],
                                 [UIImage imageNamed:@"delete"]];
    }
    else if (selectionType == FTEPopupTypeEditing) {
        self.dataSourceArray = @[[UIImage imageNamed:@"back"],
                                 [UIImage imageNamed:@"forward"],
                                 [UIImage imageNamed:@"clear"]];
    }
}

- (void)setSelectionType:(FTEPopupType)selectionType {
    if (_selectionType != selectionType) {
        _selectionType = selectionType;
        [self changePopupType:selectionType];
    }
    else {
        self.dataSourceArray = nil;
        self.selectionType = FTEPopupTypeNone;
    }
    [self.popupView reloadData];
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.selectionType) {
        case FTEPopupTypePainting: {
            self.paintingManager.paintingType = indexPath.item;
        }
            break;
        
        case FTEPopupTypeLineWidth: {
            self.paintingManager.lineWidth = indexPath.item * 4;
        }
            break;
        
        case FTEPopupTypePan: {
            self.paintingManager.paintingMode = KKSPaintingModeMove + indexPath.item;
        }
            break;
        case FTEPopupTypeEditing: {
            NSInteger index = indexPath.item;
            if (!index) {
                [self.paintingManager undo];
            }
            else if (index == 1) {
                [self.paintingManager redo];
            }
            else if (index == 2) {
                [self.paintingManager clear];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSourceArray count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PopupCollectionView"
                                                                           forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:664];
    imageView.image = self.dataSourceArray[indexPath.item];
    return cell;
}



@end
