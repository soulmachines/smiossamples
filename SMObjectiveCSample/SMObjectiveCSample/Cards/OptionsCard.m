//
//  OptionsCard.m
//  SMObjectiveCSample
//

#import <Foundation/Foundation.h>
#import "OptionsCard.h"

@interface OptionsCard ()

@end

@implementation OptionsCard

@synthesize component = _component;
@synthesize options;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _component = @"options";
    }
    return self;
}


@end

