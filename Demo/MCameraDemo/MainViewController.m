//
//  MainViewController.m
//  MCameraDemo
//
//  Created by Maxim Makhun on 12/5/17.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

#import "MainViewController.h"
#import "CameraViewController.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)openCamera:(id)sender {
    CameraViewController *cameraViewController = [CameraViewController new];
    [self presentViewController:cameraViewController animated:YES completion:nil];
}

@end
