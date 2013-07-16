//
//  SongSelectionProtocol.h
//  geomelody
//
//  Created by admin on 16.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SongSelectionProtocol <NSObject>
- (void) selectSongIndex:(int) index;
@end