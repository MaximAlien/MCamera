//
//  MainViewController.m
//  MCameraDemo
//
//  Created by Maxim Makhun on 12/5/17.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

#import "MainViewController.h"
#import "CameraViewController.h"

@interface MainViewController () <CameraViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *openCameraButton;
@property (nonatomic, strong) CameraViewController *cameraViewController;

@end

@implementation MainViewController

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleControls];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Styling methods

- (void)styleControls {
    self.openCameraButton.layer.cornerRadius = 10.0f;
    self.openCameraButton.backgroundColor = [UIColor blackColor];
    [self.openCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Action handlers

- (IBAction)openCamera:(id)sender {
    self.cameraViewController = [CameraViewController new];
    self.cameraViewController.delegate = self;
    [self presentViewController:self.cameraViewController animated:YES completion:nil];
}

#pragma mark - CameraViewControllerDelegate methods

- (void)imageSelected:(UIImage *)image {
    [self.cameraViewController dismissViewControllerAnimated:YES completion:^{
        // TODO: Save image
    }];
}

@end
