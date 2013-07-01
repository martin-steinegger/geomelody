//
//  MasterViewController.h
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongCell.h"

@class PlayerViewController;
@class TagFilterViewController;
@class GoToLibraryHeaderView;

@interface NearestSongMapListViewController : UITableViewController

@property (strong, nonatomic) PlayerViewController *playerViewController;
@property (strong, nonatomic) TagFilterViewController *tagFilterViewController;
@property (strong, nonatomic) GoToLibraryHeaderView *goToLibraryHeaderView;

- (void) setFilter:(NSMutableArray *)filterList;

@end
