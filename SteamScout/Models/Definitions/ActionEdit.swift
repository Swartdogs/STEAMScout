//
//  ActionEdit.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

struct ActionEdit {
    var action:Action
    var index:Int
    var edit:EditType
    
    init(edit:EditType, action:Action, atIndex index:Int) {
        self.edit = edit
        self.action = action
        self.index = index
    }
}
