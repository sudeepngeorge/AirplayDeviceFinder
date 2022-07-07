//
//  AirPlayDevicesDatabaseManager.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import UIKit
import CoreData

///Database Manager Class for managing AirPlayDevice Fetch and Save.
class AirPlayDevicesDatabaseManager {
    
    private init() {}
    
    /// Fetching all AirPlayDevice from DB
    static func fetchAllAirPlayDevicesFromDB(onSuccess: @escaping (([AirPlayDevice]) ->()),
                                             onFailure:@escaping (Error)->()) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let fetchRequest: NSFetchRequest<AirPlayDevice> = AirPlayDevice.fetchRequest()
        appDelegate.persistentContainer.viewContext.perform {
            do {
                let result = try fetchRequest.execute()
                onSuccess(result)
            } catch {
                onFailure(error)
                debugPrint("Unable to Execute Fetch Request, \(error)")
            }
        }
    }
    
    /// To Save AirPlayLiveDevice to DB.
    /// Saves after converting it to ManagedObjectModels of AirPlayDevice
    static func saveAirPlayInfoDB( airplayDevicesInfos : [AirPlayLiveDevice],
                                   onSuccess:  (() ->()),
                                   onFailure: ()->()) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        
        let _ = airplayDevicesInfos.map { airPlayLiveDevice in
            let airplayDevice = AirPlayDevice(context: viewContext)
            airplayDevice.name = airPlayLiveDevice.deviceName
            airplayDevice.ipAddress = airPlayLiveDevice.ipAddress
        }
        do {
            try viewContext.save()
            onSuccess()
        }
        catch{
            print(error)
            onFailure()
        }
    }
    
}
