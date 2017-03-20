//
//  Score.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

struct Score: PropertyListReadable {
    var type:ScoreType = .unknown
    var location:ScoreLocation = .unknown
    
    init() {
        
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int, let l = values["loc"] as? Int {
            self.type = ScoreType(rawValue: t)!
            self.location = ScoreLocation(rawValue: l)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue as AnyObject, "loc":location.rawValue as AnyObject]
        return representation as NSDictionary
    }
}
