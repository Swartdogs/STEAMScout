//
//  ResultType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum ResultType : Int {
    case none = 0, loss, win, tie, noShow
    
    func toString() -> String {
        return (self == .loss) ? "Loss" :
            (self == .win) ? "Win" :
            (self == .tie) ? "Tie" :
            (self == .noShow) ? "No Show" : "N/A"
    }
}
