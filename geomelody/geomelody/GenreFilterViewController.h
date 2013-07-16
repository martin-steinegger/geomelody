//
//  GenreFilterViewController.h
//  geomelody
//
//  Created by admin on 28.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenreFilterViewControllerProtocol.h"

@interface GenreFilterViewController : UITableViewController

@property (strong, nonatomic) id <GenreFilterViewControllerProtocol> delegate;

- (NSMutableArray *) getGenreFilter;

@end
