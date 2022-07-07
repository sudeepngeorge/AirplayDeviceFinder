//
//  PublicIPGeoModel.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import Foundation
struct PublicIPGeoModel : Codable {
    let ip : String?
    let city : String?
    let region : String?
    let country : String?
    let loc : String?
    let org : String?
    let postal : String?
    let timezone : String?
    let readme : String?
    
    
    func getGeoInfoAsList() -> [[String : String]] {
        var geoInfo = [[String : String]]()
        if city != nil {
            geoInfo.append(["City" : city!])
        }
        if region != nil {
            geoInfo.append(["Region" : region!])
        }
        if country != nil {
            geoInfo.append(["Country" : country!])
        }
        if loc != nil {
            geoInfo.append(["Location" : loc!])
        }
        if org != nil {
            geoInfo.append(["Organisation" : org!])
        }
        if postal != nil {
            geoInfo.append(["Postal Code" : postal!])
        }
        if timezone != nil {
            geoInfo.append(["Timezone" : timezone!])
        }
        if readme != nil {
            geoInfo.append(["Readme" : readme!])
        }
        return geoInfo
    }
}


