//
//  Service.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/18/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct MatchTransfer {
    static let serviceType = "StmSct-dataxfer"
    static let localPeerID = MCPeerID(displayName: UIDevice.current.name)
    static let session = MCSession(peer: MatchTransfer.localPeerID, securityIdentity: nil, encryptionPreference: .none)
}
