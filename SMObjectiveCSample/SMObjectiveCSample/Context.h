//
//  Context.h
//  SMObjectiveCSample
//

#import <SMDarwin/SMDarwin.h>
#import "ImageCard.h"

#ifndef Context_h
#define Context_h

@interface Context : NSObject<PersonaReadyListener, SceneMessageListener, OnSpeechMarkerEventListener>

-(void) setScene:(_Nonnull id<Scene>) scene;

@end

@protocol ContextDelegate

-(void) showCard:(_Nonnull id<Card>) card;
-(void) hideCard:(nullable id<Card>) card;

@end


#endif /* Context_h */
