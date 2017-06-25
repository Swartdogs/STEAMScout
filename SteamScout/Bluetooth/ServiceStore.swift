//
//  ServiceStore.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/17/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ServiceStore: NSObject {
    static let shared:ServiceStore = ServiceStore()
    
    let browser = MCNearbyServiceBrowser(peer: MatchTransfer.localPeerID, serviceType: MatchTransfer.serviceType)
    let advertiser = MCNearbyServiceAdvertiser(peer: MatchTransfer.localPeerID, discoveryInfo: nil, serviceType: MatchTransfer.serviceType)
    
    var foundPeers:[MCPeerID:[String:String]] = [:]
    
    fileprivate override init() {
        super.init()
        browser.delegate = self
        advertiser.delegate = self
        MatchTransfer.session.delegate = self
    }
}

extension ServiceStore: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("advertiser \(advertiser) did receive invitation from peer \(peerID) with context \(context)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("advertiser \(advertiser) did not start advertising due to error \(error.localizedDescription)")
    }
}

extension ServiceStore: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let _info = info else {
            print("Discovery Info is null! Bypassing...");
            return
        }
        
        if let version = _info[MatchTransferDiscoveryInfo.VersionKey] {
            print("Found Peer with protocol version: \(version)")
            
            if version == "0.1.0" {
                print("Adding peer \(peerID) (\(_info[MatchTransferDiscoveryInfo.DeviceName])) with type \(_info[MatchTransferDiscoveryInfo.MatchTypeKey])")
                foundPeers[peerID] = _info
            } else {
                print("Found Peer with invalid version: \(version)! Bypassing...")
            }
        } else {
            print("Found Peer with invalid version key! Bypassing...")
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Did not start browsing for peers: \(error.localizedDescription)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let _info = foundPeers[peerID]
        
        if let version = _info?[MatchTransferDiscoveryInfo.VersionKey] {
            print("Lost Peer with protocol version: \(version)")
            
            if version == "0.1.0" {
                print("Removing peer \(peerID) (\(_info?[MatchTransferDiscoveryInfo.DeviceName])) with type \(_info?[MatchTransferDiscoveryInfo.MatchTypeKey])")
                foundPeers.removeValue(forKey: peerID)
            } else {
                print("Lost Peer with invalid version: \(version)! Bypassing...")
            }
        } else {
            print("Lost Peer with invalid version key! Bypassing...")
        }
    }
}

extension ServiceStore: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("MCSession \(session) with peer \(peerID) did change state to \(state)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("MCSession \(session) did receive data from peer \(peerID): \(data)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("MCSession \(session) did receive stream \(streamName) from peer \(peerID)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("MCSession \(session) did start receiving resource with name \(resourceName) from peer \(peerID) with progress \(progress)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("MCSession \(session) did finish receiving resource with name \(resourceName) from peer \(peerID) at \(localURL) with error \(error?.localizedDescription)")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        print("MCSession \(session) did receive certificate \(certificate?.debugDescription) from peer \(peerID)")
    }
}
