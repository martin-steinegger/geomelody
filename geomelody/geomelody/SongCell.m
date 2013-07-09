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

@synthesize songImage, songTitle, songInterpreter, likes;

- (void) awakeFromNib {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        
    gradientLayer.frame = songImage.layer.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor,
                                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f].CGColor,
                                nil];
        
    gradientLayer.locations = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.4f],
                                   [NSNumber numberWithFloat:1.0f],
                                   nil];
        
   [songImage.layer insertSublayer:gradientLayer atIndex:0];
}

- (void) setImageUrl:(NSString *)url {
//    NSURL *imageURL = [NSURL URLWithString:url];
//    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//    songImage.image = [UIImage imageWithData:imageData];
//    [songImage setImageWithURL:[NSURL URLWithString:(NSString* )url]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [songImage setImageWithURLRequest:request placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             NSLog(@"success to load artwork"); //it always lands here! But nothing happens
                                             ImageEntropy * entropy = [ImageEntropy alloc];
                                             [entropy setImage:image];
                                             NSRange range=[entropy calculateRowRange];
                                             CGRect cropRect = CGRectMake(0, range.location, image.size.width, range.length);
                                             CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                                             // or use the UIImage wherever you like
                                             [songImage setImage:[UIImage imageWithCGImage:imageRef]];
                                             CGImageRelease(imageRef);
                                                                                        
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             NSLog(@"fail to load artwork");
                                         }];
    
}

@end
