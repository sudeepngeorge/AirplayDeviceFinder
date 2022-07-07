//
//  InternetRechabilityManager.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import Network
import Foundation

extension NWInterface.InterfaceType: CaseIterable {
    public static var allCases: [NWInterface.InterfaceType] = [
        .other,
        .wifi,
        .cellular,
        .loopback,
        .wiredEthernet
    ]
}

final class InternetRechabilityManager : NSObject {
    ///Signleton
    @objc static let shared = InternetRechabilityManager()
    
    ///Queue over which the internet status will be delivered
    private let queue = DispatchQueue(label: "InternetRechabilityManager")
    
    //NWPathMonitor Used to monitor the internet availability
    private let monitor: NWPathMonitor =  NWPathMonitor()
    
    //Internet available status
    @objc private(set) var isConnected = false
    
    private override init() { }
    
    //Start Monitoring the internet connection
    @objc func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
        }
        monitor.start(queue: queue)
    }
    
    //Stop monitoring the internet connection
    @objc func stopMonitoring() {
        monitor.cancel()
    }
}
