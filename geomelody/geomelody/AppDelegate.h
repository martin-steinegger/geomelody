//
//  AppDelegate.h
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder  <UIApplicationDelegate, PPRevealSideViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) PPRevealSideViewController *revealSideViewController;

@end
