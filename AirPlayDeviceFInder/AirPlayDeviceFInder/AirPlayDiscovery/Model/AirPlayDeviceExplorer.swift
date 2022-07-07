//
//  AirPlayDeviceExplorer.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import UIKit
import Network

class AirPlayDeviceExplorer: NSObject {
    
    let airPlayServiceType = "_airplay._tcp"
    
    //MARK: - Properties
    var netServiceBrowser : NetServiceBrowser = NetServiceBrowser()
    
    //Subscription Callbacks
    var onAirPlayDeviceChangeCallBack : ( ([AirPlayLiveDevice]) -> ())? = nil

    /// All the detected AirPlayDevices.
    /// On the data set, it will keep updating the onAirPlayDeviceChangeCallBack with new list of devices
    var airPlayDevices : [AirPlayLiveDevice] = [] {
        didSet {
            onAirPlayDeviceChangeCallBack?(airPlayDevices)
        }
    }
    ///List of NetService objects to avoid deinitialization while resolving the IPAddress
    var netServices : [NetService] = []
    
    //MARK: - LifeCycle Methods
    override init() {
        super.init()
        netServiceBrowser.delegate = self
    }
    
    /// Subscribe to airplay devices using NetServiceBrowser in all the domain
    func subscribeToAirPlayDevices(onDeviceListChange : @escaping ( [AirPlayLiveDevice]) -> ()) {
        onAirPlayDeviceChangeCallBack = onDeviceListChange
        netServiceBrowser.searchForServices(ofType: airPlayServiceType , inDomain: "")
    }
    
    func findIPAddressForService(service : NetService) {
        service.delegate = self
        service.resolve(withTimeout: 3)
    }
}

//MARK: - NetServiceBrowserDelegate
extension AirPlayDeviceExplorer :  NetServiceBrowserDelegate {

    ///Called when a new airplay device is available
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        netServices.append(service)
        self.findIPAddressForService(service: service)
    }
    
    ///Called when an existing airplay device is removed from netwoork
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        netServices.append(service)
        self.findIPAddressForService(service: service)
    }
}

extension AirPlayDeviceExplorer : NetServiceDelegate {
    
    ///Called when an ipAddress of the NetService is resolved.
    ///1. Get IPAddress from the Data
    ///2. Remove the NetServices from the [NetServices] array
    ///3. If AirplayLiveDevice list contains the resolved address, we assume the live device was removed
    ///4. If AirplayLiveDevice list doesnot contains the  resolved address, we assume the device was newly added
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let data = sender.addresses?.first else { return }
        
        //Step 1
        let ipAddress = data.getIPAddress()
        
        //Step 2
        if let netServiceIndex = netServices.firstIndex(where: { netServices in
            netServices == sender
        }) {
            netServices.remove(at: netServiceIndex)
            sender.delegate = nil
        }
        
        if let airPlayDeviceIndex = airPlayDevices.firstIndex (where: { airPlayDevice in
            airPlayDevice.deviceName == sender.name
        }) {
            //Step 3
            airPlayDevices.remove(at: airPlayDeviceIndex)
        }
        else {
            //Step 4
            let device = AirPlayLiveDevice(deviceName: sender.name, ipAddress: ipAddress, status: .Reachable)
            airPlayDevices.append(device)
        }
    }
    
}

