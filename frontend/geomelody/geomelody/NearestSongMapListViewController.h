//
//  MasterViewController.h
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerViewController;

@interface NearestSongMapListViewController : UITableViewController

@property (strong, nonatomic) PlayerViewController *playerViewController;

@end
