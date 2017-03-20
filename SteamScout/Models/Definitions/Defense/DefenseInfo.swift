//
//  DefenseInfo.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

struct DefenseInfo: PropertyListReadable {
    var type:DefenseType = .unknown
    var actionPerformed:DefenseAction = .none
    
    init() {
        
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int, let a = values["action"] as? Int {
            self.type = DefenseType(rawValue: t)!
            self.actionPerformed = DefenseAction(rawValue: a)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue as AnyObject, "action":actionPerformed.rawValue as AnyObject]
        return representation as NSDictionary
    }
}
