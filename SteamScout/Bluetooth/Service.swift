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

struct MatchTransferDiscoveryInfo {
    static let VersionKey = "kMatchTransferDiscoveryInfoVersionKey"
    static let DeviceName = "KMatchTransferDiscoveryInfoDeviceName"
    static let MatchTypeKey = "kMatchTransferDiscoveryInfo"
    
    static let SendVersion = "0.1.0"
}

struct MatchTransferData {
    static let MessageKey = "kMatchTransferDataMessageKey"
    static let PayloadKey = "kMatchTransferDataPayloadKey"
}
