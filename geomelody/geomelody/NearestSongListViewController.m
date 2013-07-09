//
//  MasterViewController.m
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "NearestSongListViewController.h"

#import "SCUI.h"
#import "GenreFilterViewController.h"
#import "PlayerViewController.h"
#import "BackendApi.h"
#import "GMSegmentedButtonBar.h"
#import "ImageEntropy.h"


@implementation NearestSongListViewController
@synthesize tracks;
@synthesize locationManager;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    // initialize TagFilterViewController
    if (!self.genreFilterViewController) {
        self.genreFilterViewController = [[GenreFilterViewController alloc] initWithNibName:@"GenreFilterViewController" bundle:nil];
    }
    
    [self updateNearestSongList];
    
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ImageEntropy * entropy = [ImageEntropy alloc];
    UIImage * image = [UIImage imageNamed:@"soundcloud.jpg" ];
    [entropy setImage:image];
    [entropy calculateRowRange];
    
	// Do any additional setup after loading the view, typically from a nib.
    UISwipeGestureRecognizer* gestureSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureSwipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:gestureSwipeUpRecognizer];
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutSoundCloud:)];
    self.navigationItem.leftBarButtonItem = logout;
    
    //change background of navigation bar to black
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    //get location updates for music
    self.currentLocation = NULL;
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:10]; //only every ten meters
    [locationManager startUpdatingLocation];
    
    NSArray *segments = [NSArray arrayWithObjects: @"Map", @"Filters", nil];
    GMSegmentedButtonBar *navigationControls = [[GMSegmentedButtonBar alloc] initWithItems:segments];
    [navigationControls setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [navigationControls setSegmentedControlStyle:UISegmentedControlStyleBar];
    [navigationControls addTarget:self action:@selector(navigationSegmentAction:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.titleView = navigationControls;
  
}

-(void)setPlayerButtonVisible:(bool)visible {
    if(visible == YES) {
        UIBarButtonItem *playerButton = [[UIBarButtonItem alloc] initWithTitle:@"Player" style:UIBarButtonItemStylePlain target:self action:@selector(showPlayerWithCurrentSong)];
        self.navigationItem.rightBarButtonItem = playerButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (IBAction) logoutSoundCloud:(id) sender
{
    [SCSoundCloud removeAccess];
    [self checkLogin];
}

- (void)checkLogin{
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
            if (SC_CANCELED(error)) {
                NSLog(@"Canceled!");
            } else if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
            } else {
                NSLog(@"Done!");
            }
        };
        
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
            SCLoginViewController *loginViewController;
            
            loginViewController = [SCLoginViewController
                                   loginViewControllerWithPreparedURL:preparedURL
                                   completionHandler:handler];
            [self presentViewController:loginViewController animated:YES completion:nil];
        }];
    }else { // get user information
        SCRequestResponseHandler handler;
        handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
            NSError *jsonError = nil;
            NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                                 JSONObjectWithData:data
                                                 options:0
                                                 error:&jsonError];
            if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]]) {
                
                self.activeUser = (NSDictionary *)jsonResponse;
          
            }
        };
        
        NSString *resourceURL = @"https://api.soundcloud.com/me";
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:[NSURL URLWithString:resourceURL]
                 usingParameters:nil
                     withAccount:account
          sendingProgressHandler:nil
                 responseHandler:handler];
    
    }
    
    // update song list
    [self updateNearestSongList];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //updated    newLocation
    self.currentLocation = newLocation;
    [self updateNearestSongList];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", [error description]);
}


- (void)viewDidAppear:(BOOL)animated {
    // check SC Login
    //[SCSoundCloud removeAccess]; //DEBUG only
    [self checkLogin];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) handleSwipe:(UISwipeGestureRecognizer*) recognizer {
    [self showMapController];
}

-(void)navigationSegmentAction:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) { /* Map */
        [self showMapController];
    }
    
    if (selectedSegment == 1) { /* Filter */
        [self showFilter];
    }
}

-(void)showMapController {
    NearestSongMapViewController* mapViewController = [[NearestSongMapViewController alloc] initWithNibName:@"NearestSongMapViewController" bundle:nil];
    [mapViewController setDelegate:self];
    [self.revealSideViewController pushViewController:mapViewController onDirection:PPRevealSideDirectionBottom animated:YES];
}


#pragma mark - Table View

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if(indexPath.section == 0) {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GoToLibraryCell" owner:self options:nil];
            cell = (UITableViewCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellEditingStyleNone;
        }
        return cell;
    }else {
        SongCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[SongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
        //todo: get all information for the song (title, interpret, genre/tags, likes, image)
        cell.songTitle.text = [track objectForKey:@"title"];
        NSDictionary *user  = [track objectForKey:@"user"];
        cell.songInterpreter.text = [user objectForKey:@"username"];
        
        NSNumber *favoritings_count = [track objectForKey:@"favoritings_count"];
        cell.likes.text = [NSString stringWithFormat:@"%d",(int)[favoritings_count intValue]];
        
        NSNumber *shared_count = [track objectForKey:@"shared_to_count"];
        cell.shares.text = [NSString stringWithFormat:@"%d",(int)[shared_count intValue]];
        NSObject * imageUrlObject;
        if(( imageUrlObject =[track objectForKey:@"artwork_url"])!=[NSNull null]){
            NSURL *imageURL = [NSURL URLWithString:(NSString* )imageUrlObject];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            cell.songImage.image = image;
        }
        return cell;
    }
    
}

// showPlayer is called when user taps on a item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section>0) {
        NSLog(@"selected song at position: %d from %d songs",indexPath.row, tracks.count);
        self.currentSongPosition = indexPath.row;
        NSDictionary *song = [self.tracks objectAtIndex:indexPath.row];
        
        //NSLog(@"selected song: %@",selectedSong.soundcloud_id);
        [self setPlayerButtonVisible:YES];
        [self showPlayer:song];
    }
}

// change to TagFilterView
- (void) showFilter {

    [self.navigationController pushViewController:self.genreFilterViewController animated:YES];

}

-(void) showPlayerWithCurrentSong {
    NSDictionary* song = [tracks objectAtIndex:[self getCurrentTrackIndex]];
    [self showPlayer:song];
}

// change to PlayerView, which is initialised with the defined song object
- (void) showPlayer:(NSDictionary*)song {
    if (!self.playerViewController) {
        self.playerViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
        self.playerViewController.delegate = self;
    }
    [self.playerViewController setSongItem:song];
    [self.navigationController pushViewController:self.playerViewController animated:YES];
}

// change to user's soundcloud library
- (void) showLibrary {
    //todo
}

- (void) updateNearestSongList {
    
    NSLog(@"update nearest song list");
    
    NSArray *genreFilter = [self.genreFilterViewController getGenreFilter];

    // 1) todo: get nearest songs from database with filter
    // 2) ask soundcloud for information http://api.soundcloud.com/tracks?client_id=f0cfa9035abc5752e699580d5586d1e6&ids=41558714,13158665
    // 3) order by favoritings_count and playback_count
    // getSoundCloudSongs
    
    BackendApi* backendApi=[BackendApi sharedBackendApi];
    
    GeoMelodyBackendLocation *backendLocation = [GeoMelodyBackendLocation alloc];
    backendLocation.latitude =  [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
    backendLocation.longitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];
    [backendApi getkNearestSongsWithLocation:backendLocation andFilters:genreFilter k:4 onSuccess:^(NSArray * objects) {
        NSLog(@"getkNearestSongsWithLocation successful");
        NSMutableString *ids_string = [NSMutableString stringWithCapacity:1000];
        NSDictionary *songsDict = (NSDictionary* ) objects;
        NSDictionary *songs = [songsDict objectForKey:@"Song"]; // Can be an array
        NSMutableArray * backendSongArray = [[NSMutableArray alloc] initWithObjects:nil];
        if([songs isKindOfClass:[NSArray class]]){ // if there is more than one element
            for (id object in songs) {
                if([object isKindOfClass:[NSDictionary class]]){
                    NSDictionary *song = (NSDictionary *) object;
                    if([song count] != 0){
                        [backendSongArray addObject:song];
                        NSString *current_id_number = [song objectForKey:@"SoundCloudSongId"];
                        [ids_string appendString:current_id_number ];
                        [ids_string appendString: @","];
                    }
                }
            }
            if(ids_string.length > 1 ) // remove last 
                if([ids_string characterAtIndex:[ids_string length]-1]==',')
                    [ids_string deleteCharactersInRange:NSMakeRange([ids_string length]-1, 1)];

        }
        
        if([songs isKindOfClass:[NSDictionary class]]){ // if there is only one element
            NSDictionary *song = (NSDictionary* ) songs;
            if([song count] != 0){
                [backendSongArray addObject:song];
                NSString *current_id_number = [song objectForKey:@"SoundCloudSongId"];
                [ids_string appendString:current_id_number ];
            }
        }
        
        // do request for SoundCloud
        // like https://api.soundcloud.com/tracks.json?client_id=f0cfa9035abc5752e699580d5586d1e6&sharing=public&ids=41558714,13158665
        NSMutableDictionary *requestParameter = [NSMutableDictionary dictionary];
        [requestParameter setObject:@"public"  forKey:@"sharing"];
        [requestParameter setObject:ids_string forKey:@"ids"];

        SCAccount *account = [SCSoundCloud account];
        SCRequestResponseHandler handler;
        handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
            NSError *jsonError = nil;
            NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                                 JSONObjectWithData:data
                                                 options:0
                                                 error:&jsonError];
            if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
                tracks = [self mergeData:(NSArray *)jsonResponse backEndTracks:backendSongArray];
                [self.tableView reloadData];
            }
        };
        NSString *resourceURL = @"https://api.soundcloud.com/tracks.json";
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:[NSURL URLWithString:resourceURL]
                 usingParameters:requestParameter
                     withAccount:account
          sendingProgressHandler:nil
                 responseHandler:handler];
        
        
    } onFail:^(NSError * error) {
        NSLog(@"getkNearestSongsWithLocation Error with query");
    }];
}

-(NSArray*)mergeData:(NSArray *)soundCloudTracks  backEndTracks:(NSMutableArray *)backEndTracks {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for(NSDictionary* scTrack in soundCloudTracks) {
        for (NSDictionary* beTrack in backEndTracks) {
            NSInteger beSoundCloudSongId = [[beTrack objectForKey:@"SoundCloudSongId"] intValue];
            NSInteger scSoundCloudSongId = [[scTrack objectForKey:@"id"] intValue];
            if(beSoundCloudSongId == scSoundCloudSongId) {
                NSMutableDictionary *dict = [scTrack mutableCopy];
                [dict addEntriesFromDictionary:beTrack];
                [result addObject:dict];
            }
        }
    }
    return result;
}

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
    return self.currentLocation;
}

- (id)getActiveUser {
    return self.activeUser;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 1;
    else
        return tracks.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark NearestSongMapViewControllerProtocoll

- (NSArray*) getTracks {
    return tracks;
}

-(NSInteger) getCurrentTrackIndex {
    return self.currentSongPosition;
}

@end
