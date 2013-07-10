//
//  SoundcloudLibraryViewController.h
//  geomelody
//
//  Created by admin on 08.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerViewController.h"

@class PlayerViewController;

@interface SoundcloudLibraryViewController : UIViewController <PlayerViewControllerProtocol,UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) id <PlayerViewControllerProtocol> delegate;
@property (strong, nonatomic) PlayerViewController *playerViewController;
@property (nonatomic, strong) NSArray *tracks;
@property NSInteger currentSongPosition;

@property (weak, nonatomic) IBOutlet UISearchBar *search;
@property (weak, nonatomic) IBOutlet UISegmentedControl *librarySelector;

- (IBAction)librarySelection:(id)sender;

@end
