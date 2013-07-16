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
#import "YIPopupTextView.h"
#import "PlayerViewControllerProtocol.h"

@interface PlayerViewController : UIViewController<YIPopupTextViewDelegate>

@property (strong, nonatomic) id <PlayerViewControllerProtocol> delegate;
@property (strong, nonatomic) id songItem;

@property (nonatomic, retain) AVPlayer * audioPlayer;
@property (nonatomic, retain) IBOutlet UIButton * playPauseButton;
@property (nonatomic, retain) IBOutlet UIButton * nextButton;
@property (nonatomic, retain) IBOutlet UIButton * previousButton;
@property (nonatomic, retain) IBOutlet UICircularSlider * songProgressControl;

@property (nonatomic, retain) IBOutlet UIImageView * artwork_picture;
@property (nonatomic, retain) IBOutlet UIImageView * user_picture;
@property (nonatomic, retain) IBOutlet UITextView * user_comment;
@property (nonatomic, retain) IBOutlet UIButton * post_button;

@property (nonatomic, retain) IBOutlet UILabel * songTitle;
@property (nonatomic, retain) IBOutlet UILabel * songInterpreter;

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL playerControlsHidden;

- (IBAction) togglePlayingState:(id) button;
- (void) playAudio;
- (void) pauseAudio;
- (void) togglePlayPause;
- (IBAction) playNextSong:(id) button;
- (IBAction) playPreviousSong:(id) button;
- (void) setSongItem:(id) newDetailItem;

@end
