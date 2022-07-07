//
//  AppDelegateExtension.swift
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

import UIKit

extension AppDelegate {
    func setRootViewController(viewController : UIViewController) {
        if (self.window == nil) {
            self.window = UIWindow.init(frame: UIScreen.main.bounds)
        }
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
    }
}
