#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate_;
    NSString * title_;
    NSString * subtitle_;
    id tag_;
    NSNumber* index_;
}

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) id tag;
@property (nonatomic, copy) NSNumber* index;

@end
