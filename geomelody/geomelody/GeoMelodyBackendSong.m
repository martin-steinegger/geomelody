//
//  Song.m
//  geomelody
//
//  Created by admin on 02.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "GeoMelodyBackendSong.h"

@implementation GeoMelodyBackendSong

@synthesize soundCloudSongId = soundCloudSongId_;
@synthesize soundCloudUserId = soundCloudUserId_;
@synthesize comment          = comment_;
@synthesize location         = location_;
@synthesize tags             = tags_;

-(NSDictionary*) toDictionary {
    NSDictionary* location = [location_ toDictionary];
    return [[NSDictionary alloc] initWithObjectsAndKeys:soundCloudSongId_, @"SoundCloudSongId", soundCloudUserId_, @"SoundCloudUserId", comment_, @"Comment", location, @"Location", tags_, @"Tags", nil];
}

@end
