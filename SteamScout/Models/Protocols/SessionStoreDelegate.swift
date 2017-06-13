//
//  SessionStoreDelegate.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/12/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

protocol SessionStoreDelegate: class {
    func sessionStoreCompleted(_ request:RequestType, withData data:Data?, andError error:NSError?)
    func sessionStoreCanceled(_ request:RequestType)
    func sessionStore(_ progress:Double, forRequest request:RequestType)
}
