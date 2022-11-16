//
// Copyright (c) 2022 Soul Machines. All rights reserved.
//  ConfigId.h
//  SMObjectiveCSample
//

#import <Foundation/Foundation.h>

typedef enum ConfigId {
    //Switches
    EnableOrchestration,
    UseJWT,
    UseUrlAndToken,
    
    //Inputs
    ServerUrl,
    KeyName,
    PrivateKey,
    OrchestrationUrl,
    JWTString,
    APIKeyDescription
} ConfigId;

typedef enum HeaderId {
    APIKey,
    ServerConnectionAccessToken
} HeaderId;

@interface Enums: NSObject

+ (NSString *) labelFromConfigId:(ConfigId)configId;
+ (NSString *) labelFromHeaderId:(HeaderId)headerId;

+ (BOOL) isConfigIdSwitch:(ConfigId)configId;

@end
