//
//  BackendApi.m
//  geomelody
//
//  Created by admin on 01.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "BackendApi.h"
#import "AFNetworking.h"

#define API_ENDPOINT @"http://api.geomelody.com/resources/v1/"

static BackendApi * gBackendApi;


@implementation BackendApi

+ (void) initialize {
    static BOOL initialized = NO;

    if (!initialized) {
        initialized = YES;
        gBackendApi = [[BackendApi alloc] init];
    }
}

+ (BackendApi *) sharedBackendApi {
    return gBackendApi;
}

- (void) saveSong:(GeoMelodyBackendSong *)song onSuccess:(SaveSongRequestBlock)successCallback onFail:(ResponseErrorBlock)failiureCallback {
    AFHTTPClient * httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_ENDPOINT]];

    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    NSMutableURLRequest * request = [httpClient requestWithMethod:@"POST" path:@"song/" parameters:[song toDictionary]];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation, id responseObject) {
         if (successCallback) {
             successCallback();
         }
     } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
         NSLog(@"%@", error);
         if (failiureCallback) {
             failiureCallback(error);
         }
     }];
    [operation start];

}

- (void) getkNearestSongsWithLocation:(GeoMelodyBackendLocation *)location andFilters:(NSArray *)filters k:(NSInteger)k onSuccess:(GetNearestSongsRequestBlock)successCallback onFail:(ResponseErrorBlock)failiureCallback {
    id filterValue = filters ? [NSDictionary dictionaryWithObjectsAndKeys:filters, @"Filters", nil] : [NSNull null];
    NSDictionary * requestData = [NSDictionary dictionaryWithObjectsAndKeys:[location toDictionary], @"Location", filterValue, @"Filters", [NSNumber numberWithInt:k], @"Count", nil];

    AFHTTPClient * httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_ENDPOINT]];

    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    NSMutableURLRequest * request = [httpClient requestWithMethod:@"POST" path:@"song/nearby" parameters:requestData];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation, id responseObject) {
         if (successCallback) {
             successCallback(responseObject);
         }
     } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
         NSLog(@"%@", error);
         if (failiureCallback) {
             failiureCallback(error);
         }
     }];
    [operation start];
}

@end
