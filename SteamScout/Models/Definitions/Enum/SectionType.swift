//
//  SectionType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum SectionType : Int {
    case auto = 0, tele
    
    func toString() -> String {
        return (self == .auto) ? "Autonomous" : "Teleop"
    }
}
