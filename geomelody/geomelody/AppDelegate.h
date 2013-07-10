//
//  AppDelegate.h
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PlayerViewController.h"
#import "NearestSongListViewController.h"

@interface AppDelegate : UIResponder  <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) PlayerViewController *playerViewController;
@property (strong, nonatomic) NearestSongListViewController *nearestSongListViewController;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
