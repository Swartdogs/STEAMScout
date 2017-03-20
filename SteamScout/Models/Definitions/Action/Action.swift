//
//  Action.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

struct Action: PropertyListReadable {
    var section:SectionType = .tele
    var type:ActionType = .unknown
    var data:ActionData = .none
    
    init() {}
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int,
            let s = values["section"] as? Int,
            let d = values["data"] as? NSDictionary {
            self.type = ActionType(rawValue: t)!
            self.section = SectionType(rawValue: s)!
            self.data = ActionData(propertyListRepresentation: d)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        return ["type":type.rawValue, "section":section.rawValue, "data":data.propertyListRepresentation()]
    }
}
