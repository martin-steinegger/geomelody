//
//  AppDelegate.m
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "AppDelegate.h"

#import "NearestSongListViewController.h"
#import "SoundcloudLibraryViewController.h"
#import "Reachability.h"

@implementation AppDelegate
Reachability *internetReachable;

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize playerViewController;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
    //no shadows for navigationbar
    [[UINavigationBar appearance]setShadowImage:[[UIImage alloc] init]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NearestSongListViewController *masterViewController = [[NearestSongListViewController alloc] initWithNibName:@"NearestSongListViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    NearestSongMapViewController *songMapViewController = [[NearestSongMapViewController alloc] initWithNibName:@"NearestSongMapViewController" bundle:nil];
    [songMapViewController setDelegate:masterViewController];
    
    SoundcloudLibraryViewController * soundcloudLibraryViewController= [[SoundcloudLibraryViewController alloc] initWithNibName:@"SoundcloudLibraryViewController" bundle:nil];
    soundcloudLibraryViewController.delegate = masterViewController;
    
    playerViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    [playerViewController setDelegate:masterViewController];
    [masterViewController setPlayerViewController:playerViewController];
    [masterViewController setSoundcloudLibraryViewController:soundcloudLibraryViewController];
    
    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.viewControllers = [NSArray arrayWithObjects:navigationController, songMapViewController, playerViewController, soundcloudLibraryViewController, nil];
    
    self.window.rootViewController = _tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    //Internet check
    [[NSNotificationCenter defaultCenter] addObserver:masterViewController selector:@selector(reachabilityHasChanged:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];

    NetworkStatus remoteHostStatus = [internetReachable currentReachabilityStatus];
    [masterViewController setReachability:remoteHostStatus];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if(playerViewController.songItem != NULL){
            if (event.subtype == UIEventSubtypeRemoteControlPlay) {
                NSLog(@"playAudio");
                [playerViewController playAudio];
            } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
                NSLog(@"pauseAudio");
                [playerViewController pauseAudio];
            } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
                NSLog(@"togglePlayPause");
                [playerViewController togglePlayPause];
            } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
                NSLog(@"playNextSong");
                [playerViewController playNextSong:NULL];
            } else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
                NSLog(@"playPreviousSong");
                [playerViewController playPreviousSong:NULL];
            }
        }
    }
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
