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
- (void)setUpView;
- (void)setUpSong;
@end

@implementation PlayerViewController
@synthesize playPauseButton;
@synthesize songItem;

@synthesize audioPlayer;

- (IBAction)songProgressDidChange:(UISlider *)slider {
    float chosenSongSecond=self.songProgressControl.value;
    CMTime newTime = CMTimeMakeWithSeconds(chosenSongSecond, 1);
    [self.audioPlayer seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (IBAction)togglePlayingState:(id)button {
    //Handle the button pressing
    [self togglePlayPause];
}

- (void)playAudio {
    //Play the audio and set the button to represent the audio is playing
    [audioPlayer play];
    self.isPlaying = true;
    float pauseTime = -1*[self.pauseStart timeIntervalSinceNow];
    [self.songProgressTimer setFireDate:[self.previousFireDate initWithTimeInterval:pauseTime sinceDate:self.previousFireDate]];
    [playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
}

- (void)pauseAudio {
    //Pause the audio and set the button to represent the audio is paused
    [audioPlayer pause];
    self.isPlaying = false;
    self.pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    self.previousFireDate = [self.songProgressTimer fireDate];
    [self.songProgressTimer setFireDate:[NSDate distantFuture]];

    [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
}
- (void)togglePlayPause {
    //Toggle if the music is playing or paused
    if (!self.isPlaying) {
        [self playAudio];
    } else if (self.isPlaying) {
        [self pauseAudio];
    }
}

//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

// handle headphone events
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self playAudio];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self pauseAudio];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self togglePlayPause];
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
            [self playNextSong:NULL];
        } else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
            [self playPreviousSong:NULL];
        }

    }
}

- (IBAction)playNextSong:(id)button{
    id song = [self.delegate getNextEntry];
    [self setSongItem:song];
}

- (IBAction)playPreviousSong:(id)button{
    id song = [self.delegate getPreviousEntry];
    [self setSongItem:song];
}

-(void) handleSwipe:(UISwipeGestureRecognizer*) recognizer {
    id song;
    [UIView animateWithDuration:0.55 animations:^{
        [UIView setAnimationDelay:0.2];
    }];
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionDefault]];
    [animation setSpeed:0.4];
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft){
        song = [self.delegate getNextEntry];
        [animation setSubtype:kCATransitionFromLeft];
    }else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        song = [self.delegate getPreviousEntry];
        [animation setSubtype:kCAAlignmentRight];
    }
    if(!song)
        return;
    [self setSongItem:song];
    [[self.view layer] addAnimation:animation forKey:nil];
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
        // Update the song.
        audioPlayer = nil;
        [self setUpSong];
        [self playAudio];
        [self setUpView];
    }
}

- (void)setUpSong{
    if (self.songItem) {
        NSString *streamURL = [songItem objectForKey:@"stream_url"];
        NSString *streamClientAuth = [streamURL stringByAppendingString:@"?client_id=f0cfa9035abc5752e699580d5586d1e6"];
        NSURL *url = [NSURL URLWithString:streamClientAuth];
        AVURLAsset * avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        AVPlayerItem * playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
        self.audioPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        self.songProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.23 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
        self.songProgressControl.maximumValue = [self durationInSeconds];
        self.songProgressControl.minimumValue = 0.0;
        self.songProgressControl.continuous = YES;        
    }
}

- (void)setUpView
{
    if (self.songItem) {
        self.detailDescriptionLabel.text = [self.songItem description];

        
        NSObject * artworkImageUrlObject;
        UIImage *art_work_image=NULL;
        if(( artworkImageUrlObject =[songItem objectForKey:@"artwork_url"])!=[NSNull null]){
            NSURL *imageURL = [NSURL URLWithString:(NSString* )artworkImageUrlObject];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            art_work_image = [UIImage imageWithData:imageData];
            self.artwork_picture.image = art_work_image;
        }
        
        NSDictionary *user  = [songItem objectForKey:@"user"];
        NSObject * userImageUrlObject;
        if(( userImageUrlObject =[user objectForKey:@"avatar_url"])!=[NSNull null]){
            NSURL *imageURL = [NSURL URLWithString:(NSString* )userImageUrlObject];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            self.user_picture.image = image;
        }
        
        
        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
        
        if (playingInfoCenter) {
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            
            if(art_work_image != NULL){
                MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: art_work_image];
                [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            }
            [songInfo setObject:[songItem objectForKey:@"title"] forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:[user objectForKey:@"username"] forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:@"Sound Cloud" forKey:MPMediaItemPropertyAlbumTitle];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
    }
}




- (Float64)durationInSeconds {
    Float64 dur = CMTimeGetSeconds(self.audioPlayer.currentItem.asset.duration);
    return dur;
}


- (Float64)currentTimeInSeconds {
    Float64 dur = CMTimeGetSeconds([self.audioPlayer currentTime]);
    return dur;
}


- (void)updateProgressBar:(NSTimer *)timer {
    self.songProgressControl.maximumValue = [self durationInSeconds];
    self.songProgressControl.value = [self currentTimeInSeconds];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];

    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postSong:)];
    self.navigationItem.rightBarButtonItem = postButton;
    
    UISwipeGestureRecognizer* gestureSwipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureSwipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:gestureSwipeLeftRecognizer];
    
    UISwipeGestureRecognizer* gestureSwipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureSwipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:gestureSwipeRightRecognizer];
    
    [self createAudioSession];
	// Do any additional setup after loading the view, typically from a nib.
    [self setUpView];
}

- (IBAction) postSong:(id) sender{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
