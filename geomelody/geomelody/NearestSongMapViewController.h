//
//  NearestSongMapViewController.h
//  geomelody
//
//  Created by admin on 04.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMCalloutView.h"
#import "CalloutMapView.h"
#import "SongSelectionProtocol.h"

@protocol NearestSongMapViewControllerProtocol <NSObject>

-(NSArray*) getTracks;
-(NSInteger) getCurrentTrackIndex;
-(void) showPlayer:(NSDictionary*)song;
-(void) playSongAtIndex:(int)index;

@end

@interface NearestSongMapViewController : UIViewController <MKMapViewDelegate, SMCalloutViewDelegate>

@property (strong, nonatomic) id <NearestSongMapViewControllerProtocol, SongSelectionProtocol> delegate;

@property (weak, nonatomic) IBOutlet CalloutMapView *mapView;
@property (strong, nonatomic) SMCalloutView *calloutView;

-(void) updateMapAnnotations;
-(void) zoomToPins;
@end
