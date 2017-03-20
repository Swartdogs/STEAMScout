//
//  EditType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum EditType : Int {
    case delete = 0, add
    
    mutating func reverse() {
        self = self == .delete ? .add : .delete;
    }
}
