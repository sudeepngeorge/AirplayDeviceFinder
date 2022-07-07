//
//  AirPlayDevicesListView.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import UIKit

class AirPlayDevicesListViewController: UIViewController {
    
    //IBOuttlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataFoundLabel: UILabel!
    
    //Dependencies
    var authenticationManager : AuthenticationManagerProtocol!
    var airPlayExplorer : AirPlayDeviceExplorer!
    
    var dataSource : [AirPlayLiveDevice] = []
    
    //AirPlay Devices in the DB
    private var airPlayDevicesInDB : [AirPlayDevice] = []
    
    //AirPlay devices live in network
    private var airPlayDevicesLive : [AirPlayLiveDevice] = []
    
    //MARK: - Initialization & LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //:TODO : Move dependecy to outside class using injection
        airPlayExplorer = AirPlayDeviceExplorer()
        
        self.initializeUI()
        self.startDiscoveringAirPlayDevices()
    }
    
    func initializeUI() {
        self.addSignOutButton()
        self.tableView.rowHeight = 80.0
    }
    
    func addSignOutButton() {
        let rightBarButtonItem = UIBarButtonItem(title: "SignOut", style: .plain, target: self , action: #selector(onSignOut))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    
    //MARK: - Helper Methods
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.dataSource.count > 0 {
                self.noDataFoundLabel.isHidden = true
                self.tableView.isHidden = false
            }
            else {
                self.noDataFoundLabel.isHidden = false
                self.tableView.isHidden = true
            }
        }
    }
    
    //MARK: - AirPlay Devices Discovering Methods
    
    /// This methods performs foillowing operations
    /// 1. Fetch All Airplay devices previously saved in DB
    /// 2. List all the devices in the DB in UI
    /// 3. Subscribe to Live AirPlay device status
    /// 4. On availability of new device or status change update the status value in the UI
    func startDiscoveringAirPlayDevices() {
        AirPlayDevicesDatabaseManager.fetchAllAirPlayDevicesFromDB { [weak self] airPlayDevicesStored in
            self?.airPlayDevicesInDB = airPlayDevicesStored
            self?.createAirPlayDevicesList(liveDevicesList: self?.airPlayDevicesLive ?? [])
            self?.airPlayExplorer?.subscribeToAirPlayDevices(onDeviceListChange: { airPlayDeviceList in
                self?.airPlayDevicesLive = airPlayDeviceList
                self?.createAirPlayDevicesList(liveDevicesList: airPlayDeviceList)
            })
            
        } onFailure: { error in
            print("error")
        }
    }
    
    /// This Method creates [AirPlayLiveDevice] which will be used to display the tableview
    /// This methods performs foillowing operations
    /// 1. Create a datasource for tableview by updating the status of live devices to the DB devices
    /// 2. If any new device is identified in live device list, which is not a part of DB devices,
    ///    It will be saved to DB and updated to the datasource.
    func createAirPlayDevicesList(liveDevicesList : [AirPlayLiveDevice]) {
        var tempLiveList = liveDevicesList
        
        //Step 1
        //Update data source with current devices in DB with its live status
        self.dataSource = self.airPlayDevicesInDB.map { airPlayDevice -> AirPlayLiveDevice in
            var status = AirPlayDeviceStatus.UnReachable
            if let currentDevice = liveDevicesList.first(where: { liveDevice in
                return liveDevice.deviceName == airPlayDevice.wrappedName && liveDevice.ipAddress == airPlayDevice.wrappedIpAddress
            }) {
                tempLiveList.removeAll(where: { tempDevice in
                    return currentDevice == tempDevice
                })
                status = AirPlayDeviceStatus.Reachable
            }
            let dataSourceItem = AirPlayLiveDevice(deviceName: airPlayDevice.wrappedName, ipAddress: airPlayDevice.wrappedIpAddress, status: status)
            return dataSourceItem
        }
        
        //Step 2
        //Search For new airplay device in the current live list and add to datasource & DB
        for newLiveDevice in  tempLiveList {
            self.dataSource.append(newLiveDevice)
            AirPlayDevicesDatabaseManager.saveAirPlayInfoDB(airplayDevicesInfos: tempLiveList) {
                AirPlayDevicesDatabaseManager.fetchAllAirPlayDevicesFromDB { [weak self] airPlayDevicesStored in
                    self?.airPlayDevicesInDB = airPlayDevicesStored
                    self?.createAirPlayDevicesList(liveDevicesList: self?.airPlayDevicesLive ?? [])
                } onFailure: { error in
                    print("error")
                }
            } onFailure: {
            }
        }
        self.reloadData()
        
    }
    
    //MARK: - IBActions
    @objc func onSignOut() {
        self.authenticationManager?.logoutUser(completionHandler: { logoutSuccess in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.loadLoginViewController()
            }
        })
    }
}

//MARK: - UITableViewDataSource
extension AirPlayDevicesListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deviceInfo = self.dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AirPlayListCell", for: indexPath) as! AirPlayTableViewCell
        cell.configureCell(devicesInfo: deviceInfo)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension AirPlayDevicesListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let airPlayDeviceDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "AirPlayDeviceDetailViewController") as? AirPlayDeviceDetailViewController {
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(airPlayDeviceDetailViewController, animated: true)
            }
        }
    }
}
