//
//  ScoreType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum ScoreType: Int {
    case unknown = 0, missedHigh, high, missedLow, low
    
    var missed:Bool {
        return (self == .missedHigh || self == .missedLow)
    }
    
    func toString() -> String {
        return (self == .high)        ? "Scored High Goal" :
            (self == .low)         ? "Scored Low Goal " :
            (self == .missedHigh)  ? "Missed High Goal" :
            (self == .missedLow)   ? "Missed Low Goal"  : "Unknown"
    }
}
