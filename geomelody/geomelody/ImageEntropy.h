//
//  ImageEntropy.h
//  geomelody
//
//  Created by Martin Steinegger on 08.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageEntropy : NSObject
- (void) setImage:(UIImage *) img;
- (NSRange) calculateRowRange;
@end
