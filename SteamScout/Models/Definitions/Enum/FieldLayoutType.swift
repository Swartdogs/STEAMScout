//
//  FieldLayoutType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import UIKit

enum FieldLayoutType: Int {
    case blueRed = 0, redBlue
    
    mutating func reverse() {
        self = self == .blueRed ? .redBlue : .blueRed
    }
    
    func getImage() -> UIImage {
        return self == .blueRed ? UIImage(named: "fieldLayoutBlueRed")! : UIImage(named: "fieldLayoutRedBlue")!
    }
}
