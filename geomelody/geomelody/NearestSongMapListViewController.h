//
//  MasterViewController.h
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SongCell.h"
#import "PlayerViewController.h"


@class PlayerViewController;
@class TagFilterViewController;
@class GoToLibraryHeaderView;

@interface NearestSongMapListViewController : UITableViewController<CLLocationManagerDelegate,PlayerViewControllerProtocol>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PlayerViewController *playerViewController;
@property (strong, nonatomic) TagFilterViewController *tagFilterViewController;
@property (strong, nonatomic) GoToLibraryHeaderView *goToLibraryHeaderView;
@property (strong,nonatomic) NSArray *tracks;
@property (strong,nonatomic) CLLocation   *currentLocation;
@property (strong,nonatomic) NSDictionary *activeUser;

@property NSInteger currentSongPosition;


@end
