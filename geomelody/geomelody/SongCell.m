//
//  SongCell.m
//  geomelody
//
//  Created by admin on 29.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "SongCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"

@implementation SongCell

@synthesize songImage, songTitle, songInterpreter, likes;

- (void) awakeFromNib {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        
    gradientLayer.frame = songImage.layer.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor,
                                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f].CGColor,
                                nil];
        
    gradientLayer.locations = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.4f],
                                   [NSNumber numberWithFloat:1.0f],
                                   nil];
        
   [songImage.layer insertSublayer:gradientLayer atIndex:0];
}

- (void) setImageUrl:(NSString *)url {
   [songImage setImageWithURL:[NSURL URLWithString:(NSString* )url]];
}

@end
