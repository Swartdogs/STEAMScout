//
//  FinalConfigType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum FinalConfigType : Int {
    case none = 0, climb, climbAttempt
    
    func toString() -> String {
        return (self == .climb) ? "Climb" :
            (self == .climbAttempt) ? "Attempted Climb" : "N/A"
    }
}
