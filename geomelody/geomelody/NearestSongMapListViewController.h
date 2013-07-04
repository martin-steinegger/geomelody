//
//  MasterViewController.h
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SongCell.h"
#import "PlayerViewController.h"


@class PlayerViewController;
@class GenreFilterViewController;

@interface NearestSongMapListViewController : UITableViewController<CLLocationManagerDelegate,PlayerViewControllerProtocol>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PlayerViewController *playerViewController;
@property (strong, nonatomic) GenreFilterViewController *genreFilterViewController;

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) AVAudioPlayer *player;

@property NSInteger currentSongPosition;


@end
