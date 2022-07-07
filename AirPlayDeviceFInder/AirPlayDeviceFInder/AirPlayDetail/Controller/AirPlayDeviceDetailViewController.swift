//
//  AirPlayDeviceDetailViewController.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import UIKit

class AirPlayDeviceDetailViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Properties
    var publicIPModel : PublicIPModel? = nil
    var publicIPGeoModel : PublicIPGeoModel? = nil
    var dataSource : [[String : String]] = []
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadIPData()
    }
    
    //MARK: - LifeCycle Methods
    /// Load IP data and Geo Information One After another.
    func loadIPData() {
        self.startActivityIndicator()
        NetworkManager.getMyPublicIPAddress {  [weak self]  publicIPModel in
            self?.publicIPModel = publicIPModel
            if let myIP = publicIPModel.ip {
                NetworkManager.getIPGeoInformation(ipAddress: myIP) { publicIPGeoModel in
                    self?.dataSource = publicIPGeoModel.getGeoInfoAsList()
                    self?.reloadData()
                    self?.stopActivityIndicator()
                } onFailure: { error in
                    print(error ?? "")
                    self?.stopActivityIndicator()
                }
            }
            else{
                self?.stopActivityIndicator()
            }
        } onFailure: { [weak self] error in
            print(error ?? "")
            self?.stopActivityIndicator()
        }
    }


    //MARK: - Helper Methods
    
    func startActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.ipAddressLabel.text = self.publicIPModel?.ip
            self.tableView.reloadData()
        }
    }
    
}


//MARK: - UITableViewDataSource

extension AirPlayDeviceDetailViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let geoInfo = dataSource[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: "geoInfoCell", for: indexPath)
        cell.textLabel?.text = geoInfo.keys.first
        cell.detailTextLabel?.text = geoInfo.values.first
        return cell
        
    }
}
