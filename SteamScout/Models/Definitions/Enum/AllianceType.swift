//
//  AllianceType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum AllianceType : Int {
    case unknown = 0, blue, red
    
    func toString() -> String {
        return (self == .blue) ? "Blue" :
            (self == .red)  ? "Red"  : "Unknown"
    }
}
