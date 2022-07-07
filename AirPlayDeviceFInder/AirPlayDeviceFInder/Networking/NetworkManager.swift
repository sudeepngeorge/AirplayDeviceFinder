//
//  NetworkManager.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import Foundation


class NetworkManager {
   
    private init(){}
    
    ///Method to load Public IPAddress
    static func getMyPublicIPAddress(onSuccess : @escaping (_ publicIPModel : PublicIPModel) -> () , onFailure : @escaping (Error?) -> ()) {
        self.getMethod(url: NetworkingConstants.publicIPAddress ,success: onSuccess,failure: onFailure)
    }
    
    ///Method to load IPGeoInformation
    static func getIPGeoInformation(ipAddress : String, onSuccess : @escaping (_ publicIPGeoModel : PublicIPGeoModel) -> () , onFailure : @escaping (Error?) -> ()) {
        self.getMethod(url: NetworkingConstants.ipGeoInformation(ipAddress: ipAddress),success: onSuccess,failure: onFailure)
    }
    
    /// GET Service Call to API
    static func getMethod<T: Decodable>(url: String, success: @escaping (T) -> (), failure: @escaping (Error?) -> ()){
        let url = URL(string: url)
        URLSession.shared.dataTask(with: url!){(data,  response, error) in
            guard let data = data else {
                failure(error)
                return
            }
            guard error == nil else {
                failure(error)
                return
            }
            do{
                let obj = try JSONDecoder().decode(T.self, from: data)
                success(obj)
            }catch let jsonErr{
                failure(jsonErr)
            }
        }.resume()
    }
}

