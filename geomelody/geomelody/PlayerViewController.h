//
//  DetailViewController.h
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController : UIViewController 

@property (strong, nonatomic) id songItem;

@property (weak, nonatomic)   IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UISlider *volumeControl;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
- (IBAction)volumeDidChange:(id)slider; 
- (IBAction)togglePlayingState:(id)button; 
- (void)playSong;
- (void)pausePause;
- (void)togglePlayPause;
- (void)setSongItem:(id)newDetailItem;


@end
