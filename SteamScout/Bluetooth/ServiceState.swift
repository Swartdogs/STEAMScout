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
    case browseRunning
    case browseConnecting
    case browseReceivingData
}

enum ServiceEvent: EventType {
    case reset
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
        // MARK: Add Advertisement Transitions
        
        /// Not Ready => Selecting Data
        /// Triggered by: Proceed
        /// Handlers:     Proceed - Allow Delegate to handle selecting data and notify machine when data has been selected
        machine.addRoute(.notReady => .advertSelectingData)
        
        /// Selecting Data => Ready
        /// Triggered by: Proceed
        /// Handlers:     Proceed - Update machine state
        machine.addRoute(.advertSelectingData => .advertReady)
        
        /// Selecting Data => Not Ready
        /// Triggered by: GoBack, Reset
        /// Handlers:     GoBack - Allow Delegate to update UI
        ///               Reset  - Allow Delegate to update UI
        machine.addRoute(.advertSelectingData => .notReady)
        
        /// Ready => Running
        /// Triggered by: Proceed
        /// Handlers:     Proceed - Start Advertiser
        machine.addRoute(.advertReady => .advertRunning)
        
        /// Ready => Selecting Data
        /// Triggered by: GoBack
        /// Handlers:     GoBack - Allow Delegate to select new data (delegate will notify machine when data has been selected)
        machine.addRoute(.advertReady => .advertSelectingData)
        
        /// Ready => Not Ready
        /// Triggered by: Reset
        /// Handlers:     Reset - Allow Delegate to update UI, update state
        machine.addRoute(.advertReady => .notReady)
        
        /// Running => Invitation Pending
        /// Triggered by: Proceed
        /// Handlers:     Proceed - Allow Delegate to update UI
        machine.addRoute(.advertRunning => .advertInvitationPending)
        
        /// Running => Ready
        /// Triggered by: GoBack
        /// Handlers:     GoBack - Allow Delegate to update UI, stop advertiser
        machine.addRoute(.advertRunning => .advertReady)
        
        /// Running => Not Ready
        /// Triggered by: ErrorOut, Reset
        /// Handlers:     ErrorOut - Allow Delegate to update UI, stop advertiser
        ///               Reset    - Allow Delegate to update UI, stop advertiser
        machine.addRoute(.advertRunning => .notReady)
        
        /// Invitation Pending => Connecting
        /// Triggered by: Proceed
        /// Handlers:     Proceed - Allow Delegate to update UI
        machine.addRoute(.advertInvitationPending => .advertConnecting)
        
        /// Invitation Pending => Running
        /// Triggered by: GoBack
        /// Handlers:     GoBack - Allow Delegate to update UI, reset state back to running
        machine.addRoute(.advertInvitationPending => .advertRunning)
        
        /// Invitation Pending => Not Ready
        /// Triggered by: Reset
        /// Handlers:     Reset - Allow Delegate to update UI, stop advertiser
        machine.addRoute(.advertInvitationPending => .notReady)
        
        /// Connecting => Sending Data
        /// Triggered by: Proceed
        /// Handlers:     Proceed - Allow Delegate to update UI
        machine.addRoute(.advertConnecting => .advertSendingData)
        
        /// Connecting => Running
        /// Triggered by: GoBack 
        /// Handlers:     GoBack - Allow Delegate to update UI, reset state back to running
        machine.addRoute(.advertConnecting => .advertRunning)
        
        /// Connecting => Not Ready
        /// Triggered by: ErrorOut, Reset
        /// Handlers:     ErrorOut - Allow Delegate to update UI, stop advertiser
        ///               Reset    - Allow Delegate to update UI, stop advertiser
        machine.addRoute(.advertConnecting => .notReady)
        
        /// Sending Data => Not Ready
        /// Triggered by: Proceed, ErrorOut, Reset
        /// Handlers:     Proceed  - Allow Delegate to update UI, stop advertiser
        ///               ErrorOut - Allow Delegate to update UI, stop advertiser
        ///               Reset    - Allow Delegate to update UI, stop advertiser
        machine.addRoute(.advertSendingData => .notReady)
        
        /// Sending Data => Running
        /// Triggered by: GoBack
        /// Handlers:     GoBack - Reset state back to running
        machine.addRoute(.advertSendingData => .advertRunning)
        
        // MARK: Add Browse Transitions
        
        /// Not Ready => Running
        /// Triggered by: Proceed
        /// Handlers:     Proceed - Allow Delegate to update UI, start browser
        machine.addRoute(.notReady => .browseRunning)
        
        /// Running => Connecting
        /// Triggered by: Proceed
        /// Handlers:     Proceed - Allow Delegate to update UI
        machine.addRoute(.browseRunning => .browseConnecting)
        
        /// Running => Not Ready
        /// Triggered by: GoBack, ErrorOut, Reset
        /// Handlers:     GoBack   - Allow Delegate to update UI, stop browser
        ///               ErrorOut - Allow Delegate to update UI, stop browser
        ///               Reset    - Allow Delegate to update UI, stop browser
        machine.addRoute(.browseRunning => .notReady)
        
        /// Connecting => Receiving Data
        /// Triggered by: Proceed
        /// Handlers:     Proceed - Allow Delegate to update UI
        machine.addRoute(.browseConnecting => .browseReceivingData)
        
        /// Connecting => Running
        /// Triggered by: GoBack
        /// Handlers:     GoBack - Allow Delegate to update UI
        machine.addRoute(.browseConnecting => .browseRunning)
        
        /// Connecting => Not Ready
        /// Triggered by: ErrorOut, Reset
        /// Handlers:     ErrorOut - Allow Delegate to update UI, stop browser
        ///               Reset    - Allow Delegate to update UI, stop browser
        machine.addRoute(.browseConnecting => .notReady)
        
        /// Receiving Data => Not Ready
        /// Triggered by: Proceed, ErrorOut, Reset
        /// Handlers:     Proceed  - Allow Delegate to update UI, stop browser
        ///               ErrorOut - Allow Delegate to update UI, stop browser
        ///               Reset    - Allow Delegate to update UI, stop browser
        machine.addRoute(.browseReceivingData => .notReady)
        
        /// Receiving Data => Running
        /// Triggered by: GoBack
        /// Handlers:     GoBack - Allow Delegate to update UI, reset state back to running
        machine.addRoute(.browseReceivingData => .browseRunning)
        
        // Add Default Error Handler
        machine.addErrorHandler { event, fromState, toState, userInfo in
            print("[ERROR] ServiceStateMachine: \(fromState) => \(toState), \(String(describing: event)) with user info \(String(describing: userInfo))")
        }
        
        machine.addRouteMapping { event, fromState, userInfo -> ServiceState? in
            guard let event = event else { return nil }
            
            switch(event, fromState) {
            // Advert Proceed Events
            case (.advertProceed, .notReady)                : return .advertSelectingData
            case (.advertProceed, .advertSelectingData)     : return .advertReady
            case (.advertProceed, .advertReady)             : return .advertRunning
            case (.advertProceed, .advertRunning)           : return .advertInvitationPending
            case (.advertProceed, .advertInvitationPending) : return .advertConnecting
            case (.advertProceed, .advertConnecting)        : return .advertSendingData
            case (.advertProceed, .advertSendingData)       : return .notReady
                
            // Advert GoBack Events
            case (.advertGoBack, .advertSelectingData)      : return .notReady
            case (.advertGoBack, .advertReady)              : return .advertSelectingData
            case (.advertGoBack, .advertRunning)            : return .advertReady
            case (.advertGoBack, .advertInvitationPending)  : return .advertRunning
            case (.advertGoBack, .advertConnecting)         : return .advertRunning
            case (.advertGoBack, .advertSendingData)        : return .advertRunning
                
            // Advert ErrorOut Events
            case (.advertErrorOut, .advertRunning)          : return .notReady
            case (.advertErrorOut, .advertConnecting)       : return .notReady
            case (.advertErrorOut, .advertSendingData)      : return .notReady
                
            // Browse Proceed Events
            case (.browseProceed, .notReady)                : return .browseRunning
            case (.browseProceed, .browseRunning)           : return .browseConnecting
            case (.browseProceed, .browseConnecting)        : return .browseReceivingData
            case (.browseProceed, .browseReceivingData)     : return .notReady
                
            // Browse GoBack Events
            case (.browseGoBack, .browseRunning)            : return .notReady
            case (.browseGoBack, .browseConnecting)         : return .browseRunning
            case (.browseGoBack, .browseReceivingData)      : return .browseRunning
                
            // Browse ErrorOut Events
            case (.browseErrorOut, .browseRunning)          : return .notReady
            case (.browseErrorOut, .browseConnecting)       : return .notReady
            case (.browseErrorOut, .browseReceivingData)    : return .notReady
                
            // Reset Events
            case (.reset, .advertSelectingData)             : return .notReady
            case (.reset, .advertReady)                     : return .notReady
            case (.reset, .advertRunning)                   : return .notReady
            case (.reset, .advertInvitationPending)         : return .notReady
            case (.reset, .advertConnecting)                : return .notReady
            case (.reset, .advertSendingData)               : return .notReady
            case (.reset, .browseRunning)                   : return .notReady
            case (.reset, .browseConnecting)                : return .notReady
            case (.reset, .browseReceivingData)             : return .notReady
                
            default:
                return nil
            }
        }
    })
}
