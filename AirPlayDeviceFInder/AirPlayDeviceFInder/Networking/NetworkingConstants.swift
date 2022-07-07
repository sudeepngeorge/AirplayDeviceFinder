//
//  NetworkingConstants.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import Foundation
struct NetworkingConstants {
    
    static let publicIPAddress = "https://api.ipify.org?format=json"
    
    static func ipGeoInformation(ipAddress : String) -> String {
        return "https://ipinfo.io/\(ipAddress)/geo"
    }
}
