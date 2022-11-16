//
// Copyright (c) 2021 Soul Machines. All rights reserved.
//  ContentAwareView.m
//  SMObjectiveCSample
//

#import <Foundation/Foundation.h>
#import "ContentAwareView.h"

@interface ContentAwareView ()

@end

@implementation ContentAwareView

- (PointRect * _Nonnull)getBounds
{
    return [[PointRect alloc] initWithX1:self.frame.origin.x y1:self.frame.origin.y
                                      x2:self.frame.origin.x + self.frame.size.width
                                      y2:self.frame.origin.y + self.frame.size.height];
}

- (NSString * _Nonnull)getId
{
    //Each content item within the ContentAwareness should have a unique Id, as duplicate Ids will replace existing items.
    return @"UniqueIdRepresentingView";
}

- (NSDictionary<NSString *,id> * _Nonnull)getMetadata
{
    return @{};
}

@end
