//
//  ConfigId.h
//  SMObjectiveCSample
//

#import <Foundation/Foundation.h>

typedef enum ConfigId {
    //Switches
    EnableOrchestration,
    UseJWT,
    
    //Inputs
    ServerUrl,
    KeyName,
    PrivateKey,
    OrchestrationUrl,
    JWTString
} ConfigId;

typedef enum HeaderId {
    ServerConnection,
    AccessToken
} HeaderId;

@interface Enums: NSObject

+ (NSString *) labelFromConfigId:(ConfigId)configId;
+ (NSString *) labelFromHeaderId:(HeaderId)headerId;

+ (BOOL) isConfigIdSwitch:(ConfigId)configId;

@end
