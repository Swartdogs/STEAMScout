//
//  DataTransferViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/18/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import SwiftState

class DataTransferViewController: UIViewController {
    
    @IBOutlet var showBrowserButton: UIButton!
    @IBOutlet var pingButton: UIButton!
    @IBOutlet var advertisingSwitch: UISwitch!
    @IBOutlet var browsingSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ServiceStore.shared.delegate = self

        showBrowserButton.isEnabled = false
        pingButton.isEnabled = false
        ServiceStore.shared.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func advertisingSwitchChanged(_ sender: UISwitch) {
        if(sender.isOn) {
            ServiceStore.shared.startAdvertising()
            browsingSwitch.isOn = false
            browsingSwitch.isEnabled = false
        } else {
            ServiceStore.shared.stopAdvertising()
            browsingSwitch.isEnabled = true
        }
    }
    
    @IBAction func broadcastingSwitchChanged(_ sender: UISwitch) {
        if(sender.isOn) {
            ServiceStore.shared.startBrowsing()
            advertisingSwitch.isOn = false
            advertisingSwitch.isEnabled = false
            showBrowserButton.isEnabled = true
        } else {
            ServiceStore.shared.stopBrowsing()
            showBrowserButton.isEnabled = false
            advertisingSwitch.isEnabled = true
        }
    }
    
    @IBAction func showBrowserView(_ sender: UIButton) {
        print("ERROR: Need to implement this!")
    }
    
    @IBAction func pingConnectedDevices(_ sender: UIButton) {
        let message = "ping"
        ServiceStore.shared.sendMessage(message)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DataTransferViewController: ServiceStoreDelegate {
    func serviceStore(_ serviceStore: ServiceStore, withSession session: MCSession, didChangeState state: MCSessionState) {
        let enable = state == .connected
        DispatchQueue.main.async { [weak self, enable] in
            self?.pingButton.isEnabled = enable
        }
    }
    
    func serviceStore(_ serviceStore: ServiceStore, withSession session: MCSession, didReceiveData data: Data, fromPeer peerId: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            print("Message decoded: \(message)")
            if message == "ping" {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "Ping!", message: "\(peerId.displayName) pinged you!", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(ok)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func serviceStore(_ serviceStore: ServiceStore, transitionedFromState fromState: ServiceState, toState: ServiceState, forEvent event: ServiceEvent, withUserInfo userInfo: Any?) {
        // TODO: Implement Further
        
        switch(event, fromState, toState) {
        // State Updates (no further action required)
        case (.advertProceed, .advertReady, .advertRunning) :
            print("Advertiser Started")
            break
        case (.advertGoBack, .advertRunning, .advertReady) :
            print("Advertiser Stopped")
            break
        case (.browseProceed, .notReady, .browseRunning) :
            print("Browser Started")
            break
        case (.browseGoBack, .browseRunning, .notReady) :
            print("Browser Stopped")
            break
        case (.reset, .advertSelectingData, .notReady)      : fallthrough
        case (.reset, .advertReady, .notReady)              : fallthrough
        case (.reset, .advertRunning, .notReady)            : fallthrough
        case (.reset, .advertInvitationPending, .notReady)  : fallthrough
        case (.reset, .advertConnecting, .notReady)         : fallthrough
        case (.reset, .advertSendingData, .notReady)        : fallthrough
        case (.reset, .browseRunning, .notReady)            : fallthrough
        case (.reset, .browseConnecting, .notReady)         : fallthrough
        case (.reset, .browseReceivingData, .notReady)      :
            print("Reset Event Ocurred")
            break
            
        // UI Updates (need to update UI on main thread)
        case (.advertProceed, .notReady, .advertSelectingData) : fallthrough
        case (.advertGoBack, .advertReady, .advertSelectingData) :
            print("Show Data Selection Screen UI")
            break
        case (.advertProceed, .advertSelectingData, .advertReady) : fallthrough
        case (.advertGoBack,  .advertSelectingData, .notReady) :
            print("Hide Data Selection Screen UI")
            break
        case (.advertProceed, .advertRunning, .advertInvitationPending) :
            print("Show Invitation Pending UI")
            break
        case (.advertProceed, .advertInvitationPending, .advertConnecting) : fallthrough
        case (.browseProceed, .browseRunning, .browseConnecting) :
            print("Show Connecting UI")
            break
        case (.advertProceed, .advertConnecting, .advertSendingData) :
            print("Show Sending Data UI")
            break
        case (.browseProceed, .browseConnecting, .browseReceivingData) :
            print("Show Receiving Data UI")
            break
        case (.advertProceed, .advertSendingData, .notReady) : fallthrough
        case (.browseProceed, .browseReceivingData, .notReady) :
            print("Show Complete UI and hide after 2 sec delay")
            break
        case (.advertGoBack, .advertInvitationPending, .advertRunning) : fallthrough
        case (.advertGoBack, .advertConnecting, .advertRunning) : fallthrough
        case (.advertGoBack, .advertSendingData, .advertRunning) : fallthrough
        case (.browseGoBack, .browseConnecting, .browseRunning) : fallthrough
        case (.browseGoBack, .browseReceivingData, .browseRunning) :
            // UI Might not be necesssary
            print("Show Dismissal UI with userInfo: \(String(describing: userInfo))")
            break
        case (.advertErrorOut, .advertRunning, .notReady) : fallthrough
        case (.advertErrorOut, .advertConnecting, .notReady) : fallthrough
        case (.advertErrorOut, .advertSendingData, .notReady) : fallthrough
        case (.browseErrorOut, .browseRunning, .notReady) : fallthrough
        case (.browseErrorOut, .browseConnecting, .notReady) : fallthrough
        case (.browseErrorOut, .browseReceivingData, .notReady) :
            print("Show \(String(describing: fromState)) Error UI with user info: \(String(describing: userInfo))")
            break
        
        default:
            print("WARN: Unknown transition \(String(describing: fromState)) => \(String(describing: toState)) for \(String(describing: event))!")
            break
        }
    }
}
