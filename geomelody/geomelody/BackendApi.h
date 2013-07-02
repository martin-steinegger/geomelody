//
//  BackendApi.h
//  geomelody
//
//  Created by admin on 01.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "GeoMelodyBackendSong.h"
#import "GeoMelodyBackendLocation.h"

typedef void (^SaveSongRequestBlock) ();
typedef void (^GetNearestSongsRequestBlock) (NSArray*);
typedef void (^ResponseErrorBlock) (NSError*);

@interface BackendApi : NSObject

+(BackendApi*) sharedBackendApi;

-(void) saveSong:(GeoMelodyBackendSong*) song onSuccess:(SaveSongRequestBlock) successCallback onFail:(ResponseErrorBlock) failiureCallback;

-(void) getkNearestSongsWithLocation:(GeoMelodyBackendLocation*) location andFilters:(NSArray*) filters k:(NSInteger)k
                           onSuccess:(GetNearestSongsRequestBlock) successCallback onFail:(ResponseErrorBlock) failiureCallback;
@end