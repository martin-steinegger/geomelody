//
//  Song.h
//  geomelody
//
//  Created by admin on 02.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GeoMelodyBackendLocation.h"

@interface GeoMelodyBackendSong : NSObject {
    NSNumber * soundCloudSongId_;
    NSNumber * soundCloudUserId_;
    NSString * comment_;
    GeoMelodyBackendLocation * location_;
    NSArray * tags_;
}

@property (nonatomic) NSNumber * soundCloudSongId;
@property (nonatomic) NSNumber * soundCloudUserId;
@property (nonatomic) NSString * comment;
@property (nonatomic) GeoMelodyBackendLocation * location;
@property (nonatomic) NSArray * tags;

- (NSDictionary *) toDictionary;

@end
