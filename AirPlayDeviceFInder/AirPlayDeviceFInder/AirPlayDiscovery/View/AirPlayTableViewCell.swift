//
//  AirPlayTableViewCell.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import UIKit

class AirPlayTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    ///Configure AirPlayTableViewCell from AirPlayLiveDevice properties
    func configureCell(devicesInfo : AirPlayLiveDevice) {
        DispatchQueue.main.async {
            let color = (devicesInfo.status == .Reachable) ? UIColor.blue : UIColor.red
            self.deviceNameLabel.textColor = color
            self.ipAddressLabel.textColor = color
            self.statusLabel.textColor = color
            self.deviceNameLabel.text = devicesInfo.deviceName
            self.ipAddressLabel.text = devicesInfo.ipAddress
            self.statusLabel.text = devicesInfo.status.rawValue
        }
    }
}
