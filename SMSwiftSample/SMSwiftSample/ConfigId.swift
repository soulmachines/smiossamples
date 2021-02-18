//
//  ConfigIds.swift
//  SMSwiftSample
//

import Foundation

enum ConfigId: String {
    //Switches
    case EnableOrchestration = "EnableOrchestration"
    case UseJWT = "UseJWT"
    
    //Inputs
    case ServerUrl = "ServerUrl"
    case KeyName = "KeyName"
    case PrivateKey = "PrivateKey"
    case OrchestrationUrl = "OrchestrationUrl"
    case JWT = "JWT"
    
    func isSwitch() -> Bool {
        if self == .EnableOrchestration || self == .UseJWT {
            return true
        }
        
        return false
    }
}

enum HeaderId: String {
    case ServerConnection = "ServerConnection"
    case AccessToken = "AccessToken"
}
