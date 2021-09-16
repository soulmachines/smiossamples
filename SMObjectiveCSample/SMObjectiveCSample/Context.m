//
//  Context.m
//  SMObjectiveCSample
//

#import <Foundation/Foundation.h>
#import <SMDarwin/SMDarwin.h>
#import "Context.h"
#import "ImageCard.h"
#import "OptionsCard.h"
#import "ExternalLinkCard.h"

@interface Context ()

@property NSMutableDictionary *cardDictionary;
@property (nonatomic) id<Scene> scene;
@property (nonatomic, weak) id<ContextDelegate> delegate;

@end

@implementation Context

@synthesize scene = _scene;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cardDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self.cardDictionary removeAllObjects];
    [self.scene removeWithPersonaReadyListener:self];
    [self.scene removeWithSceneMessageListener:self];
    NSArray *personas = [self.scene getPersonas];
    
    for (int i = 0; i < personas.count; ++i) {
        [personas[i] removeOnSpeechMarkerEventListener:self];
    }
    
    _scene = nil;
}

- (void) setDelegate:(id<ContextDelegate>)delegate
{
    _delegate = delegate;
}

- (void) setScene:(id<Scene>) scene
{
    _scene = scene;
    [self.scene addWithPersonaReadyListener:self];
    [self.scene addWithSceneMessageListener:self];
}

- (void) parseCardName:(NSString *)cardName cardContent:(NSData *)cardContent
{
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:cardContent options:0 error:&error];
    
    if (nil != error)
    {
        NSLog(@"Encountered an error converting card content to object: %@", error);
        return;
    }
    
    //Remove existing entries with the same object name.
    if(self.cardDictionary[cardName] != nil)
    {
        [self.cardDictionary removeObjectForKey:cardName];
    }
    
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *cardDictionary = object;
        NSString *component = cardDictionary[@"component"];
        
        if([component isEqualToString:@"image"])
        {
            NSString *imageUrl = (cardDictionary[@"data"])[@"url"];
            ImageCard *imageCard = [[ImageCard alloc] init];
            imageCard.imageUrl = imageUrl;
            self.cardDictionary[cardName] = imageCard;
        }
        else if([component isEqualToString:@"options"])
        {
            NSArray *options = (cardDictionary[@"data"])[@"options"];
            OptionsCard *optionsCard = [[OptionsCard alloc] init];
            optionsCard.options = options;
            self.cardDictionary[cardName] = optionsCard;
        }
        else if([component isEqualToString:@"externalLink"])
        {
            NSString *url = (cardDictionary[@"data"])[@"url"];
            NSString *imageUrl = (cardDictionary[@"data"])[@"imageUrl"];
            NSString *title = (cardDictionary[@"data"])[@"title"];
            NSString *description = (cardDictionary[@"data"])[@"description"];
            ExternalLinkCard *externalLinkCard = [[ExternalLinkCard alloc] init];
            externalLinkCard.url = url;
            externalLinkCard.imageUrl = imageUrl;
            externalLinkCard.linkDescription = description;
            externalLinkCard.title = title;
            self.cardDictionary[cardName] = externalLinkCard;
        }
        else
        {
            NSLog(@"Unimplemented card type: %@", component);
        }
    }
}

- (void) parseContext:(NSDictionary *)context withBody:(ConversationResultEventBody *)body
{
    BOOL isWatson = ([body.provider.kind isEqualToString:@"watson"]) ? TRUE : FALSE;
    
    for (NSString *key in context.allKeys)
    {
        if([key containsString:@".original"])
        {
            continue;
        }
        
        NSRange splitRange = [key rangeOfString:@"-"];
        NSRange end = NSMakeRange(splitRange.location + splitRange.length, key.length - (splitRange.location + splitRange.length));
        NSString *cardName = [key substringWithRange:end];
        NSData *cardContent = nil;
        
        if(true == isWatson)
        {
            NSError *error = nil;
            cardContent = [NSJSONSerialization dataWithJSONObject:context[key] options:0 error:&error];
            
            if(nil != error)
            {
                NSLog(@"Encountered error serializing json to data: %@", error);
                continue;
            }
        }
        else
        {
            cardContent = [(NSString *)context[key] dataUsingEncoding:NSUTF8StringEncoding];
        }

        [self parseCardName:cardName cardContent:cardContent];
    }
}

- (void) parseMetadata:(NSDictionary *)metadata withBody:(ConversationResultEventBody *)body
{
    NSDictionary *dialogflowMetadata = metadata[@"dialogflow"];
    NSDictionary *queryResult = dialogflowMetadata[@"queryResult"];
    NSArray *messages = queryResult[@"fulfillmentMessages"];
    
    for (NSDictionary *message in messages)
    {
        NSDictionary *soulmachinesData = (message[@"payload"])[@"soulmachines"];
        for (NSString *key in [soulmachinesData allKeys])
        {
            NSRange splitRange = [key rangeOfString:@"-"];
            NSRange end = NSMakeRange(splitRange.location + splitRange.length, key.length - (splitRange.location + splitRange.length));
            NSString *cardName = splitRange.length != 0 ? [key substringWithRange:end] : key;
            NSError *error = nil;
            
            NSData *cardContent = [NSJSONSerialization dataWithJSONObject:soulmachinesData[key] options:0 error:&error];
            
            if (nil != error)
            {
                NSLog(@"Encountered error serializing json to data: %@", error);
                continue;
            }

            [self parseCardName:cardName cardContent:cardContent];
        }
    }
}

- (void)onPersonaReady:(id<Persona> _Nonnull)personaReady
{
    [personaReady addOnSpeechMarkerEventListener:self];
}

- (void)onConversationResultMessage:(SceneEvent * _Nonnull)conversationResultMessage
{
    ConversationResultEventBody *body = (ConversationResultEventBody *)conversationResultMessage.body;
    
    if (nil != body)
    {
        if (nil != body.output.getContext && 0 != body.output.getContext.count)
        {
            [self parseContext:body.output.getContext withBody:body];
        }
        else if (nil != body.provider.getMetadata)
        {
            [self parseMetadata:body.provider.getMetadata withBody:body];
        }
    }
}

- (void)onRecognizeResultsMessage:(SceneEvent * _Nonnull)recognizeResultsMessage
{
    
}

- (void)onStateMessage:(SceneEvent * _Nonnull)stateMessage
{
    
}

- (void)onUserText:(NSString * _Nonnull)userText
{
    
}

- (void) onSpeechMarkerEventWithPersona:(id<Persona>)persona message:(SceneEventBody *)message
{
    SpeechMarkerEventBody *body = (SpeechMarkerEventBody *)message;
    
    if (body == nil)
    {
        return;
    }
    
    if([body.name isEqualToString:@"showcards"])
    {
        NSString *cardName = body.arguments.firstObject;
        id<Card> cardModel = self.cardDictionary[cardName];
        
        if(nil != self.delegate)
        {
            [self.delegate showCard:cardModel];
        }
    }
    if([body.name isEqualToString:@"hidecards"])
    {
        NSString *cardName = body.arguments.firstObject;
        id<Card> cardModel = nil;
        
        if (cardName != nil)
        {
            cardModel = self.cardDictionary[cardName];
        }
        
        if(nil != self.delegate)
        {
            [self.delegate hideCard:cardModel];
        }
    }
}

@end
