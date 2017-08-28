//
//  ServiceStoreDelegate.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 8/23/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ServiceStoreDelegate {
    func serviceStore(_ serviceStore:ServiceStore, withSession session:MCSession, didChangeState state:MCSessionState)
    func serviceStore(_ serviceStore:ServiceStore, withSession session:MCSession, didReceiveData data:Data, fromPeer peerId:MCPeerID)
    func handleShowDataSelectionUIWithServiceStore(_ serviceStore: ServiceStore)
    func handleHideDataSelectionUIWithServiceStore(_ serviceStore: ServiceStore)
    func handleShowInvitationPendingUIWithServiceStore(_ serviceStore: ServiceStore)
    func handleShowConnectingWithServiceStore(_ serviceStore: ServiceStore)
    func handleShowSendingDataUIWithServiceStore(_ serviceStore: ServiceStore)
    func handleShowReceivingDataUIWithServiceStore(_ serviceStore: ServiceStore)
    func handleShowCompleteUIWithServiceStore(_ serviceStore: ServiceStore)
    func handleShowErrorUIWithServiceStore(_ serviceStore: ServiceStore, fromState state: ServiceState, withUserInfo userInfo: Any?)
}
