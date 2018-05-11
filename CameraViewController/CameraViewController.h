//
//  CameraViewController.h
//  MCameraDemo
//
//  Created by Maxim Makhun on 5/11/18.
//  Copyright © 2018 Maxim Makhun. All rights reserved.
//

@import UIKit;

@protocol CameraViewControllerDelegate <NSObject>

- (void)imageSelected:(UIImage *)image;

@end

@interface CameraViewController : UIViewController

@property (nonatomic, weak) id<CameraViewControllerDelegate> delegate;

@end
