//
//  ImageEntropy.m
//  geomelody
//
//  Created by Martin Steinegger on 08.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "ImageEntropy.h"
#import "Math.h"
#include <stdlib.h>

@implementation ImageEntropy {
    CFDataRef imageData;
    UIImage * image;
    NSInteger imageColumnSize;
    NSInteger imageRowSize;

}



- (void)setImage:(UIImage *) img
{
    image = img;
    imageData = CGDataProviderCopyData(CGImageGetDataProvider(img.CGImage));
    CGSize imageSize = [image  size];
    imageColumnSize = imageSize.width;
    imageRowSize = imageSize.height;
}

- (double) imageRowEntropy:(NSInteger) rowIndex
{
    int COUNTER[256*3];
    memset(&COUNTER[0], 0, (256*3)*sizeof(int));
    const UInt8 *pixels = CFDataGetBytePtr(imageData);
    int bytesPerPixel = CGImageGetBitsPerPixel(image.CGImage) / 8;
    for(int y = 0; y < imageColumnSize; y++) {
        int pixelStartIndex = (y + (rowIndex * imageColumnSize)) * bytesPerPixel;
        UInt8 redVal = pixels[pixelStartIndex ];
        UInt8 greenVal = pixels[pixelStartIndex + 1];
        UInt8 blueVal = pixels[pixelStartIndex + 2];
        COUNTER[redVal]++;       // red
        COUNTER[256+greenVal]++; // green
        COUNTER[512+blueVal]++;  // blue
        
    }
    double entropy = 0;
    double two_log=log(2);
    double histlength=imageColumnSize*3;

    for(int i = 0; i < 256*3; i ++){
        double p= ((double)COUNTER[i])/histlength;
        if(p!=0)
            entropy += p * log(p)/two_log;
    }
    
    return -entropy;
}

-(NSInteger) compareLines:(NSInteger) firstLineIndex secondLineIndex:(NSInteger)secondLineIndex{
    double firstLineEntropy  = [self imageRowEntropy:firstLineIndex];
    double secondLineEntropy = [self imageRowEntropy:secondLineIndex];
    if(firstLineEntropy < secondLineEntropy)
        return 1;
    else if (firstLineEntropy > secondLineEntropy)
        return -1;
    else
        return 0;

}

- (NSRange) calculateRowRange
{
    NSInteger searchWidth = 160;
    NSInteger currentSize = imageRowSize;
    NSInteger topLine = 0;
    NSInteger buttomLine = imageRowSize-1;

    while(currentSize > searchWidth){
        switch([self compareLines:topLine secondLineIndex:buttomLine]){
            case -1:
                buttomLine--;
                break;
            case 1:
                topLine++;
                break;
            case 0:

                if(arc4random_uniform(2)==0)
                    buttomLine--;
                else
                    topLine++;

                break;
                
        }
        currentSize--;
    }
    if((topLine+searchWidth) > imageRowSize)
        topLine = imageRowSize - searchWidth;
    return NSMakeRange(topLine, searchWidth);
}


@end
