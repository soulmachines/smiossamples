//
//  Context.h
//  SMObjectiveCSample
//

#import <SMDarwin/SMDarwin.h>

#ifndef Context_h
#define Context_h

@interface Context : NSObject<PersonaReadyListener, SceneMessageListener, OnSpeechMarkerEventListener>

-(void) setScene:(id<Scene>) scene;

@end


#endif /* Context_h */
