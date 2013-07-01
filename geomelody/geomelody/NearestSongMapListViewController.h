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


@class PlayerViewController;
@class TagFilterViewController;
@class GoToLibraryHeaderView;

@interface NearestSongMapListViewController : UITableViewController<CLLocationManagerDelegate> 
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PlayerViewController *playerViewController;
@property (strong, nonatomic) TagFilterViewController *tagFilterViewController;
@property (strong, nonatomic) GoToLibraryHeaderView *goToLibraryHeaderView;

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSArray *tagFilter;

- (void) setFilter:(NSMutableArray *)filterList;

@end
