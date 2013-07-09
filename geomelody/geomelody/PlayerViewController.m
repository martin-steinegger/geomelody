//
//  DetailViewController.m
//  geomelody
//
//  Created by Martin Steinegger on 27.06.13.
//  Copyright (c) 2013 Martin Steinegger. All rights reserved.
//
#import "PlayerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SCUI.h"
#import "BackendApi.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"


@interface PlayerViewController ()
- (void)setUpView;
- (void)setUpSong;
@end

@implementation PlayerViewController
@synthesize playPauseButton;
@synthesize songItem;
@synthesize artwork_picture;
@synthesize audioPlayer;


- (IBAction)songProgressTouchStart:(UISlider *)slider {
    NSLog(@"songProgressTouchStart");
    self.songProgressTouch = YES;
//    [self pauseAudio];
}

- (IBAction)songProgressTouchEnd:(UISlider *)slider {
    NSLog(@"songProgressTouchStart");

    if (self.songProgressTouch==YES) {
        self.songProgressTouch = NO;
        self.lastActivityDate = [[NSDate alloc] init];

        float chosenSongSecond=self.songProgressControl.value;
        CMTime newTime = CMTimeMakeWithSeconds(chosenSongSecond, 1);
        [self.audioPlayer seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.songProgressTimer invalidate];
        self.songProgressTimer = nil;

        NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 1.2 ];
        
        [NSThread sleepUntilDate:future];
        self.songProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.23 target:self selector:@selector(updateSongProgressBar:)  userInfo:nil repeats:YES];
        

    }
}


- (void)updateSongProgressBar:(NSTimer *)timer {
    
    if(self.songProgressTouch == NO){
        self.songProgressControl.maximumValue = [self durationInSeconds];
        [self.songProgressControl setValueWithoutUpdate:[self currentTimeInSeconds]];
    }
}

- (void)checkActivity:(NSTimer *)timer {
    if(self.songProgressTouch == NO){
        NSDate *now = [[NSDate alloc] init];
        NSTimeInterval diff = [now timeIntervalSinceDate:self.lastActivityDate];
        NSInteger diff_time = diff;
        if(diff_time > 5){
            [self hidePlayerControls];
            [self.activityTimer setFireDate:[NSDate distantFuture]];
            [self.activityTimer invalidate];
            self.activityTimer=nil ;

        }
    }
    
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
    self.lastActivityDate = [[NSDate alloc] init];
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
    NSDictionary * newSongDict = (NSDictionary* ) newDetailItem;
    NSDictionary * oldSongDict = (NSDictionary* ) songItem;
    if([[newSongDict objectForKey:@"id"] isEqual:[oldSongDict objectForKey:@"id"]]==false)
    {
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
        if(self.audioPlayer==NULL)
            self.audioPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        else
            [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        self.songProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.23 target:self selector:@selector(updateSongProgressBar:) userInfo:nil repeats:YES];
        if(self.activityTimer!=NULL){
            [self.activityTimer setFireDate:[NSDate distantFuture]];
            [self.activityTimer invalidate];
            self.activityTimer=nil ;
        }
        self.activityTimer     = [NSTimer scheduledTimerWithTimeInterval:5    target:self selector:@selector(checkActivity:) userInfo:nil repeats:YES];
        self.lastActivityDate = [[NSDate alloc] init];
        self.pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
        self.previousFireDate = [self.songProgressTimer fireDate];

        self.songProgressControl.maximumValue = [self durationInSeconds];
        self.songProgressControl.minimumValue = 0.0;
        self.songProgressControl.continuous = YES;
    }
}

- (void) songDidFinishPlaying {
    [self playNextSong:NULL];
}

- (NSString *) changeUrlForPictureQuality:(NSString *) url{
    NSRange start =[url rangeOfString:@"-" options:NSBackwardsSearch];
    NSRange end   =[url rangeOfString:@"." options:NSBackwardsSearch];
    if(end.location < start.location){
        NSLog(@"Start > End");
        return url;
    }
    NSRange range = NSMakeRange(start.location+1,(end.location-start.location)-1);
    return [url stringByReplacingCharactersInRange:range withString:@"t300x300"];
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
        
        
        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        if (playingInfoCenter) {
            [songInfo setObject:[self.songItem objectForKey:@"title"] forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:[user objectForKey:@"username"] forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:@"Sound Cloud" forKey:MPMediaItemPropertyAlbumTitle];
 
        }
        
        
        NSObject * artworkImageUrlObject=NULL;
        if(( artworkImageUrlObject =[songItem objectForKey:@"artwork_url"])!=[NSNull null]){
            UIImageView * artWorkPicture = self.artwork_picture;
            NSString *artworkImageUrlString =[self changeUrlForPictureQuality:(NSString* )artworkImageUrlObject];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:artworkImageUrlString]];
            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            
            [self.artwork_picture setImageWithURLRequest:request placeholderImage:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                NSLog(@"success to load artwork"); //it always lands here! But nothing happens
                 [artWorkPicture setImage:image];
                 MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: image];
                 [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                 [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = songInfo;

            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                NSLog(@"fail to load artwork");
            }];
            
        } else {
            self.artwork_picture.image = nil;
            [songInfo removeObjectForKey:MPMediaItemPropertyArtwork];
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = songInfo;
        }
        
        NSObject * userImageUrlObject;
        if(( userImageUrlObject =[user objectForKey:@"avatar_url"])!=[NSNull null]){            
            [self.user_picture setImageWithURL:[NSURL URLWithString:(NSString* )userImageUrlObject]];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];

    [self.songProgressControl addTarget:self action:@selector(songProgressTouchStart:) forControlEvents:UIControlEventTouchDown];
    [self.songProgressControl addTarget:self action:@selector(songProgressTouchEnd:)   forControlEvents:UIControlEventTouchUpInside];


    self.songProgressControl.sliderStyle = UICircularSliderStyleCircle;
    self.songProgressControl.maximumTrackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    self.songProgressControl.minimumTrackTintColor = [UIColor whiteColor];
    self.songProgressControl.thumbTintColor =  [UIColor whiteColor];
    
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
    
    
    [self.user_comment.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.user_comment.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.user_comment.layer setBorderWidth: 1.0];
    [self.user_comment.layer setCornerRadius:8.0f];
    [self.user_comment.layer setMasksToBounds:YES];
    self.user_comment.clipsToBounds = YES;


    UIImage *redImage = [UIImage imageNamed:@"stretchable_image_red.png"];
    UIImage *redButtonImage = [redImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.post_button addTarget:self action:@selector(postSong:) forControlEvents:UIControlEventTouchUpInside];
    [self.post_button setBackgroundImage:redButtonImage forState:UIControlStateHighlighted];
    [self.post_button setBackgroundImage:redButtonImage forState:UIControlStateNormal];
    
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.artwork_picture.layer.bounds;

    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.7f].CGColor,
                            (id)[UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.3f].CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:0.8f],
                               nil];
    

    [self.artwork_picture.layer addSublayer:gradientLayer];


    // Controll
    // Hack http://stackoverflow.com/questions/900461/slow-start-for-avaudioplayer-the-first-time-a-sound-is-played

    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    UIImage* btnImage = [UIImage imageNamed:@"BackArrow.png"];
    [backButton setImage:btnImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0f, 0.0f, 64.0f, 41.0f);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    
    UISwipeGestureRecognizer* gestureSwipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureSwipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.artwork_picture addGestureRecognizer:gestureSwipeLeftRecognizer];
    
    UISwipeGestureRecognizer* gestureSwipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureSwipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.artwork_picture addGestureRecognizer:gestureSwipeRightRecognizer];
    
    UISwipeGestureRecognizer* gestureSwipeLeftSongProgressControl = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureSwipeLeftSongProgressControl.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.songProgressControl addGestureRecognizer:gestureSwipeLeftSongProgressControl];
    
    UISwipeGestureRecognizer* gestureSwipeRightSongProgressControl = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureSwipeRightSongProgressControl.direction = UISwipeGestureRecognizerDirectionRight;
    [self.songProgressControl addGestureRecognizer:gestureSwipeRightSongProgressControl];
    

    UITapGestureRecognizer *single_tap_songprogress_recognizer =[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleSingleTapArtwork)];
    single_tap_songprogress_recognizer.numberOfTapsRequired = 1;
    [self.songProgressControl addGestureRecognizer:single_tap_songprogress_recognizer];
    
    UITapGestureRecognizer *single_tap_artwork_recognizer =[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleSingleTapArtwork)];
    single_tap_artwork_recognizer.numberOfTapsRequired = 1;
    [self.artwork_picture addGestureRecognizer:single_tap_artwork_recognizer];

    
    UITapGestureRecognizer *single_tap_comment_field =[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleCommentSelect)];
    single_tap_comment_field.numberOfTapsRequired = 1;
    [self.user_comment addGestureRecognizer:single_tap_comment_field];
    self.playerControlsHidden = NO;

    [self createAudioSession];
	// Do any additional setup after loading the view, typically from a nib.
    [self setUpView];
}

- (void)handleSingleTapArtwork {
    // single tap action
    NSLog(@"Single Tap");
    if(self.playerControlsHidden ) {
        [self showPlayerControls];
    } else {
        // hide
        [self hidePlayerControls];
    }
}

- (void)showPlayerControls{
    // show
    self.playerControlsHidden = NO;
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
}
-(void)hidePlayerControls{
    self.playerControlsHidden = YES;

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

- (void)backButtonDidPressed:(id)aResponder {
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction) postSong:(id) sender{
    CLLocation* location = [self.delegate getCurrentGeoPosition];
    BackendApi* backendApi=[BackendApi sharedBackendApi];
    GeoMelodyBackendLocation *backendLocation = [GeoMelodyBackendLocation alloc];
    backendLocation.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    backendLocation.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    GeoMelodyBackendSong * song = [GeoMelodyBackendSong alloc];
    song.location = backendLocation;
    song.comment = self.user_comment.text;
    NSString *tag_string=[self.songItem objectForKey:@"tag_list"];
    if(tag_string != NULL){
        NSArray *tags = [tag_string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *genre_and_tags = [(NSArray*)tags mutableCopy];
        NSString *genre=[self.songItem objectForKey:@"genre"];
        if(genre!=NULL){
            [genre_and_tags addObject:genre];
        }
        song.tags = genre_and_tags;
    }
    song.soundCloudSongId = [self.songItem objectForKey:@"id"];
    NSDictionary * activeUser = [self.delegate getActiveUser];
    song.soundCloudUserId = [activeUser objectForKey:@"id"];
    [backendApi saveSong:song onSuccess:^{
        NSLog(@"Post Song successful");
        [self.post_button setEnabled:FALSE];
        [self.post_button setTitle:@"Post Done" forState:0 ];
    } onFail:^(NSError * error)  {
        NSLog(@"Post Song error");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post was not successful"
                                                        message:@"You must be connected to the internet to use this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];        
    }];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)popupTextView:(YIPopupTextView *)textView willDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    NSLog(@"will dismiss: cancelled=%d",cancelled);
    if(cancelled==NO)
        self.user_comment.text = text;
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    NSLog(@"did dismiss: cancelled=%d",cancelled);
}


- (void)handleCommentSelect
{
    YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"input here" maxCount:1000
                                        buttonStyle:YIPopupTextViewButtonStyleLeftCancelRightDone tintsDoneButton:YES];
    popupTextView.delegate = self;
    popupTextView.caretShiftGestureEnabled = YES;   // default = NO
    popupTextView.text = self.user_comment.text;
    //    popupTextView.editable = NO;                  // set editable=NO to show without keyboard
    [popupTextView showInView:NULL];
    

}


@end
