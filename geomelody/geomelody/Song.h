//
//  Song.h
//  geomelody
//
//  Created by admin on 28.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Song : NSObject {
    NSInteger primarykey;
    NSString* soundcloud_id;
    NSString* soundcloud_user_id;
    NSString* comment;
    double longitude;
    double latitude;
    NSString* genreTag;
    NSString* title;
    NSString* interpreter;
    NSInteger* likes;
    UIImage* songImage;
}

- (NSInteger) primarykey;
- (NSString*) soundcloud_id;
- (NSString*) soundcloud_user_id;
- (NSString*) comment;
- (double) longitude;
- (double) latitude;
- (NSString*) genreTag;
- (NSString*) title;
- (NSString*) interpreter;
- (NSInteger*) likes;
- (UIImage*) songImage;

- (id) initWithPrimaryKey:(NSInteger)key;

- (void) setPrimaryKey:(NSInteger)key;
- (void) setSoundcloudId: (NSString*)songid;
- (void) setSoundcloudUserId: (NSString*)userid;
- (void) setComment: (NSString*)comments;
- (void) setGeolocation;
- (void) setGeolocationLatitude: (double)lat andLongitude: (double)lon;
- (void) setGenreTag:(NSString*)tag;
- (void) setTitle:(NSString*)songTitle;
- (void) setInterpreter:(NSString*)songInterpreter;
- (void) setLikes:(NSInteger*)songLikes;
- (void) setSongImage:(UIImage*)image;

- (CLLocation*)getGeolocation;

@end
