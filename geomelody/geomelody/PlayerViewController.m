//
//  DetailViewController.m
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//

#import "PlayerViewController.h"
#import "SCUI.h"

@interface PlayerViewController ()
- (void)setUpSongAndPlayer;
@end

@implementation PlayerViewController
@synthesize playPauseButton;
@synthesize volumeControl;
@synthesize songItem;

@synthesize audioPlayer;

- (IBAction)volumeDidChange:(UISlider *)slider {
    //Handle the slider movement
    [audioPlayer setVolume:[slider value]];
}
- (IBAction)togglePlayingState:(id)button {
    //Handle the button pressing
    [self togglePlayPause];
}

- (void)playAudio {
    //Play the audio and set the button to represent the audio is playing
    [audioPlayer play];
    [playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
}
- (void)pauseAudio {
    //Pause the audio and set the button to represent the audio is paused
    [audioPlayer pause];
    [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
}
- (void)togglePlayPause {
    //Toggle if the music is playing or paused
    if (!self.audioPlayer.playing) {
        [self playAudio];
    } else if (self.audioPlayer.playing) {
        [self pauseAudio];
    }
}
//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self playAudio];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self pauseAudio];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self togglePlayPause];
        }
    }
}

#pragma mark - Managing the detail item


-(void)createAudioSession
{
    
    // Registers this class as the delegate of the audio session.
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    // Use this code instead to allow the app sound to continue to play when the screen is locked.
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    NSError *myErr;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&myErr];
    
}

- (void)setSongItem:(id)newDetailItem
{
    if (songItem != newDetailItem) {
        songItem = newDetailItem;
        // Update the view.
        [self setUpSongAndPlayer];
    }
}

- (void)setUpSongAndPlayer
{
    if (self.songItem) {
        self.detailDescriptionLabel.text = [self.songItem description];

        NSString *streamURL = [songItem objectForKey:@"stream_url"];
        
        SCAccount *account = [SCSoundCloud account];
        
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:[NSURL URLWithString:streamURL]
                 usingParameters:nil
                     withAccount:account
          sendingProgressHandler:nil
                 responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                     NSError *playerError;
                     audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
                     [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                     [[AVAudioSession sharedInstance] setActive: YES error: nil];
                     [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                     
                     //[player prepareToPlay];
                     [self playAudio];
                 }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createAudioSession];
	// Do any additional setup after loading the view, typically from a nib.
    [self setUpSongAndPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
@end
