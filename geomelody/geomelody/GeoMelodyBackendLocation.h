//
//  Location.h
//  geomelody
//
//  Created by admin on 02.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoMelodyBackendLocation : NSObject {
    NSNumber * latitude_;
    NSNumber * longitude_;
}

@property (nonatomic) NSNumber * latitude;
@property (nonatomic) NSNumber * longitude;

- (NSDictionary *) toDictionary;

@end
