//
//  SoundcloudLibraryViewController.m
//  geomelody
//
//  Created by admin on 08.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "SoundcloudLibraryViewController.h"
#import "SongCell.h"
#import "PlayerViewController.h"
#import "SCUI.h"

@interface SoundcloudLibraryViewController ()

@end

@implementation SoundcloudLibraryViewController

@synthesize tracks;
@synthesize playerViewController;
@synthesize currentSongPosition;
@synthesize search;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"103-map" ofType:@"png"]];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:img tag:0];
        self.title = @"Search";
    }
    
    return self;
}

// load songs for tab selection: all music/only my music
- (void) loadSongs {
    
    NSString *searchString = search.text;
    
    //todo: connection to tabs
    
    // do request for SoundCloud
    // like https://api.soundcloud.com/tracks.json?client_id=f0cfa9035abc5752e699580d5586d1e6&sharing=public&ids=41558714,13158665
    NSMutableDictionary *requestParameter = [NSMutableDictionary dictionary];
    [requestParameter setObject:@"public"  forKey:@"sharing"];
    //todo
    //[requestParameter setObject:ids_string forKey:@"ids"];
    
    SCAccount *account = [SCSoundCloud account];
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            //todo
            
            //tracks = [self mergeData:(NSArray *)jsonResponse backEndTracks:backendSongArray];
            //[self.tableView reloadData];
        }
    };
    NSString *resourceURL = @"https://api.soundcloud.com/tracks.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:requestParameter
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //change background of navigation bar to black
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[SongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}


// change to PlayerView, which is initialised with the defined song object
- (void) showPlayer:(NSDictionary*)song {
    if (!playerViewController) {
        playerViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
        playerViewController.delegate = self;
    }
    [playerViewController setSongItem:song];
    [self.navigationController pushViewController:self.playerViewController animated:YES];
}


// delegate methods ***

- (id)getPreviousEntry {
    self.currentSongPosition--;
    self.currentSongPosition=MAX(self.currentSongPosition, 0);
    return tracks[self.currentSongPosition];
}

- (id)getNextEntry {
    self.currentSongPosition++;
    self.currentSongPosition=MIN(self.currentSongPosition, [tracks count]-1);
    return tracks[self.currentSongPosition];
}

- (id)getCurrentGeoPosition {
    return [self.delegate getCurrentGeoPosition];
}

- (id)getActiveUser {
    return [self.delegate getCurrentGeoPosition];
}


- (IBAction)librarySelection:(id)sender {
}
@end
