//
//  GoToLibraryHeaderView.m
//  geomelody
//
//  Created by admin on 30.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "GoToLibraryHeaderView.h"


@implementation GoToLibraryHeaderView

@synthesize goToLibraryButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:@"GoToLibraryHeaderView" owner:self options:nil] objectAtIndex:0];
        CALayer *layer = [goToLibraryButton layer];
        [layer setMasksToBounds:YES];
        [layer setBorderWidth:5.0];
        [layer setCornerRadius:5.0];
        [layer setBorderColor:[[UIColor colorWithWhite:0.3 alpha:0.7] CGColor]];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)goToLibraryClicked:(id)sender {
    NSLog(@"Go to library");
}
@end
