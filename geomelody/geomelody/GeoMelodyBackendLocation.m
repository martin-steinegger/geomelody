//
//  Location.m
//  geomelody
//
//  Created by admin on 02.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "GeoMelodyBackendLocation.h"

@implementation GeoMelodyBackendLocation

@synthesize latitude  = latitude_;
@synthesize longitude = longitude_;

- (NSDictionary *) toDictionary {
    return [[NSDictionary alloc] initWithObjectsAndKeys:latitude_, @"Latitude", longitude_, @"Longitude", nil];
}

@end
