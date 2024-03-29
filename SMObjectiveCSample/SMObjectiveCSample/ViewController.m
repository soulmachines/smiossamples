//
// Copyright (c) 2022 Soul Machines. All rights reserved.
//  ViewController.m
//  SMObjectiveCSample
//

#import <UIKit/UIKit.h>
#import <SMDarwin/SMDarwin.h>
#import <JWT/JWT.h>
#import <JWT/JWTAlgorithmFactory.h>
#import "Enums.h"
#import "ContentAwareView.h"
#import "ViewController.h"

@import SMDarwin;

@interface ViewController ()

@end

@implementation ViewController

BOOL contentAwareViewAddingEnabled = FALSE;
UITapGestureRecognizer *tapGestureRecognizer = nil;
ContentAwareView *contentAwareView = nil;
UserMediaOptions currentUserMediaOptions = UserMediaOptionsNone;

@synthesize scene;
@synthesize isMuted;

static NSString *filename = @"SMObjectiveCSample_Log";

typedef enum CameraViewDirection {
    Left,
    Center,
    Right
} CameraViewDirection;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.muteButton setHidden:true];
    [self.contentAwareButton setHidden:true];
    [self.cameraControlView setHidden:true];
    self.connectButton.tintColor = UIColor.greenColor;
    // Do any additional setup after loading the view.
    CompletionError* loggingError = [LoggingCenter.loggingCenter setWithLogType:LogTypeFile filename:filename callback:nil];
    [LoggingCenter.loggingCenter setWithLogSeverity:LogSeverityWarning];
    if (nil != loggingError)
    {
        NSLog(@"Encountered error when setting up logger: %@", loggingError);
    }
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayViewAtRecognizerLocation:)];
    contentAwareView = [[ContentAwareView alloc] init];
    [contentAwareView setBackgroundColor:UIColor.systemPinkColor];
    
    self.scene = [SceneFactory createWithUserMediaOptions: currentUserMediaOptions];
    [self.cameraSwitch setOn:[UserMediaOptionsHelpers optionHasVideo:currentUserMediaOptions]];
    [self.microphoneSwitch setOn:[UserMediaOptionsHelpers optionHasAudio:currentUserMediaOptions]];
    
    [self.scene setWithRemoteView:self.remoteView localView:self.localView];

    [self.scene addWithDisconnectedEventListener:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *displayedSettingsKey = @"DisplayedSettings";
    BOOL hasDisplayedFirstRunSettings = [NSUserDefaults.standardUserDefaults boolForKey:displayedSettingsKey];
    if (false == hasDisplayedFirstRunSettings)
    {
        UIViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        [self presentViewController:settingsViewController animated:true completion:^{
            [NSUserDefaults.standardUserDefaults setBool:true forKey:displayedSettingsKey];
        }];
    }
}

- (void) disconnect
{
    if (true == contentAwareViewAddingEnabled)
    {
        [self toggleContentAwarenessViewCreation:nil];
    }

    [self.scene disconnect];
    self.connectButton.tintColor = UIColor.greenColor;
    [self.muteButton setHidden:true];
    [self setContentAwarenessImage:[UIImage systemImageNamed:@"square.split.bottomrightquarter.fill"]];
    self.isMuted = false;
    [self setMuteImage:[UIImage systemImageNamed:@"mic.fill"]];
    [self.contentAwareButton setHidden:true];
    [self.cameraControlView setHidden:true];
}

- (void) connect
{
    if(true == [NSUserDefaults.standardUserDefaults boolForKey:[Enums labelFromConfigId: UseUrlAndToken]])
    {
        [self connectWithUrlAndAccessToken];
    }
    else
    {
        [self connectWithAPIKey];
    }
}

- (void) connectWithAPIKey
{
    NSString *apiKey = [NSUserDefaults.standardUserDefaults stringForKey:[Enums labelFromConfigId:APIKeyDescription]];
    
    [[self.scene connectWithApiKey:apiKey userText:nil retryOptions:[[RetryOptions alloc] init]] subscribeWithCompletion:^(Completion* completion)
     {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.connectButton setEnabled:true];
            [self.activityIndicator stopAnimating];
        
            if (completion.error != nil)
            {
                NSLog(@"Error connecting to scene: %@", completion.error.debugDescription);
                NSString *message = [NSString stringWithFormat:@"%@\nError stack: %@", completion.error.userInfo[NSDebugDescriptionErrorKey], (completion.error.getStack ? completion.error.getStack : @"No further errors encountered.")];
                [self displayAlertWithTitle:@"Connection Error" andMessage:message];
                return;
            }
            
            if (completion.result != nil)
            {
                NSLog(@"Successful scene connection.");
                [self.muteButton setHidden:false];
                [self.contentAwareButton setHidden:false];
                [self.cameraControlView setHidden:false];
                self.connectButton.tintColor = UIColor.redColor;
            }
        });
    }];
}

- (void) connectWithUrlAndAccessToken
{
    NSString *jwt = @"";
    NSString *serverUrl = [NSUserDefaults.standardUserDefaults stringForKey:[Enums labelFromConfigId:ServerUrl]];
    
    if (true == [NSUserDefaults.standardUserDefaults boolForKey:[Enums labelFromConfigId:UseJWT]])
    {
        jwt = [NSUserDefaults.standardUserDefaults stringForKey:[Enums labelFromConfigId:JWTString]];
    }
    else
    {
        NSString *keyName = [NSUserDefaults.standardUserDefaults stringForKey:[Enums labelFromConfigId:KeyName]];
        NSString *privateKey = [NSUserDefaults.standardUserDefaults stringForKey:[Enums labelFromConfigId:PrivateKey]];
        BOOL useOrchestration = [NSUserDefaults.standardUserDefaults boolForKey:[Enums labelFromConfigId:EnableOrchestration]];
        NSString *orchestrationServer = [NSUserDefaults.standardUserDefaults stringForKey:[Enums labelFromConfigId:OrchestrationUrl]];
        double timestamp = [NSDate now].timeIntervalSince1970;
        //As we are using the default RetryOptions, 350 seconds should cover the internal 1 minute timeout per connection, and the 5 second delay in between connection attempts.
        double expiry = [NSDate dateWithTimeIntervalSinceNow:350].timeIntervalSince1970;
        NSDictionary *claimsSet = @{@"sm-control": (useOrchestration ? orchestrationServer : @""), @"sm-control-via-browser": @(useOrchestration), @"nbf": @(timestamp), @"exp": @(expiry), @"iat": @(timestamp), @"iss": (keyName ? keyName : @"")};
        id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:@"HS256"];
        jwt = [JWTBuilder encodePayload:claimsSet].secret(privateKey).algorithm(algorithm).encode;
    }
    
    [[self.scene connectWithUrl:(serverUrl ? serverUrl : @"") userText:nil accessToken:jwt retryOptions:[[RetryOptions alloc] init]] subscribeWithCompletion:^ (Completion* completion)
     {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.connectButton setEnabled:true];
            [self.activityIndicator stopAnimating];
        
            if (completion.error != nil)
            {
                NSLog(@"Error connecting to scene: %@", completion.error.debugDescription);
                NSString *message = [NSString stringWithFormat:@"%@\nError stack: %@", completion.error.userInfo[NSDebugDescriptionErrorKey], (completion.error.getStack ? completion.error.getStack : @"No further errors encountered.")];
                [self displayAlertWithTitle:@"Connection Error" andMessage:message];
                return;
            }
            
            if (completion.result != nil)
            {
                NSLog(@"Successful scene connection.");
                [self.muteButton setHidden:false];
                [self.contentAwareButton setHidden:false];
                [self.cameraControlView setHidden:false];
                self.connectButton.tintColor = UIColor.redColor;
            }
        });
    }];
}

- (IBAction) didToggleConnect:(id)sender
{
    if ([self.scene getSessionInfo] != nil)
    {
        [self disconnect];
    }
    else
    {
        [self.connectButton setEnabled:false];
        [self.activityIndicator startAnimating];
        [self connect];
    }
}

- (IBAction) didToggleMute:(id)sender
{
    [self toggleMute];
}

- (IBAction) viewFromLeft:(id)sender
{
    [self changeCameraViewTo:Left];
}

- (IBAction) viewFromRight:(id)sender
{
    [self changeCameraViewTo:Right];
}

- (IBAction) viewFromCenter:(id)sender
{
    [self changeCameraViewTo:Center];
}

- (IBAction) didToggleMicrophone:(id)sender
{
    BOOL hasAudio = [UserMediaOptionsHelpers optionHasAudio:currentUserMediaOptions];
    BOOL hasVideo = [UserMediaOptionsHelpers optionHasVideo:currentUserMediaOptions];
    UserMediaOptions newMedia = [UserMediaOptionsHelpers userMediaWithAudio:!hasAudio andVideo:hasVideo];
    [self updateUserMediaOptions:newMedia];
}

- (IBAction) didToggleCamera:(id)sender
{
    BOOL hasAudio = [UserMediaOptionsHelpers optionHasAudio:currentUserMediaOptions];
    BOOL hasVideo = [UserMediaOptionsHelpers optionHasVideo:currentUserMediaOptions];
    UserMediaOptions newMedia = [UserMediaOptionsHelpers userMediaWithAudio:hasAudio andVideo:!hasVideo];
    [self updateUserMediaOptions:newMedia];
}

- (void) updateUserMediaOptions:(UserMediaOptions)userMediaOptions
{
    [[self.scene updateWithUserMediaOptions:userMediaOptions] subscribeWithCompletion:^ (Completion* completion) {
        if (nil != completion.error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayAlertWithTitle:@"Media Change Error" andMessage:[NSString stringWithFormat:@"Error updating user media options: %@", completion.error]];
                [self.cameraSwitch setOn:[UserMediaOptionsHelpers optionHasVideo:currentUserMediaOptions]];
                [self.microphoneSwitch setOn:[UserMediaOptionsHelpers optionHasAudio:currentUserMediaOptions]];
            });
        }
        else
        {
            currentUserMediaOptions = userMediaOptions;
        }
    }];
}

- (void) changeCameraViewTo:(CameraViewDirection) direction
{
    if([[self.scene getFeatures] isFeatureFlagEnabled:FeatureFlagUI_SDK_CAMERA_CONTROL])
    {
        [self displayAlertWithTitle:@"Camera Control Disabled" andMessage:@"Camera control has been disabled. This can be configured in DDNA Studio."];
        return;
    }
    
    id<Persona> persona = [[self.scene getPersonas] firstObject];
    double scalar = 0;
    switch (direction) {
        case Left:
            scalar = -1;
            break;
        case Right:
            scalar = 1;
            break;
        default:
            break;
    }
    
    NSNumber *orbitDegX = scalar == 0? @0: @(10 * scalar);
    NSNumber *orbitDegY = scalar == 0 ? @0 : @(10);
    NSNumber *panDeg = scalar == 0? @0 : @(2 * scalar);
    
    NamedCameraAnimationParam *param = [[NamedCameraAnimationParam alloc] initWithCameraName:@"CloseUp" orbitDegX:orbitDegX orbitDegY:orbitDegY panDeg:panDeg tiltDeg:@0 time:@1];
    
    [[persona animateToNamedCameraWithOrbitPanWithParam:param] subscribeWithCompletion:^ (Completion *completion) {
        if (completion.error)
        {
            NSLog(@"Error animating camera: %@", completion.error.debugDescription);
        }
    }];
}

- (void) toggleMute
{
    BOOL shouldMute = !self.isMuted;
    
    if (true == shouldMute)
    {
        [[self.scene.getSpeechRecognizer stopRecognize] subscribeWithCompletion:^ (Completion* completion) {
            if (completion.error != nil)
            {
                NSLog(@"Received error stopping speech recognizer: %@", completion.error.debugDescription);
            }
            
            if (completion.result != nil)
            {
                NSLog(@"Successfully stopped speech recognizer.");
                self.isMuted = shouldMute;
                [self setMuteImage:[UIImage systemImageNamed:@"mic.slash.fill"]];
            }
        }];
    }
    else
    {
        [[self.scene.getSpeechRecognizer startRecognizeWithAudioSourceType:AudioSourceTypeProcessed] subscribeWithCompletion:^ (Completion* completion) {
            if (completion.error != nil)
            {
                NSLog(@"Received error starting speech recognizer: %@", completion.error.debugDescription);
            }
            
            if (completion.result != nil)
            {
                NSLog(@"Successfully started speech recognizer.");
                self.isMuted = shouldMute;
                [self setMuteImage:[UIImage systemImageNamed:@"mic.fill"]];
            }
        }];
    }
}

- (void) setMuteImage:(UIImage*) muteImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.muteButton setImage: muteImage forState: UIControlStateNormal];
    });
}

- (void) setContentAwarenessImage:(UIImage*) contentAwareImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentAwareButton setImage: contentAwareImage forState: UIControlStateNormal];
    });
}

- (IBAction) sendLogs
{
    if (false == MFMailComposeViewController.canSendMail)
    {
        [self displayAlertWithTitle:@"Email Error" andMessage:@"Unable to send mail from the current device."];
        return;
    }
    
    NSURL *path = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSData *logData = [NSData dataWithContentsOfURL:[path URLByAppendingPathComponent:filename]];
    
    if (nil == logData)
    {
        NSLog(@"Unable to load log data from file.");
        return;
    }
    
    MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
    mailView.mailComposeDelegate = self;
    [mailView setSubject:filename];
    [mailView addAttachmentData:logData mimeType:@"text/*" fileName:filename];
    
    BOOL validRtcLog = true;
    int logIndex = 0;
    
    while (true == validRtcLog)
    {
        NSString *rtcLogName = [NSString stringWithFormat:@"webrtc_log_%d", logIndex];
        NSData *rtcLogData = [NSData dataWithContentsOfURL:[path URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_RTCLog/%@", filename, rtcLogName]]];
        
        if (nil == rtcLogData)
        {
            validRtcLog = false;
        }
        else
        {
            [mailView addAttachmentData:rtcLogData mimeType:@"text/*" fileName:rtcLogName];
            logIndex += 1;
        }
    }
    
    [self presentViewController:mailView animated:true completion:nil];
}

- (void) displayAlertWithTitle:(NSString *) title andMessage: (NSString *) message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error != nil)
    {
        NSLog(@"Encountered an error sending mail: %@", error.debugDescription);
    }
    
    if (result == MFMailComposeResultFailed)
    {
        [self displayAlertWithTitle:@"Email Error" andMessage:@"Message failed to send."];
    }
    
    [controller dismissViewControllerAnimated:true completion:nil];
}

- (void) displayViewAtRecognizerLocation: (UITapGestureRecognizer *) recognizer
{
    CGPoint locationInView = [recognizer locationInView:self.remoteView];
    [contentAwareView setFrame:CGRectMake(locationInView.x - 20, locationInView.y - 20, 40, 40)];
    
    if (contentAwareView.superview == nil)
    {
        [self.remoteView addSubview:contentAwareView];
        [[self.scene getContentAwareness] addWithContent:contentAwareView];
    }
    
    [[[self.scene getContentAwareness] syncContentAwareness] subscribeWithCompletion: ^ (Completion* completion)
    {
        if(nil != completion.error)
        {
            NSLog(@"Encountered an error syncing the content awareness: %@", completion.error);
        }
    }];
}

- (IBAction) toggleContentAwarenessViewCreation:(id)sender
{
    if(false == [[self.scene getFeatures] isFeatureFlagEnabled:FeatureFlagUI_CONTENT_AWARENESS])
    {
        [self displayAlertWithTitle:@"Content Awareness Not Supported" andMessage:@"Content awareness isn't enabled for this Digital Human. This can be configured in DDNA Studio."];
        return;
    }
    
    contentAwareViewAddingEnabled = !contentAwareViewAddingEnabled;
    
    if(true == contentAwareViewAddingEnabled)
    {
        [self.remoteView addGestureRecognizer:tapGestureRecognizer];
        [self setContentAwarenessImage:[UIImage systemImageNamed:@"square.split.bottomrightquarter.fill"]];
    }
    else
    {
        [self setContentAwarenessImage:[UIImage systemImageNamed:@"square.split.bottomrightquarter"]];
        [self.remoteView removeGestureRecognizer:tapGestureRecognizer];
        [contentAwareView removeFromSuperview];
        [[self.scene getContentAwareness] removeWithContent:contentAwareView];
        [[[self.scene getContentAwareness] syncContentAwareness] subscribeWithCompletion: ^ (Completion* completion)
        {
            if(nil != completion.error)
            {
                NSLog(@"Encountered an error syncing the content awareness: %@", completion.error);
            }
        }];
    }
}

- (void)onDisconnectedWithReason:(NSString*)reason
{
    [self disconnect];
}

@end
