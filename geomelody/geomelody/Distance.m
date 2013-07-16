//
//  Distance.m
//  geomelody
//
//  Created by admin on 16.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "Distance.h"

@implementation DistanceHelper
+ (NSString *) convertDistanceToString:(double)distance {
    if (distance < 100) {
        return [NSString stringWithFormat:@"%g m", roundf(distance)];
    } else if (distance < 1000) {
        return [NSString stringWithFormat:@"%g m", roundf(distance / 5) * 5];
    } else if (distance < 10000) {
        return [NSString stringWithFormat:@"%g km", roundf(distance / 100) / 10];
    } else {
        return [NSString stringWithFormat:@"%g km", roundf(distance / 1000)];
    }
}
@end