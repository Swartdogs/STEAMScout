//
//  MatchQueueData.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

struct MatchQueueData: PropertyListReadable {
    var matchNumber:Int = 0
    var teamNumber:Int = 0
    var alliance:AllianceType = .unknown
    
    init(match:Int, team:Int, alliance:AllianceType) {
        self.matchNumber = match
        self.teamNumber = team
        self.alliance = alliance
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let m = values["mNum"] as? Int,
            let t = values["tNum"] as? Int,
            let a = values["all"] as? Int {
            self.matchNumber = m
            self.teamNumber = t
            self.alliance = AllianceType(rawValue: a)!
        } else {
            return nil
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        return ["mNum":matchNumber, "tNum":teamNumber, "all":alliance.rawValue]
    }
}
