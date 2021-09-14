//
//  ExternalLinkCard.h
//  SMObjectiveCSample
//

#ifndef ExternalLinkCard_h
#define ExternalLinkCard_h

#import "Card.h"

@interface ExternalLinkCard: NSObject<Card>

@property NSString *url;
@property NSString *imageUrl;
@property NSString *title;
@property NSString *linkDescription;

@end

#endif /* ExternalLinkCard_h */
