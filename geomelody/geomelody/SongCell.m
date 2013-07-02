//
//  SongCell.m
//  geomelody
//
//  Created by admin on 29.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "SongCell.h"

@implementation SongCell

@synthesize songImage, songTitle, songInterpreter, likes;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SongCell" owner:self options:nil];
        self = [nibArray objectAtIndex:0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
