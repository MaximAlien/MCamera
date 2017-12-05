//
//  CameraHoverView.m
//  MCamera
//
//  Created by Maxim Makhun on 6/16/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

#import "CameraHoverView.h"

@implementation CameraHoverView

- (void)drawRect:(CGRect)rect {
    UIColor *backgroundColor = [UIColor blackColor];
    backgroundColor = [backgroundColor colorWithAlphaComponent:0.5f];
    [backgroundColor setFill];
    UIRectFill(rect);
    
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat height = UIScreen.mainScreen.bounds.size.height;
    
    CGRect transparentRect = CGRectMake(1.0f,
                                        height - width - width / 2.5f,
                                        width,
                                        width);
    
    CGRect holeRectIntersection = CGRectIntersection(transparentRect, rect);
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  height - width - width / 2.5f,
                                                                  width,
                                                                  width)];
    
    borderView.layer.borderColor = [UIColor whiteColor].CGColor;
    borderView.layer.borderWidth = 1.0f;
    borderView.backgroundColor = [UIColor clearColor];
    [self addSubview:borderView];
    
    [[UIColor clearColor] setFill];
    UIRectFill(holeRectIntersection);
}

@end
