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
#import "NearestSongMapViewController.h"
#import "GenreFilterViewController.h"
#import "SoundcloudLibraryViewController.h"
#import "SongSelectionProtocol.h"

@class SoundcloudLibraryViewController;

@interface NearestSongListViewController : UITableViewController<PlayerViewControllerProtocol,
                                                                 GenreFilterViewControllerProtocol,
                                                                 NearestSongMapViewControllerProtocol,
                                                                 SongSelectionProtocol>

@property (strong, nonatomic) PlayerViewController * playerViewController;
@property (strong, nonatomic) GenreFilterViewController * genreFilterViewController;
@property (strong, nonatomic) SoundcloudLibraryViewController * soundcloudLibraryViewController;
@property (strong, nonatomic) NearestSongMapViewController * nearestSongMapViewController;

@property (strong, nonatomic) NSArray * tracks;
@property (strong, nonatomic) AVAudioPlayer * player;
@property (strong, nonatomic) CLLocation * currentLocation;
@property (strong, nonatomic) NSDictionary * activeUser;
@property (strong, nonatomic) UIAlertView * networkAlert;

@property (strong, nonatomic) IBOutlet UITableView * tableView;

@property NSInteger currentSongPosition;
@property NSInteger reachability;

@end
