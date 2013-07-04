//
//  CalloutMapView.h
//  geomelody
//
//  Created by admin on 04.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SMCalloutView.h"

@interface CalloutMapView : MKMapView

@property (strong, nonatomic) SMCalloutView *calloutView;

@end
