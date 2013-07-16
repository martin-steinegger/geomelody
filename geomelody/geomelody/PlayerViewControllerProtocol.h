//
//  PlayerViewControllerProtocol.h
//  geomelody
//
//  Created by admin on 16.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerViewControllerProtocol <NSObject>
- (id) getNextEntry;
- (id) getPreviousEntry;
- (id) getCurrentGeoPosition;
- (id) getActiveUser;
@end
