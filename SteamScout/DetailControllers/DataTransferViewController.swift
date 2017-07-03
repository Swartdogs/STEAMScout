//
//  DataTransferViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/18/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DataTransferViewController: UIViewController {
    
    @IBOutlet var showBrowserButton: UIButton!
    @IBOutlet var pingButton: UIButton!
    @IBOutlet var advertisingSwitch: UISwitch!
    @IBOutlet var browsingSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

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
            ServiceStore.shared.enableAdvertising()
            browsingSwitch.isOn = false
            browsingSwitch.isEnabled = false
        } else {
            ServiceStore.shared.disableAdvertising()
            browsingSwitch.isEnabled = true
        }
    }
    
    @IBAction func broadcastingSwitchChanged(_ sender: UISwitch) {
        if(sender.isOn) {
            ServiceStore.shared.enableBrowsing()
            advertisingSwitch.isOn = false
            advertisingSwitch.isEnabled = false
            showBrowserButton.isEnabled = true
        } else {
            ServiceStore.shared.disableBrowsing()
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
}
