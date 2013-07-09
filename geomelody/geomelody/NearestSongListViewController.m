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
#import "Reachability.h"
@implementation NearestSongListViewController

@synthesize tracks;
@synthesize locationManager;
@synthesize tableView;
@synthesize reachability;
@synthesize playerViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"List" image:nil tag:0];
        self.title = @"List";
        self.navigationItem.title = @"";
    }
    
    // initialize TagFilterViewController
    if (!self.genreFilterViewController) {
        self.genreFilterViewController = [[GenreFilterViewController alloc] initWithNibName:@"GenreFilterViewController" bundle:nil];
        self.genreFilterViewController.delegate = self;
    }
    
    return self;
}


#pragma mark - Reachability

- (void)showAlertForReachbilty:(NSInteger) ns{
    reachability = ns;
    if (ns == NotReachable) {
        if (![self.networkAlert isVisible]) {
            if ([self networkAlert] == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Someone broke the internet :("
                                                                message:@"You require an internet connection to communicate with the server."
                                                               delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                [locationManager stopUpdatingLocation];
                [self setNetworkAlert:alert];
            }
            [self.networkAlert show];
        }
    } else {
        if ([self networkAlert] != nil) {
            [self.networkAlert dismissWithClickedButtonIndex:0 animated:YES];
        }
        [locationManager startUpdatingLocation];
    }
}

- (void)reachabilityHasChanged:(NSNotification *)note {
    NetworkStatus ns = [(Reachability *)[note object] currentReachabilityStatus];
    [self showAlertForReachbilty:ns];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //Layout
    //transparent navigationbar
    self.navigationController.navigationBar.translucent = YES; // Setting this slides the view up, underneath the nav bar (otherwise it'll appear black)
    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
    UIImage *img = [[UIImage alloc] init];
    UIImage *maskedImage = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(img.CGImage, colorMask)];
    [self.navigationController.navigationBar setBackgroundImage:maskedImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage: [[UIImage alloc] init]];
    [tableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];

    // setup filter button
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    [filterButton sizeToFit];
    [filterButton addTarget:self action:@selector(showFilter) forControlEvents:UIControlEventTouchUpInside];
    filterButton.frame = CGRectMake(0.0f, 0.0f, 48.0f, 33.0f);
    [[filterButton layer] setCornerRadius:8.0f];
    [[filterButton layer] setMasksToBounds:YES];
    [[filterButton layer] setShadowOffset:CGSizeMake(5, 5)];
    [[filterButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[filterButton layer] setShadowOpacity:0.5];
    filterButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];

    UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    self.navigationItem.leftBarButtonItem = filterButtonItem;

    
    //change background of navigation bar to black
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;

    //get location updates for music
    self.currentLocation = NULL;
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:10]; //only every ten meters

    //SC init
    [SCSoundCloud  setClientID:@"f0cfa9035abc5752e699580d5586d1e6"
                        secret:@"49baf8628ee99e0e62d6af4742d33073"
                   redirectURL:[NSURL URLWithString:@"geomelody://oauth"]];
    
    
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SongCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SongCellId"];

    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    
  
}

- (IBAction) logoutSoundCloud:(id) sender
{
    [SCSoundCloud removeAccess];
    [self checkLogin];
    // update song list
    [self updateNearestSongList];
}

- (void)checkLogin{
    if(reachability==NotReachable)
        return;
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
    }
    if(self.activeUser == NULL){
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
    // check internet
    [self showAlertForReachbilty:reachability];
    
    // check SC Login
    [self checkLogin];


    // update song list
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSString *) changeUrlForPictureQuality:(NSString *) url{
    NSRange start =[url rangeOfString:@"-" options:NSBackwardsSearch];
    NSRange end   =[url rangeOfString:@"." options:NSBackwardsSearch];
    if(end.location < start.location){
        NSLog(@"Start > End");
        return url;
    }
    NSRange range = NSMakeRange(start.location+1,(end.location-start.location)-1);
    return [url stringByReplacingCharactersInRange:range withString:@"t300x300"];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    SongCell *cell = (SongCell*)[tv dequeueReusableCellWithIdentifier:@"SongCellId" forIndexPath:indexPath];

    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    //todo: get all information for the song (title, interpret, genre/tags, likes, image)
    cell.songTitle.text = [track objectForKey:@"title"];
    NSDictionary *user  = [track objectForKey:@"user"];
    cell.songInterpreter.text = [user objectForKey:@"username"];
    
    NSNumber *favoritings_count = [track objectForKey:@"favoritings_count"];
    cell.likes.text = [NSString stringWithFormat:@"%d",(int)[favoritings_count intValue]];
    
    NSNumber *shared_count = [track objectForKey:@"shared_to_count"];
    cell.shares.text = [NSString stringWithFormat:@"%d",(int)[shared_count intValue]];
    
    NSNumber *playback_count = [track objectForKey:@"playback_count"];
    cell.plays.text = [NSString stringWithFormat:@"%d",(int)[playback_count intValue]];
    
    
    NSObject * imageUrlObject;
    if((imageUrlObject =[track objectForKey:@"artwork_url"])!=[NSNull null]){
            NSString* artworkImageUrlObject=[self changeUrlForPictureQuality:(NSString *)imageUrlObject];
            [cell setImageUrl:(NSString*)artworkImageUrlObject];
    }
    return cell;
}

// showPlayer is called when user taps on a item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected song at position: %d from %d songs",indexPath.row, tracks.count);
    self.currentSongPosition = indexPath.row;
    NSDictionary *song = [self.tracks objectAtIndex:indexPath.row];
        
    //NSLog(@"selected song: %@",selectedSong.soundcloud_id);
    [self showPlayer:song];
}

// change to TagFilterView
- (void) showFilter {
    [self.navigationController pushViewController:self.genreFilterViewController animated:YES];
}

-(void) showPlayerWithCurrentSong {
    [self showPlayer:nil];
}

// change to PlayerView, which is initialised with the defined song object
- (void) showPlayer:(NSDictionary*)song {

    if(song != NULL)
        [self.playerViewController setSongItem:song];
    [self.tabBarController setSelectedIndex:2];
}


// change to user's soundcloud library
- (void) showLibrary {
    //todo
}

- (void) updateNearestSongList {
    
    NSLog(@"update nearest song list");
    [self checkLogin];
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
    for (NSDictionary* beTrack in backEndTracks) {
        for (NSDictionary* scTrack in soundCloudTracks) {
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tracks.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

#pragma mark NearestSongMapViewControllerProtocoll

- (NSArray*) getTracks {
    return tracks;
}

-(NSInteger) getCurrentTrackIndex {
    return self.currentSongPosition;
}

@end
