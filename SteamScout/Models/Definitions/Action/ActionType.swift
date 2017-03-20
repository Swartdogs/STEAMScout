//
//  ActionType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum ActionType : Int {
    case unknown = 0, score, defense, penalty
    
    func toString() -> String {
        return (self == .score)   ? "Score"   :
            (self == .defense) ? "Defense" :
            (self == .penalty) ? "Penalty" : "Unknown"
    }
}
