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
    [self.playPauseButton setImage:[UIImage imageNamed:@"pause64.png"] forState:UIControlStateNormal];
}

- (void)pauseAudio {
    //Pause the audio and set the button to represent the audio is paused
    [audioPlayer pause];
    self.isPlaying = false;
    self.pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    self.previousFireDate = [self.songProgressTimer fireDate];
    [self.songProgressTimer setFireDate:[NSDate distantFuture]];
    [self.playPauseButton setImage:[UIImage imageNamed:@"play64.png"] forState:UIControlStateNormal];
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
        [animation setSubtype:kCATransitionFromRight];
    }else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        song = [self.delegate getPreviousEntry];
        [animation setSubtype:kCATransitionFromLeft];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        self.audioPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        self.songProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.23 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
        self.songProgressControl.maximumValue = [self durationInSeconds];
        self.songProgressControl.minimumValue = 0.0;
        self.songProgressControl.continuous = YES;
    }
}

- (void) songDidFinishPlaying {
    [self playNextSong:NULL];
}

- (void)setUpView
{
    if (self.songItem) {
        
        self.songTitle.text = [self.songItem objectForKey:@"title"];
        NSDictionary *user  = [self.songItem objectForKey:@"user"];
        self.songInterpreter.text = [user objectForKey:@"username"];
        
        NSNumber *favoritings_count = [songItem objectForKey:@"favoritings_count"];
        self.likes.text = [NSString stringWithFormat:@"%d",(int)[favoritings_count intValue]];

        NSNumber *shared_count = [songItem objectForKey:@"shared_to_count"];
        self.shares.text = [NSString stringWithFormat:@"%d",(int)[shared_count intValue]];
        
        NSObject * artworkImageUrlObject;
        UIImage *art_work_image=NULL;
        if(( artworkImageUrlObject =[songItem objectForKey:@"artwork_url"])!=[NSNull null]){
            NSURL *imageURL = [NSURL URLWithString:(NSString* )artworkImageUrlObject];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            art_work_image = [UIImage imageWithData:imageData];
            self.artwork_picture.image = art_work_image;
        }
        
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
            [songInfo setObject:[self.songItem objectForKey:@"title"] forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:[user objectForKey:@"username"] forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:@"Sound Cloud" forKey:MPMediaItemPropertyAlbumTitle];
            if(art_work_image != NULL){
                MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: art_work_image];
                [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            }else{
                [songInfo removeObjectForKey:MPMediaItemPropertyArtwork];
            }
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = songInfo;
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
    [self.songProgressControl setValueWithoutUpdate:[self currentTimeInSeconds]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    //Layout
    //transparent navigationbar
    self.navigationController.navigationBar.translucent = YES; // Setting this slides the view up, underneath the nav bar (otherwise it'll appear black)
    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
    UIImage *img = [[UIImage alloc] init];
    UIImage *maskedImage = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(img.CGImage, colorMask)];
    [self.navigationController.navigationBar setBackgroundImage:maskedImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage: [[UIImage alloc] init]];

    [self.songProgressControl addTarget:self action:@selector(songProgressDidChange:) forControlEvents:UIControlEventValueChanged];
    self.songProgressControl.sliderStyle = UICircularSliderStyleCircle;
    self.songProgressControl.maximumTrackTintColor = [UIColor blackColor];
    
    [self.playPauseButton setBackgroundColor:[UIColor clearColor]];
    [self.playPauseButton setImage:[UIImage imageNamed:@"pause64.png"] forState:UIControlStateNormal];
    [self.nextButton setBackgroundColor:[UIColor clearColor]];
    [self.previousButton setBackgroundColor:[UIColor clearColor]];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.artwork_picture.bounds];
    self.artwork_picture.layer.masksToBounds = NO;
    self.artwork_picture.layer.shadowColor = [UIColor blackColor].CGColor;
    self.artwork_picture.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.artwork_picture.layer.shadowOpacity = 0.5f;
    self.artwork_picture.layer.shadowPath = shadowPath.CGPath;
    

    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.artwork_picture.layer.bounds;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithWhite:0.9f alpha:0.8f].CGColor,
                            (id)[UIColor colorWithWhite:0.0f alpha:0.3f].CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:0.8f],
                               nil];
    

    [self.artwork_picture.layer addSublayer:gradientLayer];


    // Controll
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0f, 0.0f, 64.0f, 41.0f);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postSong:) forControlEvents:UIControlEventTouchUpInside];
    postButton.frame = CGRectMake(0.0f, 0.0f, 64.0f, 41.0f);
    UIBarButtonItem *postButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postButton];
    self.navigationItem.rightBarButtonItem = postButtonItem;
    
    
    UISwipeGestureRecognizer* gestureSwipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureSwipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.artwork_picture addGestureRecognizer:gestureSwipeLeftRecognizer];
    
    UISwipeGestureRecognizer* gestureSwipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureSwipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.artwork_picture addGestureRecognizer:gestureSwipeRightRecognizer];

    UITapGestureRecognizer *single_tap_songprogress_recognizer =[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleSingleTapArtwork)];
    single_tap_songprogress_recognizer.numberOfTapsRequired = 1;
    [self.songProgressControl addGestureRecognizer:single_tap_songprogress_recognizer];
    UITapGestureRecognizer *single_tap_artwork_recognizer =[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleSingleTapArtwork)];
    single_tap_artwork_recognizer.numberOfTapsRequired = 1;
    [self.artwork_picture addGestureRecognizer:single_tap_artwork_recognizer];


    [self createAudioSession];
	// Do any additional setup after loading the view, typically from a nib.
    [self setUpView];
}

- (void)handleSingleTapArtwork {
    static BOOL firstTap = NO;
    // single tap action
    NSLog(@"Single Tap");
    if(firstTap) {
        // show
        firstTap = NO;
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.4;
        [self.previousButton.layer addAnimation:animation forKey:nil];
        [self.playPauseButton.layer addAnimation:animation forKey:nil];
        [self.nextButton.layer addAnimation:animation forKey:nil];
        [self.songProgressControl.layer addAnimation:animation forKey:nil];
        self.previousButton.hidden = NO;
        self.playPauseButton.hidden = NO;
        self.nextButton.hidden = NO;
        self.songProgressControl.hidden = NO;
    } else {
        // hide
        firstTap = YES;
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.4;
        [self.previousButton.layer addAnimation:animation forKey:nil];
        [self.playPauseButton.layer addAnimation:animation forKey:nil];
        [self.nextButton.layer addAnimation:animation forKey:nil];
        [self.songProgressControl.layer addAnimation:animation forKey:nil];
        self.previousButton.hidden = YES;
        self.playPauseButton.hidden = YES;
        self.nextButton.hidden = YES;
        self.songProgressControl.hidden = YES;
        

    }
}


- (void)backButtonDidPressed:(id)aResponder {
    [self.navigationController popViewControllerAnimated:TRUE];
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
    return self;
}

@end
