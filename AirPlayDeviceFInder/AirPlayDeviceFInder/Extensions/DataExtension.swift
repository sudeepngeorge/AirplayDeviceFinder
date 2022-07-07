//
//  NSDataExtension.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import Foundation

extension Data {
    
    /// Code to get IPAddress from Data
    func getIPAddress() -> String {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        self.withUnsafeBytes { ptr in
            guard let sockaddr_ptr = ptr.baseAddress?.assumingMemoryBound(to: sockaddr.self) else {
                return
            }
            let sockaddr = sockaddr_ptr.pointee
            guard getnameinfo(sockaddr_ptr, socklen_t(sockaddr.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                return
            }
        }
        return String(cString:hostname)
    }
}
