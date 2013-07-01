//
//  TagFilterViewController.m
//  geomelody
//
//  Created by admin on 28.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "TagFilterViewController.h"

@interface TagFilterViewController () {
    NSArray *_tags; //static predefined
    BOOL _filterEnabled; //user setting
    NSMutableArray *_tagFilter; //user setting:only relevant when filterEnabled == TRUE
}

@end

@implementation TagFilterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Filter Settings";
    }
    return self;
}

- (void) loadSettings {
    NSLog(@"Load settings");
    // load static array of available genres
    _tags = [NSArray arrayWithObjects:@"Rock",@"Pop",@"Techno", nil];
    //load user settings
    _filterEnabled = YES;
    _tagFilter = [NSMutableArray arrayWithObjects:@"Rock",@"Pop", nil];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0) {
        return 1;
    }else if (section ==1) {
        return _tags.count;
    }else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.detailTextLabel.enabled = YES;
    
    //section 0: switch for filter on/off
    if(indexPath.section ==0 ) {
        cell.textLabel.text = @"Genre Filter";
        UISwitch *filterSwitch = [[UISwitch alloc] initWithFrame: CGRectZero];
        [filterSwitch setOn:_filterEnabled animated:YES];
        [filterSwitch addTarget:self action:@selector(toggleFilter:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = filterSwitch;
        
    }else {//section 1: for each filter tag add a selectable row
        cell.textLabel.text = [_tags objectAtIndex:indexPath.row];
        if(_filterEnabled){
            cell.userInteractionEnabled = YES;
        }else{
            cell.userInteractionEnabled = NO;
        }
    }
    
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section ==1) {
        return @"Genres";
    }else return nil;
}

- (void) toggleFilter:(id)sender {
    _filterEnabled = !_filterEnabled;
    // todo: update view -> cells with genres need to be disabled/enabled
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
    //only
    if(indexPath.section ==1) {
        
    }
        
}

@end
