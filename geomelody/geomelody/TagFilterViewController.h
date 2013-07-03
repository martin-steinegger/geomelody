//
//  TagFilterViewController.h
//  geomelody
//
//  Created by admin on 28.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TagFilterViewControllerProtocol <NSObject>
- (void) updateNearestSongList;
@end

@interface TagFilterViewController : UITableViewController

@property (strong, nonatomic) id <TagFilterViewControllerProtocol> delegate;

- (NSMutableArray *)getTagFilter;

@end
