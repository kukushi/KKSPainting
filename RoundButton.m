//
//  RoundButton.m
//  MagicPaint
//
//  Created by kukushi on 8/20/14.
//  Copyright (c) 2014 Robin W. All rights reserved.
//

#import "RoundButton.h"

@implementation RoundButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)willMoveToWindow:(UIWindow *)newWindow
{
    self.layer.masksToBounds=YES;
    self.layer.cornerRadius=4.5;
    self.layer.borderColor=[[UIColor clearColor]CGColor];
    self.layer.borderWidth=1.0;
}
@end
