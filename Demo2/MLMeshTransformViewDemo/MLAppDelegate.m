//
//  MLAppDelegate.m
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 11/05/14.
//  Copyright (c) 2014 Gavin Xiang. All rights reserved.
//

#import "MLAppDelegate.h"

#import "MLDemoTableViewController.h"


@implementation MLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    MLDemoTableViewController *tableViewController = [MLDemoTableViewController new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navController;

    [self.window makeKeyAndVisible];
    
    self.window.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    
    return YES;
}


@end
