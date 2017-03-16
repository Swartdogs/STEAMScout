//
//  AppUtility.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/16/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

struct AppUtility {
    static func lockOrientation(to orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    static func unlockOrientation() {
        lockOrientation(to: .all)
    }
}
