//
//  ServiceStore.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/17/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SwiftState

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
    let stateMachine = createServiceStateMachine()
    
    weak var delegate:ServiceStoreDelegate?
    var foundPeers:[MCPeerID:[String:String]] = [:]
    var sessionState:MCSessionState = .notConnected
    
    var machineState:ServiceState {
        return stateMachine.state
    }
    
    var advertising: Bool {
        return [
            ServiceState.advertSelectingData,
            ServiceState.advertReady,
            ServiceState.advertRunning,
            ServiceState.advertInvitationPending,
            ServiceState.advertConnecting,
            ServiceState.advertSendingData
        ].contains(stateMachine.state)
    }
    
    var browsing:Bool {
        return [
            ServiceState.browseRunning,
            ServiceState.browseConnecting,
            ServiceState.browseReceivingData
        ].contains(stateMachine.state)
    }
    
    fileprivate override init() {
        super.init()
        browser.delegate = self
        advertiser.delegate = self
        MatchTransfer.session.delegate = self
        print("Setting up ServiceStore")
    }
    
    func startAdvertising() {
        if(browsing) {
            stopBrowsing()
        }
        stateMachine <-! ServiceEvent.advertProceed
    }
    
    func stopAdvertising() {
        guard advertising else { return }
        
        stateMachine <-! ServiceEvent.reset
    }
    
    func startBrowsing() {
        guard advertising || stateMachine.state == .notReady else { return }
        
        if(advertising) {
            stopAdvertising()
        }
        
        stateMachine <-! ServiceEvent.browseProceed
    }
    
    func stopBrowsing() {
        guard browsing else { return }
        
        stateMachine <-! ServiceEvent.reset
    }
    
    func sendData(_ data:Data) {
        if(sessionState != .connected) {
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
    
    private func _handleStartAdvertising() {
        MatchTransfer.session.delegate = self
        advertiser.startAdvertisingPeer()
        print("Started Advertiser")
    }
    
    private func _handleStopAdvertising() {
        MatchTransfer.session.disconnect()
        advertiser.stopAdvertisingPeer()
        MatchTransfer.session.delegate = nil
        print("Stopped Advertiser")
    }
    
    private func _handleStartBrowser() {
        MatchTransfer.session.delegate = self
        browser.startBrowsingForPeers()
        print("Started Browsing")
    }
    
    private func _handleStopBrowser() {
        MatchTransfer.session.disconnect()
        browser.stopBrowsingForPeers()
        MatchTransfer.session.delegate = nil
        print("Stopped Browser")
    }
    
    private func _setupStateMachineHandlers() {
        // Add Advert Proceed Event Handlers
        stateMachine.addHandler(event: .advertProceed) {[unowned self, weak delegate = self.delegate] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advert Proceed Events
            case (.advertReady,             .advertRunning) :
                print("Start Advertiser")
                self._handleStartAdvertising()
                fallthrough
            case (.notReady,                .advertSelectingData)     : fallthrough
            case (.advertSelectingData,     .advertReady)             : fallthrough
            case (.advertRunning,           .advertInvitationPending) : fallthrough
            case (.advertInvitationPending, .advertConnecting)        : fallthrough
            case (.advertConnecting,        .advertSendingData)       : fallthrough
            case (.advertSendingData,       .notReady) :
                delegate?.serviceStore(self, transitionedFromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.advertProceed): \(fromState) => \(toState)")
        }
        
        // Add Advert Go Back Event Handlers
        stateMachine.addHandler(event: .advertGoBack) {[unowned self, weak delegate = self.delegate] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advert Go Back Events
            case (.advertRunning,       .advertReady)         :
                print("Stop Advertiser")
                self._handleStopAdvertising()
                fallthrough
            case (.advertSelectingData, .notReady)            : fallthrough
            case (.advertReady,         .advertSelectingData) : fallthrough
            case (.advertInvitationPending, .advertRunning)   : fallthrough
            case (.advertConnecting, .advertRunning) : fallthrough
            case (.advertSendingData, .advertRunning) :
                delegate?.serviceStore(self, transitionedFromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
            default :
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.advertGoBack): \(fromState) => \(toState)")
        }
        
        // Add Advert Error Out Event Handlers
        stateMachine.addHandler(event: .advertErrorOut) {[unowned self, weak delegate = self.delegate] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advert Error Out Events
            case (.advertRunning, .notReady) : fallthrough
            case (.advertConnecting, .notReady) : fallthrough
            case (.advertSendingData, .notReady) :
                self._handleStopAdvertising()
                delegate?.serviceStore(self, transitionedFromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.advertErrorOut): \(fromState) => \(toState)")
        }
        
        // Add Browse Proceed Event Handlers
        stateMachine.addHandler(event: .browseProceed) {[unowned self, weak delegate = self.delegate] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Browse Proceed Events
            case (.notReady, .browseRunning) :
                print("Start Browser")
                self._handleStartBrowser()
                fallthrough
            case (.browseRunning, .browseConnecting) : fallthrough
            case (.browseConnecting, .browseReceivingData) : fallthrough
            case (.browseReceivingData, .notReady) :
                delegate?.serviceStore(self, transitionedFromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseProceed): \(fromState) => \(toState)")
        }
        
        // Add Browse Go Back Event Handlers
        stateMachine.addHandler(event: .browseGoBack) {[unowned self, weak delegate = self.delegate] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Browse Go Back Events
            case (.browseRunning, .notReady) :
                print("Stop Browser")
                self._handleStopBrowser()
                fallthrough
            case (.browseConnecting, .browseRunning) : fallthrough
            case (.browseReceivingData, .browseRunning) :
                delegate?.serviceStore(self, transitionedFromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseGoBack): \(fromState) => \(toState)")
        }
        
        // Add Browse Error Out Event Handlers
        stateMachine.addHandler(event: .browseErrorOut) {[unowned self, weak delegate = self.delegate] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Browse Error Out Events
            case (.browseRunning, .notReady) : fallthrough
            case (.browseConnecting, .notReady) : fallthrough
            case (.browseReceivingData, .notReady) :
                print("Stop Browser")
                self._handleStopBrowser()
                delegate?.serviceStore(self, transitionedFromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseErrorOut): \(fromState) => \(toState)")
        }
        
        // Add Reset Event Handlers
        stateMachine.addHandler(event: .browseErrorOut) {[unowned self, weak delegate = self.delegate] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advertise Reset Transitions
            case (.advertRunning, .notReady) : fallthrough
            case (.advertInvitationPending, .notReady) : fallthrough
            case (.advertConnecting, .notReady) : fallthrough
            case (.advertSendingData, .notReady) :
                print("Stop Advertiser")
                self._handleStopAdvertising()
                fallthrough
            case (.advertSelectingData, .notReady) : fallthrough
            case (.advertReady, .notReady) :
                delegate?.serviceStore(self, transitionedFromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                print("Advertise State Reset")
                break
                
            // Browse Reset Transitions
            case (.browseRunning, .notReady) : fallthrough
            case (.browseConnecting, .notReady) : fallthrough
            case (.browseReceivingData, .notReady) :
                print("Stop Browser")
                self._handleStopBrowser()
                delegate?.serviceStore(self, transitionedFromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                print("Browse State Reset")
                break
                
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseErrorOut): \(fromState) => \(toState)")
        }
    }
}
