//
//  GoToLibraryHeaderView.h
//  geomelody
//
//  Created by admin on 30.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GoToLibraryHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIButton *goToLibraryButton;

- (IBAction)goToLibraryClicked:(id)sender;

@end
