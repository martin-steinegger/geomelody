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
@synthesize search, librarySelector;
@synthesize libraryTableView;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //change background of navigation bar to black
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    search.delegate = self;
    
    [self updateLibrarySongList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// load songs for tab selection: all music/only my music
- (void) updateLibrarySongList {
    NSLog(@"update library");
    
    NSString *searchString = search.text;
    
    //todo: connection to tabs
    
    // do request for SoundCloud
    // like https://api.soundcloud.com/tracks.json?client_id=f0cfa9035abc5752e699580d5586d1e6&sharing=public&ids=41558714,13158665
    NSMutableDictionary *requestParameter = [NSMutableDictionary dictionary];
    [requestParameter setObject:@"public"  forKey:@"sharing"];
    // check if search field contains string
    if(searchString.length>0) {
        [requestParameter setObject:searchString forKey:@"q"];
    }
    // apply search on for user if "my music" is selected
    if (librarySelector.selectedSegmentIndex == 1) {
        NSLog(@"my id: %@", [[self getActiveUser] objectForKey:@"id"]);
        [requestParameter setObject:[[self getActiveUser] objectForKey:@"id"] forKey:@"user_id"];
    }
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
            tracks = [jsonResponse copy];
            NSLog(@"tracks: %@", tracks);
            [self.libraryTableView reloadData];
        }else {
            NSLog(@"error occurred when loading songs: %@", jsonError);
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"number racks: %i", tracks.count);
    return tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SongCell";
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        //cell = [[SongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (SongCell *)[nib objectAtIndex:0];
    }
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    //todo: get all information for the song (title, interpret, genre/tags, likes, image)
    cell.songTitle.text = [track objectForKey:@"title"];
    NSLog(@"reloading %@", [track objectForKey:@"title"]);
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

//library selection changed
- (IBAction)librarySelection:(id)sender {
    [self updateLibrarySongList];
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch");
    [self.view endEditing:YES];
    [search resignFirstResponder];
}

// filter library items on search string
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"start search");
    [self.view endEditing:YES];
    [search resignFirstResponder];
    [self updateLibrarySongList];
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
    return [self.delegate getActiveUser];
}

@end
