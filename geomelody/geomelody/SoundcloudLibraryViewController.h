//
//  SoundcloudLibraryViewController.h
//  geomelody
//
//  Created by admin on 08.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerViewController.h"
#import "NearestSongListViewController.h"
#import "SongSelectionProtocol.h"

@interface SoundcloudLibraryViewController : UIViewController <PlayerViewControllerProtocol,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate, SongSelectionProtocol>

@property (strong, nonatomic) id <PlayerViewControllerProtocol, SongSelectionProtocol> delegate;
@property (strong, nonatomic) PlayerViewController *playerViewController;
@property (nonatomic, strong) NSArray *tracks;
@property NSInteger currentSongPosition;

@property (weak, nonatomic) IBOutlet UISearchBar *search;
@property (weak, nonatomic) IBOutlet UISegmentedControl *librarySelector;
@property (weak, nonatomic) IBOutlet UITableView *libraryTableView;

- (IBAction)librarySelection:(id)sender;
@end
