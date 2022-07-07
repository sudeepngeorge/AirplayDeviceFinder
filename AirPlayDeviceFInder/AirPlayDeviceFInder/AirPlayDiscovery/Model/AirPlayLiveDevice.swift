//
//  AirPlayLiveDevice.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import Foundation

struct AirPlayLiveDevice {
    let deviceName : String
    var ipAddress : String
    let status : AirPlayDeviceStatus
}

//MARK: - AirPlayLiveDevice - Equatable Protocol Implementation
///Extension to compare 2 AirPlayLiveDevice are equal
extension AirPlayLiveDevice : Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.deviceName == rhs.deviceName && lhs.ipAddress == rhs.ipAddress
    }
}
