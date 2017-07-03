//
//  ServiceStore.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/17/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ServiceStoreDelegate {
    func serviceStore(_ serviceStore:ServiceStore, withSession session:MCSession, didChangeState state:MCSessionState)
    func serviceStore(_ serviceStore:ServiceStore, withSession session:MCSession, didReceiveData data:Data, fromPeer peerId:MCPeerID)
}

class ServiceStore: NSObject {
    static let shared:ServiceStore = ServiceStore()
    
    let browser = MCNearbyServiceBrowser(peer: MatchTransfer.localPeerID,
                                         serviceType: MatchTransfer.serviceType)
    let advertiser = MCNearbyServiceAdvertiser(peer: MatchTransfer.localPeerID,
                                               discoveryInfo: [
                                                MatchTransferDiscoveryInfo.DeviceName: UIDevice().name,
                                                MatchTransferDiscoveryInfo.MatchTypeKey: "SteamScout",
                                                MatchTransferDiscoveryInfo.VersionKey: MatchTransferDiscoveryInfo.SendVersion],
                                               serviceType: MatchTransfer.serviceType)
    
    var delegate:ServiceStoreDelegate? = nil
    var foundPeers:[MCPeerID:[String:String]] = [:]
    var advertising = false
    var browsing = false
    var state = MCSessionState.notConnected
    
    fileprivate override init() {
        super.init()
        browser.delegate = self
        advertiser.delegate = self
        MatchTransfer.session.delegate = self
        print("Setting up ServiceStore")
    }
    
    func enableAdvertising() {
        if(browsing) {
            disableBrowsing()
        }
        MatchTransfer.session.delegate = self
        advertiser.startAdvertisingPeer()
        advertising = true
        print("Start Advertising")
    }
    
    func disableAdvertising() {
        MatchTransfer.session.disconnect()
        advertiser.stopAdvertisingPeer()
        advertising = false
        print("Stop Advertising")
        print("Session delegate \(String(describing: MatchTransfer.session.delegate))")
    }
    
    func enableBrowsing() {
        if(advertising) {
            disableAdvertising()
        }
        MatchTransfer.session.delegate = self
        browser.startBrowsingForPeers()
        browsing = true
        print("Start Browsing")
    }
    
    func disableBrowsing() {
        MatchTransfer.session.disconnect()
        browser.stopBrowsingForPeers()
        browsing = false
        print("Stop Browsing")
    }
    
    func sendData(_ data:Data) {
        if(state != .connected) {
            print("ERROR: state is not connected -- can't send data!")
            return
        }
        do {
            try MatchTransfer.session.send(data, toPeers: MatchTransfer.session.connectedPeers, with: .reliable)
        } catch {
            print("ERROR: could not send data!")
        }
    }
    
    func sendMessage(_ message:String) {
        if let data = message.data(using: .utf8) {
            sendData(data)
        }
    }
    
}

extension ServiceStore: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("advertiser \(advertiser) did receive invitation from peer \(peerID.displayName) with context \(String(describing: context))")
        // TEMPORARY
        invitationHandler(true, MatchTransfer.session)
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
            if let mtVersion = MatchTransferVersion(rawValue: version) {
                switch mtVersion {
                case .v0_1_0:
                    print("Adding peer \(peerID.displayName) (\(String(describing: _info[MatchTransferDiscoveryInfo.DeviceName]))) with type \(String(describing: _info[MatchTransferDiscoveryInfo.MatchTypeKey]))")
                    foundPeers[peerID] = _info
                    browser.invitePeer(peerID, to: MatchTransfer.session, withContext: nil, timeout: 10.0)
                default:
                    print("Found Peer with invalid version: \(version)! Bypassing...")
                }
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
            if let mtVersion = MatchTransferVersion(rawValue: version) {
                switch mtVersion {
                case .v0_1_0:
                    print("Removing peer \(peerID.displayName) (\(String(describing: _info?[MatchTransferDiscoveryInfo.DeviceName]))) with type \(String(describing: _info?[MatchTransferDiscoveryInfo.MatchTypeKey]))")
                    foundPeers.removeValue(forKey: peerID)
                default:
                    print("Lost Peer with invalid version: \(version)! Bypassing...")
                }
            }
        } else {
            print("Lost Peer with invalid version key! Bypassing...")
        }
    }
}

extension ServiceStore: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.state = state
        self.delegate?.serviceStore(self, withSession: session, didChangeState: state)
        print("MCSession \(session.myPeerID.displayName) with did change state to \(state.stringValue)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("MCSession \(session.myPeerID.displayName) did receive data from peer \(peerID): \(data)")
        self.delegate?.serviceStore(self, withSession: session, didReceiveData: data, fromPeer: peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("MCSession \(session.myPeerID.displayName) did receive stream \(streamName) from peer \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("MCSession \(session.myPeerID.displayName) did start receiving resource with name \(resourceName) from peer \(peerID.displayName) with progress \(progress)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("MCSession \(session.myPeerID.displayName) did finish receiving resource with name \(resourceName) from peer \(peerID.displayName) at \(localURL) with error \(String(describing: error?.localizedDescription))")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        print("MCSession \(session.myPeerID.displayName) did receive certificate \(String(describing: certificate?.debugDescription)) from peer \(peerID.displayName)")
        certificateHandler(true)
    }
}

extension MCSessionState {
    var stringValue:String {
        return self == .connected ? "connected" :
        self == .notConnected ? "notConnected" : "connecting"
    }
}
