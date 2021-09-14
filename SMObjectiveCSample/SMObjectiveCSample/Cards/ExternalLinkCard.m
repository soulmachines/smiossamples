//
//  ExternalLinkCard.m
//  SMObjectiveCSample
//

#import <Foundation/Foundation.h>
#import "ExternalLinkCard.h"

@interface ExternalLinkCard ()

@end

@implementation ExternalLinkCard

@synthesize component = _component;
@synthesize title;
@synthesize linkDescription;
@synthesize imageUrl;
@synthesize url;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _component = @"externalLink";
    }
    return self;
}


@end
