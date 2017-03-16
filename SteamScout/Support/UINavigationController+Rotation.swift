//
//  UINavigationController+Rotation.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/15/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return visibleViewController?.supportedInterfaceOrientations ?? .all
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return visibleViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}
