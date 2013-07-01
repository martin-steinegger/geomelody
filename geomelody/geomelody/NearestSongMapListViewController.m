//
//  MasterViewController.m
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "NearestSongMapListViewController.h"

#import "SCUI.h"
#import "TagFilterViewController.h"
#import "GoToLibraryHeaderView.h"
#import "PlayerViewController.h"
#import "Song.h"




@implementation NearestSongMapListViewController
@synthesize player;
@synthesize tracks;
@synthesize tagFilter;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Music Near You";
        self.goToLibraryHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"GoToLibraryHeaderView" owner:self options:nil] objectAtIndex:0];
        
    }

    // initialize tag filter
    [self loadFilter];
    
    [self updateNearestSongList];
    
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(showFilter)];
    self.navigationItem.rightBarButtonItem = filterButton;
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutSoundCloud:)];
    self.navigationItem.leftBarButtonItem = logout;
    
    //change background of navigation bar to black
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
    
    
  
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
            [self presentModalViewController:loginViewController animated:YES];
        }];
    }
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


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tracks.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
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
    NSObject * imageUrlObject;
    if(( imageUrlObject =[track objectForKey:@"artwork_url"])!=[NSNull null]){
        NSURL *imageURL = [NSURL URLWithString:(NSString* )imageUrlObject];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        cell.songImage.image = image;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }*/
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70;
}


// showPlayer is called when user taps on a item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected song at position: %d from %d songs",indexPath.row, tracks.count);
    NSDictionary *song = [self.tracks objectAtIndex:indexPath.row];
    
    //NSLog(@"selected song: %@",selectedSong.soundcloud_id);
    [self showPlayer:song];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"header";
}

// set header of table as GoToLibraryHeaderView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.goToLibraryHeaderView;

}

// change to TagFilterView
- (void) showFilter {
    if (!self.tagFilterViewController) {
        self.tagFilterViewController = [[TagFilterViewController alloc] initWithNibName:@"TagFilterViewController" bundle:nil];
        [self.navigationController pushViewController:self.tagFilterViewController animated:YES];
    }
}

// change to PlayerView, which is initialised with the defined song object
- (void) showPlayer:(NSDictionary*)song {
    if (!self.playerViewController) {
        self.playerViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    }
    self.playerViewController.songItem = song;
    [self.navigationController pushViewController:self.playerViewController animated:YES];
}

// change to user's soundcloud library
- (void) showLibrary {
    //todo
}

// load tag filter list from user settings -> tagFilter
- (void) loadFilter {


    //todo: load from storage
    //filter for testing: rock pop
    tagFilter = [NSArray arrayWithObjects:@"Rock",@"Pop", nil];
    
}

// updates the tagFilter and the nearest song list accordingly; filterList = NULL if no filter is set
// DELEGATE from TagFilterViewController
- (void) setFilter:(NSMutableArray *)filterList{
    tagFilter = filterList;
    [self updateNearestSongList];
}

- (void) updateNearestSongList {

    // 1) todo: get nearest songs from database
    
    // getSoundCloudSongs
    SCAccount *account = [SCSoundCloud account];
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            tracks = (NSArray *)jsonResponse;
            [self.tableView reloadData];
        }
    };
    
    NSString *resourceURL = @"https://api.soundcloud.com/me/tracks.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
    
    
//    // create test songs
//    for(int i=0; i<5; i++) {
//        [nearestSongList addObject:[[Song alloc] initWithPrimaryKey:i]];
//    }
//    // 2) filter songs by tags
//    for(Song *nearestSong in nearestSongList) {
//        // accept song if tagFilter is not set or if it contains the genre of the song
//        if(_tagFilter==NULL || [_tagFilter containsObject: [nearestSong genreTag]]) {
//            // add song to songlist
//            [self addSong:nearestSong];
//        }
//    }
    
}


@end
