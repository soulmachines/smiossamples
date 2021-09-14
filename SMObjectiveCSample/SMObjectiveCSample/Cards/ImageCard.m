//
//  ImageCard.m
//  SMObjectiveCSample
//

#import <Foundation/Foundation.h>
#import "ImageCard.h"

@interface ImageCard ()

@end

@implementation ImageCard

@synthesize component = _component;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _component = @"image";
    }
    return self;
}

@end
