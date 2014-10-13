//
//  AppDelegate.m
//  Ribbit
//
//  Created by Noah Teshu on 10/1/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //sleep for 1.5 without blocking the main thread
    [NSThread sleepForTimeInterval:1.5];
    [Parse setApplicationId:@"J8coVdeK4qQ5caknkVPTtpVYdLw2Bnt4gi1AOIR0"
                  clientKey:@"mafeP37zwEmFrVBGm9Ok7vcRUqPety2I1b9b5KRj"];
    [self customizeUserInterface];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Helper methods 

- (void)customizeUserInterface
{
    //changing bar tint color for all navigation bars within the app
//    [[UINavigationBar appearance]setBarTintColor:[UIColor colorWithRed:0.553 green:0.435 blue:0.718 alpha:1.0]];
    
    //background of nav bars will have image as a background (solid purple)
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"navBarBackground"] forBarMetrics:UIBarMetricsDefault];

    
    //text on the nav bars will be white (titles)
    [[UINavigationBar appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    //text on buttons on the nav bars will also be white
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    
    //customize tab bar
    //make images white
    [[UITabBar appearance]setTintColor:[UIColor whiteColor]];
    
    //make font of tab bar items white
    [[UITabBarItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    
    //get root view controller of app (tab bar controller in this case)
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    //get the tab bar from the root view controller
    UITabBar *tabBar = tabBarController.tabBar;
    
    UITabBarItem *tabInbox = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabFriends = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabCamera = [tabBar.items objectAtIndex:2];
    
    tabInbox.image = [[UIImage imageNamed:@"inbox"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabInbox.selectedImage = [[UIImage imageNamed:@"inbox"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabFriends.image = [[UIImage imageNamed:@"inbox"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabFriends.selectedImage = [[UIImage imageNamed:@"inbox"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabCamera.image = [[UIImage imageNamed:@"inbox"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabCamera.selectedImage = [[UIImage imageNamed:@"inbox"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    

    
    
}

@end
