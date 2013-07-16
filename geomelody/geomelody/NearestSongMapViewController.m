//
//  NearestSongMapViewController.m
//  geomelody
//
//  Created by admin on 04.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "NearestSongMapViewController.h"
#import "MapAnnotation.h"

@interface NearestSongMapViewController ()

@end

@implementation NearestSongMapViewController

@synthesize delegate;
@synthesize calloutView;
@synthesize mapView = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"103-map" ofType:@"png"]];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Map" image:img tag:0];
        self.title = @"Map";
    }
    
    return self;
}

- (void)viewDidLoad
{
    
    
    self.calloutView = [SMCalloutView new];
    self.calloutView.delegate = self;
    self.mapView.calloutView = self.calloutView;
    self.mapView.delegate = self;
    

    
    [self updateMapAnnotations];
    [self zoomToPins];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewDidAppear:(BOOL)animated {
    [self zoomToPins];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateMapAnnotations  {
    [self removeAllPinsButUserLocation];
    
    NSArray* tracks = [delegate getTracks];
    for(NSInteger i = 0; i < [tracks count]; i++) {
        NSDictionary* track = [tracks objectAtIndex:i];
        if(!track) continue;
        NSDictionary* location = [track objectForKey:@"Location"];
        if(!location) continue;
        
        NSString* latitude = [location objectForKey:@"Latitude"];
        NSString* longitude = [location objectForKey:@"Longitude"];

        NSString* title = [track objectForKey:@"title"];
        NSDictionary *user  = [track objectForKey:@"user"];
        NSString* userName = [user objectForKey:@"username"];
        
        MapAnnotation *annotation = [MapAnnotation new];
        annotation.coordinate = (CLLocationCoordinate2D){[latitude doubleValue], [longitude doubleValue]};
        annotation.title = title;
        annotation.subtitle = userName;
        annotation.tag = track;
        annotation.index = [NSNumber numberWithInt:i];
        
        [self.mapView addAnnotation:annotation];
    }
}

-(void)zoomToPins {
    if([_mapView.annotations count] == 0)
        return;
    
    int currentTrack = [delegate getCurrentTrackIndex];
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    // use first song if no track was selected
    if(currentTrack == -1)
        currentTrack = 0;
    
    for(id<MKAnnotation> annotation in _mapView.annotations)
    {
        if([annotation isKindOfClass:[MapAnnotation class]]) {
            if ([[(MapAnnotation*) annotation index] intValue] == currentTrack){
                topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
                topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
                
                bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
                bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
            }
        }
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = 0.01; // Add a little extra space on the sides
    region.span.longitudeDelta = 0.01; // Add a little extra space on the sides
    
    region = [_mapView regionThatFits:region];
    [_mapView setRegion:region animated:YES];
}

- (void)removeAllPinsButUserLocation {
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if ( userLocation != nil ) {
        [pins removeObject:userLocation];
    }
    
    [self.mapView removeAnnotations:pins];
}

- (void)disclosureTapped:(UITapGestureRecognizer*) recognizer {
    UIButton *btn = (UIButton *) recognizer.view;
    
    [delegate playSongAtIndex:btn.tag];
    [self updateMapAnnotations];
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if([annotation isKindOfClass:[MapAnnotation class]]) {
        MapAnnotation* mapAnnotation = annotation;
        NSInteger currentTrack = [delegate getCurrentTrackIndex];
        
        MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:mapAnnotation reuseIdentifier:@""];
        if([mapAnnotation.index intValue] == currentTrack && currentTrack != -1)
            pinView.pinColor = MKPinAnnotationColorPurple;
        else
            pinView.pinColor = MKPinAnnotationColorRed;
        
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[MKUserLocation class]])
        return;
    
    if (calloutView.window)
        [calloutView dismissCalloutAnimated:NO];

    [self performSelector:@selector(popupCalloutView:) withObject:view afterDelay:1.0/3.0];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    // again, we'll introduce an artifical delay to feel more like MKMapView for this demonstration.
    [calloutView performSelector:@selector(dismissCalloutAnimated:) withObject:nil afterDelay:1.0/3.0];
}

- (void)popupCalloutView:(MKAnnotationView *)view {
    MapAnnotation* annotation = view.annotation;
    
    calloutView.title = annotation.title;
    calloutView.subtitle = annotation.subtitle;
    
    calloutView.backgroundView = [SMCalloutBackgroundView systemBackgroundView];
    
    UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [disclosure addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disclosureTapped:)]];

    disclosure.tag = [annotation.index intValue];
    
    calloutView.rightAccessoryView = disclosure;
    calloutView.calloutOffset = view.calloutOffset;
    
    [calloutView presentCalloutFromRect:view.bounds
                                 inView:view
                      constrainedToView:_mapView
               permittedArrowDirections:SMCalloutArrowDirectionAny
                               animated:YES];
}


- (NSTimeInterval)calloutView:(SMCalloutView *)theCalloutView delayForRepositionWithSize:(CGSize)offset {
    // if annotation view is coming from MKMapView, it's contained within a MKAnnotationContainerView instance
    // so we need to adjust the map position so that the callout will be completely visible when displayed
    if ([NSStringFromClass([calloutView.superview.superview class]) isEqualToString:@"MKAnnotationContainerView"]) {
        CGFloat pixelsPerDegreeLat = _mapView.frame.size.height / _mapView.region.span.latitudeDelta;
        CGFloat pixelsPerDegreeLon = _mapView.frame.size.width / _mapView.region.span.longitudeDelta;
        
        CLLocationDegrees latitudinalShift = offset.height / pixelsPerDegreeLat;
        CLLocationDegrees longitudinalShift = -(offset.width / pixelsPerDegreeLon);
        
        CGFloat lat = _mapView.region.center.latitude + latitudinalShift;
        CGFloat lon = _mapView.region.center.longitude + longitudinalShift;
        CLLocationCoordinate2D newCenterCoordinate = (CLLocationCoordinate2D){lat, lon};
        if (fabsf(newCenterCoordinate.latitude) <= 90 && fabsf(newCenterCoordinate.longitude <= 180)) {
            [_mapView setCenterCoordinate:newCenterCoordinate animated:YES];
        }
    }
    
    return kSMCalloutViewRepositionDelayForUIScrollView;
}

- (void)dismissCallout {
    [calloutView dismissCalloutAnimated:NO];
}


@end
