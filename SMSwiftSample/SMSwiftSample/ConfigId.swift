//
// Copyright (c) 2022 Soul Machines. All rights reserved.
//  ConfigIds.swift
//  SMSwiftSample
//

import Foundation

enum ConfigId: String {
    //Switches
    case EnableOrchestration = "EnableOrchestration"
    case UseJWT = "UseJWT"
    case UseUrlAndToken = "UseUrlAndToken"
    
    //Inputs
    case ServerUrl = "ServerUrl"
    case KeyName = "KeyName"
    case PrivateKey = "PrivateKey"
    case OrchestrationUrl = "OrchestrationUrl"
    case JWT = "JWT"
    case APIKeyDescription = "APIKeyDescription"
    
    func isSwitch() -> Bool {
        if self == .EnableOrchestration || self == .UseJWT || self == .UseUrlAndToken {
            return true
        }
        
        return false
    }
}

enum HeaderId: String {
    case APIKey = "APIKey"
    case ServerConnectionAccessToken = "ServerConnectionAccessToken"
}
