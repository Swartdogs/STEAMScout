//
//  RobotState.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

struct RobotState:OptionSet {
    let rawValue:Int
    
    static let None = RobotState(rawValue:0)
    static let Stalled = RobotState(rawValue: 1 << 0)
    static let Tipped = RobotState(rawValue: 1 << 1)
    
    func toString() -> String {
        switch self.rawValue {
        case RobotState.Stalled.rawValue:
            return "Stalled"
        case RobotState.Tipped.rawValue:
            return "Tipped"
        case RobotState.Tipped.union(.Stalled).rawValue:
            return "Stall+Tip"
        default:
            return "None"
        }
    }
}
