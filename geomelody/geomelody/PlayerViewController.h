//
//  DetailViewController.h
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import "UICircularSlider.h"
@protocol PlayerViewControllerProtocol <NSObject>
- (id)getNextEntry;
- (id)getPreviousEntry;
@end


@interface PlayerViewController : UIViewController

@property (strong, nonatomic) id <PlayerViewControllerProtocol> delegate;
@property (strong, nonatomic) id songItem;

@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;


@property (nonatomic, retain) IBOutlet UICircularSlider *songProgressControl;
@property (nonatomic, retain) IBOutlet NSTimer  *songProgressTimer;
@property (nonatomic, retain) IBOutlet NSDate   *pauseStart;
@property (nonatomic, retain) IBOutlet NSDate   *previousFireDate;
@property(nonatomic) BOOL isPlaying;


@property (nonatomic, retain) IBOutlet UIImageView  *artwork_picture;
@property (nonatomic, retain) IBOutlet UIImageView  *user_picture;
@property (nonatomic, retain) IBOutlet UILabel *songTitle;
@property (nonatomic, retain) IBOutlet UILabel *songInterpreter;
@property (nonatomic, retain) IBOutlet UILabel *likes;
@property (nonatomic, retain) IBOutlet UILabel *shares;


@property (nonatomic, retain) AVPlayer *audioPlayer;
- (IBAction)togglePlayingState:(id)button;
- (void)playSong;
- (void)pausePause;
- (void)togglePlayPause;
- (IBAction)playNextSong:(id)button;
- (IBAction)playPreviousSong:(id)button;
- (IBAction)songProgressDidChange:(UISlider *)slider;

- (void)setSongItem:(id)newDetailItem;


@end
