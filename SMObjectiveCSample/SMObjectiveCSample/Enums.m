//
//  ConfigId.m
//  SMObjectiveCSample
//

#import "Enums.h"

@implementation Enums

+ (NSString *) labelFromConfigId:(ConfigId)configId
{
    switch (configId) {
        case EnableOrchestration: return @"EnableOrchestration";
        case UseJWT: return @"UseJWT";
        case UseUrlAndToken: return @"UseUrlAndToken";
        case ServerUrl: return @"ServerUrl";
        case KeyName: return @"KeyName";
        case PrivateKey: return @"PrivateKey";
        case OrchestrationUrl: return @"OrchestrationUrl";
        case JWTString: return @"JWT";
        case APIKeyDescription: return @"APIKeyDescription";
    }
}

+ (NSString *) labelFromHeaderId:(HeaderId)headerId
{
    switch (headerId) {
        case APIKey: return @"APIKey";
        case ServerConnectionAccessToken: return @"ServerConnectionAccessToken";
    }
}

+ (BOOL) isConfigIdSwitch:(ConfigId)configId
{
    switch (configId)
    {
        case UseUrlAndToken:
            //fallthrough - UseUrlAndToken, EnableOrchestration, and UseJWT are all switch cases.
        case EnableOrchestration:
            //fallthrough - UseUrlAndToken, EnableOrchestration, and UseJWT are all switch cases.
        case UseJWT:
            return true;

        default:
            return false;
    }
}

@end
