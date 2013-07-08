//
//  GenreFilterViewController.m
//  geomelody
//
//  Created by admin on 28.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "GenreFilterViewController.h"

@interface GenreFilterViewController () {
    NSMutableDictionary *_genres;
    NSMutableArray *_genreTitles;
    BOOL _filterEnabled; //user settings for genre filtering
    NSMutableArray *_genreFilter; //user setting:only relevant when filterEnabled == TRUE
    NSMutableArray *_expandedGenres;
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
    
    NSString *fileString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"genres" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *stringsArray = [NSMutableArray arrayWithArray:[fileString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    _genres = [[NSMutableDictionary alloc] init];
    _genreTitles = [[NSMutableArray alloc] init];
    _expandedGenres = [[NSMutableArray alloc] init];
    NSString *genre;
    NSMutableArray *subGenres= [[NSMutableArray alloc] init];
    
    int i=0;
    while (i<stringsArray.count) {
        NSString *currentGenre = [stringsArray objectAtIndex:i];
        if([currentGenre hasPrefix:@"="] || i == stringsArray.count-1){
            //all subgenres have been added to subGenres -> save in _genres
            if(i>0){
                [_genres setObject:[subGenres copy] forKey:genre];
                [_genreTitles addObject:genre];
                [_expandedGenres addObject: [NSNumber numberWithBool:NO]];
            }
            //check if i is not the last item in the array ("")
            if(i!=stringsArray.count-1){
                genre = [currentGenre substringFromIndex:1];
                [subGenres removeAllObjects];
            }
        }else {
            if (![currentGenre isEqualToString:genre]){
                [subGenres addObject:currentGenre];
            }
        }
        i++;
    }
    
    //load user settings
    [self loadGenreFilterData];
    NSLog(@"_genreFilter: %@", _genreFilter);
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
    return _genres.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 0;
    else{
        if ([[_expandedGenres objectAtIndex:section-1] boolValue] == NO) {
            return 0;
        } else {
            NSString *genre = [_genreTitles objectAtIndex:section-1];
            NSArray *subgenres = [_genres objectForKey:genre];
            return subgenres.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //for sections >0 : set subgenre and accessory checkmark if selected in filter
    if(indexPath.section > 0) {
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.detailTextLabel.enabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        //section 1..n: for each subgenre add a selectable row to the genre's section
        NSString *genre = [_genreTitles objectAtIndex:indexPath.section-1];
        NSString *subgenre = [[_genres objectForKey:genre] objectAtIndex:indexPath.row];

        cell.textLabel.text = subgenre;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        BOOL check = [_genreFilter containsObject: subgenre] || [_genreFilter containsObject: genre];
        [cell setAccessoryView:[self getAccessoryCheckmark:check]];
        
        if(_filterEnabled){
            cell.userInteractionEnabled = YES;
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor blackColor];
        }else{
            cell.userInteractionEnabled = NO;
            cell.backgroundColor = [UIColor lightGrayColor];
            cell.textLabel.textColor = [UIColor grayColor];
        }
        return cell;
    }else
        return nil;
}

// set header of table as GoToLibraryHeaderView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    // add header for each genre
    if (section == 0) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        UISwitch *filterSwitch = [[UISwitch alloc] initWithFrame: CGRectMake(230, 22, 100, 30)];
        [filterSwitch setOn:_filterEnabled animated:YES];
        [filterSwitch addTarget:self action:@selector(toggleFilter:) forControlEvents:UIControlEventValueChanged];
        UILabel *headerText = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, 150, 30)];
        headerText.text = @"Genre Filter";
        headerText.textColor = [UIColor blackColor];
        headerText.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [header addSubview:headerText];
        [header addSubview:filterSwitch];
        return header;
        
    }else {
        
        int genreIndex = section-1;
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        
        UIButton *expand = [self getExpandable: [[_expandedGenres objectAtIndex:genreIndex] boolValue] forGenreIndex:genreIndex];
        [header addSubview:expand];
        
        UIButton *checkmark = [self getAccessoryCheckmarkForGenreSection:genreIndex];
        [header addSubview:checkmark];
        
        return header;
    }

}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section>0)
        return 40;
    else
        return 50;
}

//regulates on off switch; when filter is switched off all subgenre lists are folded
- (void) toggleFilter:(id)sender {
    _filterEnabled = !_filterEnabled;
    for (int i=0; i< _expandedGenres.count; i++) {
        [_expandedGenres replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    }

    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, _genres.count)];
    [self.tableView reloadSections:indexes withRowAnimation:UITableViewRowAnimationFade];
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
    //only if a subgenre was selected/deselected
    
    NSString *genre = [_genreTitles objectAtIndex:indexPath.section-1];
    NSString *subgenre = [[_genres objectForKey:genre] objectAtIndex:indexPath.row];

    // if this is the first subgenre deselected from the group remove the parent genre and add all subgenres
    if([_genreFilter containsObject:genre]) {
        [_genreFilter removeObject:genre];
        for (NSString *currentsubgenre in [_genres objectForKey:genre]){
            [_genreFilter addObject:currentsubgenre];
        }
    }
    
    //remove or add subgenre to filterlist
    if([_genreFilter containsObject:subgenre]) {
        [_genreFilter removeObject:subgenre];
    }else {
        [_genreFilter addObject:subgenre];
        
        // if all subgenres from one group are selected, remove all subgenres and add the parent genre
        NSArray *subgenres = [_genres objectForKey:genre];
        int i=0;
        while (i<subgenres.count && [_genreFilter containsObject:[subgenres objectAtIndex:i]]) {
            i++;
        }
        if(i == subgenres.count){
            for (NSString *currentsubgenre in [_genres objectForKey:genre]){
                [_genreFilter removeObject:currentsubgenre];
            }
            [_genreFilter addObject:genre];
        }
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        
}

// checked == YES: return button with checkmark ELSE: return empty button
- (UIButton *)getAccessoryCheckmark: (BOOL)checked {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,20,20);
    if(checked) {
        UIImage *image = [UIImage imageNamed:@"checkmark.png"];
        [button setBackgroundImage:image forState:UIControlStateNormal];
    } 
    return button;
}

- (UIButton *)getAccessoryCheckmarkForGenreSection: (int)genreIndex {
    
    UIButton *button; 

    NSString *genre = [_genreTitles objectAtIndex:genreIndex];
    
    // genre (and all subgenres) are selected -> return button with checkmark
    if ([_genreFilter containsObject:genre]) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(280, 10, 20, 20);
        UIImage *image = [UIImage imageNamed:@"checkmark.png"];
        [button setBackgroundImage:image forState:UIControlStateNormal];
    } else {
        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(225, 10, 80, 20);
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"Select All" forState:UIControlStateNormal];
    }

    button.tag = genreIndex;
    if(_filterEnabled){
        [button addTarget:self action:@selector(toggleGenreChecked:) forControlEvents:UIControlEventTouchDown];
    }
    
    // set button transparent if filter is disabled
    if (_filterEnabled) {
        [button setAlpha:1.0];
    } else {
        [button setAlpha:0.4];
    }
    
    return button;
}


// change checked state of specifc genre/section
// sender.tag contains index of treated genre (no the section!)
- (void) toggleGenreChecked:(id)sender {
    int genreIndex = ((UIButton *)sender).tag ;
    NSString *genre = [_genreTitles objectAtIndex:genreIndex];
    if([_genreFilter containsObject:genre]) {
        //remove genre
        [_genreFilter removeObject:genre];
        //remove all subgenres of the genre
        for (NSString *subgenre in [_genres objectForKey:genre]) {
            [_genreFilter removeObject:subgenre];
        }
    }else {
        // add genre
        [_genreFilter addObject:genre];
        // remove all subgenres of the genre
        for (NSString *subgenre in [_genres objectForKey:genre]) {
            [_genreFilter removeObject:subgenre];
        }
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:genreIndex+1] withRowAnimation:UITableViewRowAnimationFade];
}

// expanded==YES: return minus-icon ELSE: return plus-icon
- (UIButton *)getExpandable: (BOOL)expanded forGenreIndex:(int)genreIndex {
    
    NSString *genre = [_genreTitles objectAtIndex:genreIndex];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = expanded? [UIImage imageNamed:@"expanded.png"] : [UIImage imageNamed:@"nonexpanded.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 10, 10)];
    imageView.image = image;
    [button addSubview:imageView];
    
    UIView *textView = [[UIView alloc] init];
    UILabel *headerText = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 100, 20)];
    headerText.text = genre;
    headerText.textColor = [UIColor blackColor];
    headerText.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [textView addSubview:headerText];
    
    //check if subgenres are selected
    NSArray *subgenres = [_genres objectForKey:genre];
    int i=0;
    for (NSString *subgenre in subgenres) {
        if([_genreFilter containsObject:subgenre]) {
            i++;
        }
    }
    // subselection -> show number of selected subgenres
    if (i>0 && i< subgenres.count) {
        UILabel *headerTextSmall = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 150, 20)];
        headerTextSmall.text = [[NSString stringWithFormat:@"%i", i] stringByAppendingString:@" selected"];
        headerTextSmall.textColor = [UIColor blackColor];
        headerTextSmall.font = [UIFont systemFontOfSize:10.0];
        headerTextSmall.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [textView addSubview:headerTextSmall];
    }
    
    [button addSubview:textView];

    button.frame = CGRectMake(0,0,200,30);
    button.tag = genreIndex;
    if(_filterEnabled){
        [button addTarget:self action:@selector(toggleExpandable:) forControlEvents:UIControlEventTouchDown];
    }
    
    // set button transparent if filter is disabled
    if (_filterEnabled) {
        [button setAlpha:1.0];
    } else {
        [button setAlpha:0.4];
    }
    
    return button;
}

// change expand-state of specific genre/section
// sender.tag contains index of treated genre (no the section!)
- (void) toggleExpandable:(id)sender {
    int genreIndex = ((UIButton *)sender).tag;
    if([[_expandedGenres objectAtIndex:genreIndex] boolValue] == YES) {
        [_expandedGenres replaceObjectAtIndex:genreIndex withObject:[NSNumber numberWithBool:NO]];
    } else {
        [_expandedGenres replaceObjectAtIndex:genreIndex withObject:[NSNumber numberWithBool:YES]];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:genreIndex+1] withRowAnimation:UITableViewRowAnimationFade];
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

-(NSString *)getStoragePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSLog(@"storage: %@", directory);
    return [directory stringByAppendingPathComponent:@"tagfilter.archive"];
}

// save user's filter settings to memory
- (void) saveGenreFilterData {
    
    [[NSUserDefaults standardUserDefaults] setBool:_filterEnabled forKey:@"filterEnabled"];
    NSLog(@"save succeeded: %@", [NSKeyedArchiver archiveRootObject:_genreFilter toFile:[self getStoragePath]] ? @"YES" : @"NO");
    
}

// load user's filter settings from memory
- (void) loadGenreFilterData {
    
    _filterEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"filterEnabled"];
    _genreFilter = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getStoragePath]];
    if(_genreFilter == nil){
        _genreFilter = [[NSMutableArray alloc] initWithArray:_genreTitles];
        //for (NSString *genreTitle in _genreTitles) {
         //   [_genreFilter addObjectsFromArray: [_genres objectForKey:genreTitle]];
        //}
    }
    
}

@end
