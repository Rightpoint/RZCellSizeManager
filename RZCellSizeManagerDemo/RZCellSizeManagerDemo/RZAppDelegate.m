//
//  RZAppDelegate.m
//  RZCellSizeManagerDemo
//
//  Created by Alex Rouse on 12/20/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZAppDelegate.h"


#import "RZRootViewController.h"

@implementation RZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController* tableVC = [[RZRootViewController alloc] init];
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:tableVC];
    [self.window setRootViewController:navVC];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
