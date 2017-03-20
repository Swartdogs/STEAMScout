//
//  ScoreLocation.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum ScoreLocation: Int {
    case unknown = 0, batter, courtyard, defenses
    
    func toString() -> String {
        return (self == .batter)    ? "Batter"    :
            (self == .courtyard) ? "Courtyard" :
            (self == .defenses)  ? "Defenses"  : "Unknown"
    }
}
