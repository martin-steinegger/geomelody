//
//  Song.m
//  geomelody
//
//  Created by admin on 28.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "Song.h"


@implementation Song


- (NSInteger) primarykey {
    return primarykey;
}

- (NSString*) soundcloud_id {
    return soundcloud_id;
}

- (NSString*) soundcloud_user_id {
    return soundcloud_user_id;
}

- (NSString*) comment {
    return comment;
}

- (double) longitude {
    return longitude;
}

- (double) latitude {
    return latitude;
}

- (NSString*) genreTag {
    return genreTag;
}

- (NSString*) title {
    return title;
}

- (NSString*) interpreter {
    return  interpreter;
}

- (NSInteger*) likes {
    return likes;
}

- (UIImage*) songImage {
    return songImage;
}

- (id) initWithPrimaryKey:(NSInteger)key {
    if (self = [super init]){
        [self setPrimaryKey:key];
        [self setSoundcloudId:@"SoundcloudId"];
        [self setSoundcloudUserId:@"SoundcloudUserId"];
        [self setComment:@""];
        [self setGeolocation];
        [self setGenreTag:@"Rock"];
        [self setTitle:@"Title missing"];
        [self setInterpreter:@"Interpreter missing"];
        [self setLikes:0];
        [self setSongImage:[UIImage imageNamed:@"sample.jpg"]];
    }
    return self;
}

- (void) setPrimaryKey:(NSInteger)key {
    primarykey = key;
}

- (void) setSoundcloudId: (NSString*)songid {
    soundcloud_id = songid;
}
- (void) setSoundcloudUserId: (NSString*)userid {
    soundcloud_user_id = userid;
}
- (void) setComment: (NSString*)comments {
    comment = comments;
}

//sets geolocation of the song to current user location
- (void) setGeolocation {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    longitude = locationManager.location.coordinate.longitude;
    latitude = locationManager.location.coordinate.latitude;
}
- (void) setGeolocationLatitude: (double)lat andLongitude: (double)lon {
    longitude = lon;
    latitude = lat;
}

- (void) setGenreTag:(NSString *)tag {
    genreTag = tag;
}

- (void) setTitle:(NSString *)songTitle {
    title = songTitle;
}

- (void) setInterpreter:(NSString *)songInterpreter {
    interpreter = songInterpreter;
}

- (void) setLikes:(NSInteger*)songLikes {
    likes = songLikes;
}

- (void) setSongImage:(UIImage*)image {
    songImage = image;
}


- (CLLocation*)getGeolocation {
    CLLocation* geoLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    return geoLocation;
}


@end
