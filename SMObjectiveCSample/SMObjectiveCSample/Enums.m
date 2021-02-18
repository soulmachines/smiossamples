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
        case ServerUrl: return @"ServerUrl";
        case KeyName: return @"KeyName";
        case PrivateKey: return @"PrivateKey";
        case OrchestrationUrl: return @"Orchestration URL";
        case JWTString: return @"JWTString";
    }
}

+ (NSString *) labelFromHeaderId:(HeaderId)headerId
{
    switch (headerId) {
        case AccessToken: return @"AccessToken";
        case ServerConnection: return @"ServerConnection";
    }
}

+ (BOOL) isConfigIdSwitch:(ConfigId)configId
{
    switch (configId)
    {
        case EnableOrchestration:
            //fallthrough - EnableOrchestration and UseJWT are both switch cases.
        case UseJWT:
            return true;

        default:
            return false;
    }
}

@end
