//
//  GMSegmentedButtonBar.m
//  geomelody
//
//  Created by admin on 07.07.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "GMSegmentedButtonBar.h"

@implementation GMSegmentedButtonBar

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    if (CGRectContainsPoint(self.bounds, [touches.anyObject locationInView:self])) {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];

    [self sendActionsForControlEvents:UIControlEventTouchCancel];
}

@end
