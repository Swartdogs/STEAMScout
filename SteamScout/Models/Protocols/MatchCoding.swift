//
//  MatchCoding.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/12/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

protocol MatchCoding {
    init(withPList pList:[String:AnyObject])
    
    var encodingHelper:MatchEncodingHelper { get }
}
