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

@implementation SoundcloudLibraryViewController

@synthesize tracks;
@synthesize playerViewController;
@synthesize currentSongPosition;
@synthesize search, librarySelector;
@synthesize libraryTableView;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage * img = [UIImage imageNamed:@"06-magnify.png"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:img tag:0];
        self.title = @"Search";
    }

    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    // change background of navigation bar to black
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;

    search.delegate = self;

    [self updateLibrarySongList];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// load songs for tab selection: all music/only my music
- (void) updateLibrarySongList {
    NSLog(@"update library");

    NSString * searchString = search.text;

    // do request for SoundCloud
    // like https://api.soundcloud.com/tracks.json?client_id=f0cfa9035abc5752e699580d5586d1e6&sharing=public&ids=41558714,13158665
    NSMutableDictionary * requestParameter = [NSMutableDictionary dictionary];
    [requestParameter setObject:@"public"  forKey:@"sharing"];
    // check if search field contains string
    if (searchString.length > 0) {
        [requestParameter setObject:searchString forKey:@"q"];
    }

    SCAccount * account = [SCSoundCloud account];
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse * response, NSData * data, NSError * error) {
        NSError * jsonError = nil;
        NSJSONSerialization * jsonResponse = [NSJSONSerialization
                                              JSONObjectWithData:data
                                                options			:0
                                                error			:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            // todo
            tracks = [jsonResponse copy];
            [self.libraryTableView reloadData];
        } else {
            NSLog(@"error occurred when loading songs: %@", jsonError);
        }
    };
    // distinguish between "my music" and "everything"
    NSString * resourceURL = (librarySelector.selectedSegmentIndex == 0) ? @"https://api.soundcloud.com/tracks.json" : @"https://api.soundcloud.com/me/tracks.json";
    [SCRequest performMethod:SCRequestMethodGET
        onResource				:[NSURL URLWithString:resourceURL]
        usingParameters			:requestParameter
        withAccount				:account
        sendingProgressHandler	:nil
        responseHandler			:handler];

}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (tracks.count == 0) ? 350 : 160;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(tracks.count, 1);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // no music found
    if (tracks.count == 0) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"EmptyLibraryView" owner:self options:nil];
        UITableViewCell * cell = [nib objectAtIndex:0];
        cell.userInteractionEnabled = NO;
        return cell;
    }

    static NSString * CellIdentifier = @"SongCell";
    SongCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        // cell = [[SongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (SongCell *) [nib objectAtIndex:0];
    }

    // set state (if playing)
    if (indexPath.row == [self currentSongPosition]) {
        [cell setActive:YES];
    } else {
        [cell setActive:NO];
    }

    NSDictionary * track = [self.tracks objectAtIndex:indexPath.row];
    // todo: get all information for the song (title, interpret, genre/tags, likes, image)
    cell.songTitle.text = [track objectForKey:@"title"];
    NSLog(@"reloading %@", [track objectForKey:@"title"]);
    NSDictionary * user  = [track objectForKey:@"user"];
    cell.songInterpreter.text = [user objectForKey:@"username"];

    NSNumber * favoritings_count = [track objectForKey:@"favoritings_count"];
    cell.likes.text = [NSString stringWithFormat:@"%d", (int) [favoritings_count intValue]];

    NSNumber * shared_count = [track objectForKey:@"shared_to_count"];
    cell.shares.text = [NSString stringWithFormat:@"%d", (int) [shared_count intValue]];

    NSNumber * playback_count = [track objectForKey:@"playback_count"];
    cell.plays.text = [NSString stringWithFormat:@"%d", (int) [playback_count intValue]];

    NSObject * imageUrlObject;
    if ((imageUrlObject = [track objectForKey:@"artwork_url"]) != [NSNull null]) {
        NSString * artworkImageUrlObject = [self changeUrlForPictureQuality:(NSString *) imageUrlObject];
        [cell setImageUrl:(NSString *) artworkImageUrlObject];
    }

    return cell;

}

- (NSString *) changeUrlForPictureQuality:(NSString *)url {
    NSRange start = [url rangeOfString:@"-" options:NSBackwardsSearch];
    NSRange end   = [url rangeOfString:@"." options:NSBackwardsSearch];

    if (end.location < start.location) {
        return url;
    }
    
    NSRange range = NSMakeRange(start.location + 1, (end.location - start.location) - 1);
    return [url stringByReplacingCharactersInRange:range withString:@"t300x300"];
}

// showPlayer is called when user taps on a item
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentSongPosition = indexPath.row;
    NSDictionary * song = [self.tracks objectAtIndex:indexPath.row];

    // NSLog(@"selected song: %@",selectedSong.soundcloud_id);
    [[self delegate] selectSongIndex:-1];
    [self showPlayer:song];
}

// change to PlayerView, which is initialised with the defined song object
- (void) showPlayer:(NSDictionary *)song {
    if (song != NULL) {
        [self.playerViewController setSongItem:song];
        [self.playerViewController setDelegate:self];
    }
    [self.libraryTableView reloadData];
    [self.tabBarController setSelectedIndex:2];
}

// library selection changed
- (IBAction) librarySelection:(id)sender {
    [self updateLibrarySongList];
}

- (IBAction) dismissKeyboard:(id)sender {
    NSLog(@"touch");
    // [self.view endEditing:YES];
    libraryTableView.userInteractionEnabled = YES;
    [search resignFirstResponder];
}

// filter library items on search string
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [search resignFirstResponder];
    [self updateLibrarySongList];
    self.currentSongPosition = -1;
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"search opened");
    libraryTableView.userInteractionEnabled = NO;
}

// delegate methods ***

- (id) getPreviousEntry {
    self.currentSongPosition--;
    self.currentSongPosition = MAX(self.currentSongPosition, 0);
    [self.libraryTableView reloadData];
    return tracks[self.currentSongPosition];
}

- (id) getNextEntry {
    self.currentSongPosition++;
    self.currentSongPosition = MIN(self.currentSongPosition, [tracks count] - 1);
    [self.libraryTableView reloadData];
    return tracks[self.currentSongPosition];
}

- (id) getCurrentGeoPosition {
    return [self.delegate getCurrentGeoPosition];
}

- (id) getActiveUser {
    return [self.delegate getActiveUser];
}

- (void) selectSongIndex:(int)index {
    [self setCurrentSongPosition:index];
    [libraryTableView reloadData];
}

@end
