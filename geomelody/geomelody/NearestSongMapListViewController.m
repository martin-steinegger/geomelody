//
//  MasterViewController.m
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "NearestSongMapListViewController.h"

#import "PlayerViewController.h"
#import "SCUI.h"
#import "TagFilterViewController.h"
#import "Song.h"
#import "GoToLibraryHeaderView.h"


@interface NearestSongMapListViewController () {
    NSMutableArray *_songs;
    NSArray *_tagFilter;
}

@end

@implementation NearestSongMapListViewController

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
    
    //change background of navigation bar to black
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addSong:(Song *)newSong{
    if (!_songs) {
        _songs = [[NSMutableArray alloc] init];
    }
    [_songs insertObject:newSong atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songs.count;
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

    Song *song = [_songs objectAtIndex: indexPath.row];
    //todo: get all information for the song (title, interpret, genre/tags, likes, image)
    cell.songTitle.text = song.title;
    cell.songInterpreter.text = song.interpreter;
    cell.likes.text = [NSString stringWithFormat:@"%d", (int)song.likes];
    cell.songImage.image = song.songImage;
    
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

// showPlayer is called when user taps on a item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected song at position: %d from %d songs",indexPath.row, _songs.count);
    Song *selectedSong = [_songs objectAtIndex:indexPath.row];
    NSLog(@"selected song: %@",selectedSong.soundcloud_id);
    [self showPlayer:selectedSong];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"header";
}

// set header of table as GoToLibraryHeaderView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    return self.goToLibraryHeaderView;

}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70;
}

// change to TagFilterView
- (void) showFilter {
    if (!self.tagFilterViewController) {
        self.tagFilterViewController = [[TagFilterViewController alloc] initWithNibName:@"TagFilterViewController" bundle:nil];
        [self.navigationController pushViewController:self.tagFilterViewController animated:YES];
    }
}

// change to PlayerView, which is initialised with the defined song object
- (void) showPlayer:(Song*)song {
    if (!self.playerViewController) {
        self.playerViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    }
    self.playerViewController.playingSong = song;
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
    _tagFilter = [NSArray arrayWithObjects:@"Rock",@"Pop", nil];
    
}

// updates the tagFilter and the nearest song list accordingly; filterList = NULL if no filter is set
// DELEGATE from TagFilterViewController
- (void) setFilter:(NSMutableArray *)filterList{
    _tagFilter = filterList;
    [self updateNearestSongList];
}

- (void) updateNearestSongList {

    [_songs removeAllObjects];
    // 1) todo: get nearest songs from database
    NSMutableArray *nearestSongList = [[NSMutableArray alloc] init];
    // create test songs
    for(int i=0; i<5; i++) {
        [nearestSongList addObject:[[Song alloc] initWithPrimaryKey:i]];
    }
    // 2) filter songs by tags
    for(Song *nearestSong in nearestSongList) {
        // accept song if tagFilter is not set or if it contains the genre of the song
        if(_tagFilter==NULL || [_tagFilter containsObject: [nearestSong genreTag]]) {
            // add song to songlist
            [self addSong:nearestSong];
        }
    }
    
}


@end
