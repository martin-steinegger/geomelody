//
//  NearestSongMapViewControllerProtocol.h
//  geomelody
//
//  Created by admin on 16.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NearestSongMapViewControllerProtocol <NSObject>
- (NSArray *) getTracks;
- (NSInteger) getCurrentTrackIndex;
- (void) showPlayer:(NSDictionary *) song;
- (void) playSongAtIndex:(int) index;
@end
