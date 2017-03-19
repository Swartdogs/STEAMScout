//
//  DefenseAction.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum DefenseAction: Int {
    case none = 0, crossed, attemptedCross, crossedWithBall, assistedCross
    
    func toString() -> String {
        return (self == .crossed)         ? "Crossed"             :
            (self == .attemptedCross)  ? "Attempted Cross"     :
            (self == .crossedWithBall) ? "Crossed With Ball"   :
            (self == .assistedCross)   ? "Assisted With Cross" : "None"
    }
}
