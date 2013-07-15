//
//  SongCell.m
//  geomelody
//
//  Created by admin on 29.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "SongCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "ImageEntropy.h"
@implementation SongCell

@synthesize songImage;
@synthesize songTitle, songInterpreter;
@synthesize likes, plays, shares;
@synthesize likesImage, playsImage, sharesImage;




- (void) setImageUrl:(NSString *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [songImage setImageWithURLRequest:request placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             NSLog(@"success to load artwork"); //it always lands here! But nothing happens
                                             ImageEntropy * entropy = [ImageEntropy alloc];
                                             [entropy setImage:image];
                                             NSRange range=[entropy calculateRowRange];
                                             CGRect cropRect = CGRectMake(0,
                                                                          range.location,
                                                                          image.size.width*image.scale,
                                                                          range.length);
                                             CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                                             // or use the UIImage wherever you like
                                             [songImage setImage:[UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation]];
                                             CGImageRelease(imageRef);
                                                                                        
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             NSLog(@"fail to load artwork");
                                         }];
    
}

-(void) setActive:(bool)active {
    [self clearSublayers];
    [self initInnerShadow];
    [self initReadabilityGradient];
    
    if(active) {
        CALayer *sublayer = [CALayer layer];
        sublayer.frame = songImage.bounds;
        sublayer.contents = (id) [UIImage imageNamed:@"play-overlay.png"].CGImage;
        sublayer.opacity = 0.8;
        [songImage.layer addSublayer:sublayer];
    
    }
}

-(void) initReadabilityGradient {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = songImage.layer.bounds;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor,
                            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9f].CGColor, nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.4f],
                                [NSNumber numberWithFloat:1.0f], nil];
    
    [songImage.layer insertSublayer:gradientLayer atIndex:0];
}

-(void) initInnerShadow {
    CAShapeLayer* shadowLayer = [CAShapeLayer layer];
    [shadowLayer setFrame:[songImage bounds]];
    
    // Standard shadow stuff
    [shadowLayer setShadowColor:[[UIColor blackColor] CGColor]];
    [shadowLayer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [shadowLayer setShadowOpacity:1.0f];
    [shadowLayer setShadowRadius:5];
    
    // Causes the inner region in this example to NOT be filled.
    [shadowLayer setFillRule:kCAFillRuleEvenOdd];
    
    // Create the larger rectangle path.
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectInset([songImage bounds], -42, -42));
    
    // Add the inner path so it's subtracted from the outer path.
    CGPathAddPath(path, NULL, [[UIBezierPath bezierPathWithRect:[shadowLayer bounds]] CGPath]);
    CGPathCloseSubpath(path);
    
    [shadowLayer setPath:path];
    CGPathRelease(path);
    
    [songImage.layer insertSublayer:shadowLayer atIndex:0];
}

-(void) clearSublayers {
    for (int i = songImage.layer.sublayers.count-1; i >= 0; i--) {
        [[songImage.layer.sublayers objectAtIndex:i] removeFromSuperlayer];
    }
}

@end
