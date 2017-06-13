//
//  PenaltyType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum PenaltyType : Int {
    case none = 0, foul, techFoul, yellowCard, redCard
    
    func toString() -> String {
        return self == .foul       ? "Foul"           :
            self == .techFoul   ? "Technical Foul" :
            self == .yellowCard ? "Yellow Card"    :
            self == .redCard    ? "Red Card"       : "None"
    }
}
