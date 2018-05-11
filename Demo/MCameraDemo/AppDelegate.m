//
//  AppDelegate.m
//  MCameraDemo
//
//  Created by Maxim Makhun on 12/5/17.
//  Copyright © 2017 Maxim Makhun. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [MainViewController new];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
