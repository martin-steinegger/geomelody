//
//  AppDelegate.m
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "AppDelegate.h"
#import <PPRevealSideViewController.h>

#import "NearestSongListViewController.h"
#import "Reachability.h"

@implementation AppDelegate
Reachability *internetReachable;

@synthesize window = _window;
@synthesize revealSideViewController = _revealSideViewController;




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{


    //no shadows for navigationbar
    [[UINavigationBar appearance]setShadowImage:[[UIImage alloc] init]];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NearestSongListViewController *masterViewController = [[NearestSongListViewController alloc] initWithNibName:@"NearestSongListViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    _revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:nav];
    _revealSideViewController.delegate = self;
    


    
    self.window.rootViewController = _revealSideViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    //Internet check
    [[NSNotificationCenter defaultCenter] addObserver:masterViewController selector:@selector(reachabilityHasChanged:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];

    NetworkStatus remoteHostStatus = [internetReachable currentReachabilityStatus];
    [masterViewController setReachability:remoteHostStatus];

    [self.window makeKeyAndVisible];
 
    
    return YES;
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{

    return UIInterfaceOrientationMaskPortrait;
}

@end
