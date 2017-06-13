//
//  Actionable.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/12/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

protocol Actionable {
    func updateMatchWithAction(_ action:Action)
    func aggregateActionsPerformed()
}
