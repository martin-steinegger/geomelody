//
//  GenreFilterViewController.m
//  geomelody
//
//  Created by admin on 28.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "GenreFilterViewController.h"

@interface GenreFilterViewController () {
    NSArray *_genres; //static predefined
    BOOL _filterEnabled; //user setting
    NSMutableArray *_genreFilter; //user setting:only relevant when filterEnabled == TRUE
}

@end

@implementation GenreFilterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Filter Settings";
    }
    //initially set to disabled (only needed, when user starts app for the first time and has not changed the filter yet)
    _filterEnabled = NO;
    return self;
}

- (void) loadSettings {
    NSLog(@"Load settings");
    // load static array of available genres
    
    NSString *fileString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"tags" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *stringsArray = [NSMutableArray arrayWithArray:[fileString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    _genres = [NSArray arrayWithArray:stringsArray];
    
    //load user settings
    [self loadGenreFilterData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadSettings];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _genres.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.detailTextLabel.enabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //section 1: for each filter tag add a selectable row
        cell.textLabel.text = [_genres objectAtIndex:indexPath.row];
        if([_genreFilter containsObject: [_genres objectAtIndex:indexPath.row]]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        if(_filterEnabled){
            cell.userInteractionEnabled = YES;
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor blackColor];
        }else{
            cell.userInteractionEnabled = NO;
            cell.backgroundColor = [UIColor lightGrayColor];
            cell.textLabel.textColor = [UIColor grayColor];
        }
    
    // Configure the cell...
    
    return cell;
}

// set header of table as GoToLibraryHeaderView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    UISwitch *filterSwitch = [[UISwitch alloc] initWithFrame: CGRectMake(220, 30, 100, 30)];
    [filterSwitch setOn:_filterEnabled animated:YES];
    [filterSwitch addTarget:self action:@selector(toggleFilter:) forControlEvents:UIControlEventValueChanged];
    UILabel *headerText = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 150, 30)];
    headerText.text = @"Genre Filter";
    headerText.textColor = [UIColor darkGrayColor];
    headerText.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [header addSubview:headerText];
    [header addSubview:filterSwitch];
    return header;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Genre Filter";
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70;
}

- (void) toggleFilter:(id)sender {
    _filterEnabled = !_filterEnabled;
    // todo: update view -> cells with genres need to be disabled/enabled
    
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //only if a genre was selected/deselected

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSString *selectedTag = [_genres objectAtIndex:indexPath.row];
        if([_genreFilter containsObject:selectedTag]) {
            [_genreFilter removeObject:selectedTag];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }else {
            [_genreFilter addObject:selectedTag];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
}


-(NSString *)getStoragePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSLog(@"storage: %@", directory);
    return [directory stringByAppendingPathComponent:@"tagfilter.archive"];
}

- (void) saveGenreFilterData {
    
    [[NSUserDefaults standardUserDefaults] setBool:_filterEnabled forKey:@"filterEnabled"];
    NSLog(@"save succeeded: %@", [NSKeyedArchiver archiveRootObject:_genreFilter toFile:[self getStoragePath]] ? @"YES" : @"NO");
    
}

- (void) loadGenreFilterData {
    
    _filterEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"filterEnabled"];
    _genreFilter = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getStoragePath]];
    if(_genreFilter == nil)
        _genreFilter = [[NSMutableArray alloc] initWithArray:_genres];
    
}

//save changes when go back button is pressed
- (void)viewWillDisappear:(BOOL)animated {
    [self saveGenreFilterData];
    [self.delegate updateNearestSongList];
    //[self.nearestSongMapListViewController setFilter:_tagFilter];
}

//return NULL, if filter is disabled -> all tags accepted
//return the list of accepted tags, if filter is enabled
- (NSMutableArray *)getGenreFilter {
    // load settings from storage if not yet initialized
    if(_genreFilter == nil){
        [self loadGenreFilterData];
    }
    if (_filterEnabled) {
        return _genreFilter;
    }else
        return NULL;
}

@end
