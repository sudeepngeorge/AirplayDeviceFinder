//
//  UIviewControllerExtension.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import UIKit

@objc
extension UIViewController {
    func showAlert(
        title: String?,
        message: String?,
        buttonTitles: [String]? = nil,
        completion: ((Int) -> Void)? = nil) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            var allButtons = buttonTitles ?? [String]()
            if allButtons.count == 0 {
                allButtons.append("OK")
            }
            
            for index in 0..<allButtons.count {
                let buttonTitle = allButtons[index]
                let action = UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
                    completion?(index)
                })
                alertController.addAction(action)
            }
            present(alertController, animated: true, completion: nil)
        }
}
