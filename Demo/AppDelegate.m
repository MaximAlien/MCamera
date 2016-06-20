//
//  AppDelegate.m
//  Demo
//
//  Created by Maxim Makhun on 6/16/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[MainViewController new]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
