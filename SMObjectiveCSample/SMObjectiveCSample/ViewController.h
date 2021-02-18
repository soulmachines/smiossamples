//
//  ViewController.h
//  SMObjectiveCSample
//

#import <UIKit/UIKit.h>
#import <SMDarwin/SMDarwin.h>
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController<MFMailComposeViewControllerDelegate>

@property SceneFactory* sceneFactory;
@property BOOL isMuted;
@property id<Scene> scene;
@property (weak, nonatomic) IBOutlet UIView *localView;
@property (weak, nonatomic) IBOutlet UIView *remoteView;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIView *cameraControlView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

