//
//  AirPlayDevice+CoreDataProperties.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//
//

import Foundation
import CoreData

extension AirPlayDevice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AirPlayDevice> {
        return NSFetchRequest<AirPlayDevice>(entityName: "AirPlayDevice")
    }

    @NSManaged public var ipAddress: String?
    @NSManaged public var name: String?
    
    var wrappedName: String {
        return name != nil ? name! : "Un Available"
    }
    
    var wrappedIpAddress: String {
        return ipAddress != nil ? ipAddress! : "Un Available"
    }
}

extension AirPlayDevice : Identifiable {

}
