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
    
    var delegate:ServiceStoreDelegate? = nil
    var foundPeers:[MCPeerID:[String:String]] = [:]
    var state:MCSessionState = .notConnected
    
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
            ServiceState.advertSendingData,
            ServiceState.advertComplete,
            ServiceState.advertError
        ].contains(stateMachine.state)
    }
    
    var browsing:Bool {
        return [
            ServiceState.browseRunning,
            ServiceState.browseConnecting,
            ServiceState.browseReceivingData,
            ServiceState.browseComplete,
            ServiceState.browseError
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
        
        // TODO: call reset ServiceEvent when it's created
        
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
        
        // TODO: call reset ServiceEvent when it's created
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
        stateMachine.addHandler(event: .advertProceed) {(event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advert Proceed Events
            case (.notReady, .advertSelectingData) :
                print("Show Data Selection Screen UI")
                self.delegate?.handleShowDataSelectionUIWithServiceStore(self)
                break
            case (.advertSelectingData, .advertReady) :
                print("Hide Data Selection Screen UI")
                self.delegate?.handleHideDataSelectionUIWithServiceStore(self)
                break
            case (.advertReady, .advertRunning) :
                print("Start Advertiser")
                self._handleStartAdvertising()
                break
            case (.advertRunning, .advertInvitationPending) :
                print("Show Invitation Pending UI")
                self.delegate?.handleShowInvitationPendingUIWithServiceStore(self)
                break
            case (.advertInvitationPending, .advertConnecting) :
                print("Show Connecting UI")
                self.delegate?.handleShowConnectingWithServiceStore(self)
                break
            case (.advertConnecting, .advertSendingData) :
                print("Show Sending Data UI")
                self.delegate?.handleShowSendingDataUIWithServiceStore(self)
                break
            case (.advertSendingData, .advertComplete) :
                print("Show Complete UI and hide after 2 sec delay")
                self.delegate?.handleShowCompleteUIWithServiceStore(self)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.advertProceed): \(fromState) => \(toState)")
        }
        
        // Add Advert Go Back Event Handlers
        stateMachine.addHandler(event: .advertGoBack) {(event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advert Go Back Events
            case (.advertSelectingData, .notReady) :
                print("Hide Data Selection Screen")
                self.delegate?.handleHideDataSelectionUIWithServiceStore(self)
                break
            case (.advertReady, .advertSelectingData) :
                print("Show Data Selection Screen")
                self.delegate?.handleShowSendingDataUIWithServiceStore(self)
                break
            case (.advertRunning, .advertReady) :
                print("Stop Advertiser")
                self._handleStopAdvertising()
                break
            case (.advertInvitationPending, .advertRunning) :
                // UI Shouldn't be necessary?
                print("Show Dismissal UI for userInfo: \(userInfo.debugDescription)")
                break
            case (.advertConnecting, .advertInvitationPending) :
                print("Show Invitation Pending UI")
                self.delegate?.handleShowInvitationPendingUIWithServiceStore(self)
                break
            case (.advertSendingData, .advertConnecting) :
                print("Show Connecting UI")
                self.delegate?.handleShowConnectingWithServiceStore(self)
                break
            case (.advertComplete, .advertSendingData) :
                print("Show Sending Data UI")
                self.delegate?.handleShowSendingDataUIWithServiceStore(self)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.advertGoBack): \(fromState) => \(toState)")
        }
        
        // Add Advert Error Out Event Handlers
        stateMachine.addHandler(event: .advertErrorOut) {(event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advert Error Out Events
            case (.advertRunning, .advertError) :
                print("Show Run Error UI with user info: \(userInfo.debugDescription)")
                self.delegate?.handleShowErrorUIWithServiceStore(self, fromState: fromState, withUserInfo: userInfo)
                break
            case (.advertConnecting, .advertError) :
                print("Show Connect Error UI with user info: \(userInfo.debugDescription)")
                self.delegate?.handleShowErrorUIWithServiceStore(self, fromState: fromState, withUserInfo: userInfo)
                break
            case (.advertSendingData, .advertError) :
                print("Show Send Error UI with user info: \(userInfo.debugDescription)")
                self.delegate?.handleShowErrorUIWithServiceStore(self, fromState: fromState, withUserInfo: userInfo)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.advertErrorOut): \(fromState) => \(toState)")
        }
        
        // Add Browse Proceed Event Handlers
        stateMachine.addHandler(event: .browseProceed) {(event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Browse Proceed Events
            case (.notReady, .browseRunning) :
                print("Start Browser")
                self._handleStartBrowser()
                break
            case (.browseRunning, .browseConnecting) :
                print("Show Connecting UI")
                self.delegate?.handleShowConnectingWithServiceStore(self)
                break
            case (.browseConnecting, .browseReceivingData) :
                print("Show Receiving Data UI")
                self.delegate?.handleShowReceivingDataUIWithServiceStore(self)
                break
            case (.browseReceivingData, .browseComplete) :
                print("Show Complete UI and hide after 2 sec delay")
                self.delegate?.handleShowCompleteUIWithServiceStore(self)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseProceed): \(fromState) => \(toState)")
        }
        
        // Add Browse Go Back Event Handlers
        stateMachine.addHandler(event: .browseGoBack) {(event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Browse Go Back Events
            case (.browseRunning, .notReady) :
                print("Stop Browser")
                self._handleStopBrowser()
                break
            case (.browseConnecting, .browseRunning) :
                print("Hide Connecting UI")
                // TODO: Need to create a function for this!
                break
            case (.browseReceivingData, .browseConnecting) :
                print("Show Connecting UI")
                self.delegate?.handleShowConnectingWithServiceStore(self)
                break
            case (.browseComplete, .browseReceivingData) :
                print("Show Reveiving Data UI")
                self.delegate?.handleShowReceivingDataUIWithServiceStore(self)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseGoBack): \(fromState) => \(toState)")
        }
        
        // Add Browse Error Out Event Handlers
        stateMachine.addHandler(event: .browseErrorOut) {(event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Browse Error Out Events
            case (.browseRunning, .browseError) :
                print("Show Run Error UI with user info \(userInfo.debugDescription)")
                self.delegate?.handleShowErrorUIWithServiceStore(self, fromState: fromState, withUserInfo: userInfo)
                break
            case (.browseConnecting, .browseError) :
                print("Show Connect Error UI with user info \(userInfo.debugDescription)")
                self.delegate?.handleShowErrorUIWithServiceStore(self, fromState: fromState, withUserInfo: userInfo)
                break
            case (.browseReceivingData, .browseError) :
                print("Show Receive Error UI with user info \(userInfo.debugDescription)")
                self.delegate?.handleShowErrorUIWithServiceStore(self, fromState: fromState, withUserInfo: userInfo)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseErrorOut): \(fromState) => \(toState)")
        }
    }
}
