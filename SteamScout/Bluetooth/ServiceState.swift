//
//  ServiceState.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 7/25/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import SwiftState

enum ServiceState: StateType {
    case notReady
    case advertSelectingData
    case advertReady
    case advertRunning
    case advertInvitationPending
    case advertConnecting
    case advertSendingData
    case advertError
    case advertComplete
    case browseRunning
    case browseConnecting
    case browseReceivingData
    case browseError
    case browseComplete
}

enum ServiceEvent: EventType {
    case advertProceed
    case advertGoBack
    case advertErrorOut
    case browseProceed
    case browseGoBack
    case browseErrorOut
}

enum ServiceError: Error {
    case advertRuntime
    case advertConnect
    case advertSend
    case browseRuntime
    case browseConnect
    case browseReceive
}

func createServiceStateMachine() -> StateMachine<ServiceState, ServiceEvent> {
    return StateMachine<ServiceState, ServiceEvent>(state: .notReady, initClosure: { machine in
        // Add Advertisement Transitions
        machine.addRoute(.notReady                => .advertSelectingData)      // Select Data Before Ready State
        machine.addRoute(.notReady                => .advertReady)              // Jump to Ready State (data already selected)
        machine.addRoute(.advertSelectingData     => .advertReady)              // Ready to Advertise (after selecting data)
        machine.addRoute(.advertSelectingData     => .notReady)                 // Cancel Selecting Data
        machine.addRoute(.advertReady             => .notReady)                 // Cancel Advertising
        machine.addRoute(.advertReady             => .advertRunning)            // Start Advertising
        machine.addRoute(.advertRunning           => .advertReady)              // Stop Advertising
        machine.addRoute(.advertRunning           => .advertError)              // Handle Advertise Runtime Error
        machine.addRoute(.advertRunning           => .advertInvitationPending)  // On Receive Invitation
        machine.addRoute(.advertInvitationPending => .advertRunning)            // Deny Invitation
        machine.addRoute(.advertInvitationPending => .advertConnecting)         // Accept Invitation
        machine.addRoute(.advertConnecting        => .advertError)              // on Connect Error
        machine.addRoute(.advertConnecting        => .advertSendingData)        // on Connect Success
        machine.addRoute(.advertSendingData       => .advertError)              // on Send Error
        machine.addRoute(.advertSendingData       => .advertComplete)           // on Send Complete
        machine.addRoute(.advertError             => .advertReady)              // After Error Handled -> keep select data
        machine.addRoute(.advertError             => .notReady)                 // After Error Handled -> choose new data
        machine.addRoute(.advertComplete          => .advertReady)              // After Send Complete
        machine.addRoute(.advertComplete          => .notReady)                 // After Send Complete -> choose new data
        
        // Add Browse Transitions
        machine.addRoute(.notReady            => .browseRunning)        // Start Browsing
        machine.addRoute(.browseRunning       => .notReady)             // Stop Browsing
        machine.addRoute(.browseRunning       => .browseError)          // Handle Browser Runtime Error
        machine.addRoute(.browseRunning       => .browseConnecting)     // Attempt To Connect to Advertiser
        machine.addRoute(.browseConnecting    => .browseRunning)        // on Request Denied
        machine.addRoute(.browseConnecting    => .browseError)          // Handle Browser Connct Error
        machine.addRoute(.browseConnecting    => .browseReceivingData)  // Data Receiving
        machine.addRoute(.browseReceivingData => .browseError)          // Handle Browser Recieve Error
        machine.addRoute(.browseReceivingData => .browseComplete)       // on Receive Complete
        machine.addRoute(.browseError         => .browseRunning)        // After Error Handled -> keep browsing
        machine.addRoute(.browseError         => .notReady)             // After Error Handled -> stop browsing
        machine.addRoute(.browseComplete      => .browseRunning)        // After Recieve Complete -> keep browsing
        machine.addRoute(.browseComplete      => .notReady)             // After Recieve Complete -> stop browsing
        
        machine.addErrorHandler { event, fromState, toState, userInfo in
            print("[ERROR] ServiceStateMachine: \(fromState) => \(toState), \(String(describing: event)) with user info \(String(describing: userInfo))")
        }
        
        machine.addRoutes(event: .advertProceed, transitions: [
            .notReady => .advertSelectingData,
            .advertSelectingData => .advertReady,
            .advertReady => .advertRunning,
            .advertRunning => .advertInvitationPending,
            .advertInvitationPending => .advertConnecting,
            .advertConnecting => .advertSendingData,
            .advertSendingData => .advertComplete,
        ])
        
        machine.addRoutes(event: .advertProceed, transitions: [
            .advertSelectingData => .notReady,
            .advertReady => .advertSelectingData,
            .advertRunning => .advertReady,
            .advertInvitationPending => .advertRunning
            .advertConnecting => .advertInvitationPending,
            .advertSendingData => .advertConnecting,
            .advertComplete => .advertSendingData
        ])
        
        machine.addRoutes(event: .advertErrorOut, transitions: [
            .advertRunning => .advertError,
            .advertConnecting => .advertError,
            .advertSendingData => .advertError
        ])
        
        machine.addRoutes(event: .browseProceed, transitions: [
            .notReady => .browseRunning,
            .browseRunning => .browseConnecting,
            .browseConnecting => .browseReceivingData,
            .browseReceivingData => .browseComplete,
        ])
        
        machine.addRoutes(event: .browseGoBack, transitions: [
            .browseRunning => .notReady,
            .browseConnecting => .browseRunning,
            .browseReceivingData => .browseConnecting,
            .browseComplete => .browseReceivingData,
        ])
        
        machine.addRoutes(event: .browseErrorOut, transistions: [
            .browseRunning => .browseError,
            .browseConnecting => .browseError,
            .browseReceivingData => .browseError
        ])
    })
}
