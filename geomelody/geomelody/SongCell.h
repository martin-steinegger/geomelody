//
//  SongCell.h
//  geomelody
//
//  Created by admin on 29.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView * songImage;
@property (weak, nonatomic) IBOutlet UILabel * songTitle;
@property (weak, nonatomic) IBOutlet UILabel * songInterpreter;
@property (weak, nonatomic) IBOutlet UILabel * likes;
@property (weak, nonatomic) IBOutlet UILabel * plays;
@property (weak, nonatomic) IBOutlet UILabel * shares;

- (void) setImageUrl:(NSString *) url;
- (void) setActive:(bool) active;

@end
