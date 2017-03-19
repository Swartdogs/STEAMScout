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
    
    let browser = MCNearbyServiceBrowser(peer: MatchTransfer.localPeerID, serviceType: MatchTransfer.serviceType)
    let advertiser = MCNearbyServiceAdvertiser(peer: MatchTransfer.localPeerID, discoveryInfo: nil, serviceType: MatchTransfer.serviceType)
    
    var blockedPeers = [MCPeerID]()
    
    @IBOutlet var showBrowserButton: UIButton!
    @IBOutlet var advertisingSwitch: UISwitch!
    @IBOutlet var browsingSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        browser.delegate = self
        advertiser.delegate = self
        MatchTransfer.session.delegate = self
        showBrowserButton.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func advertisingSwitchChanged(_ sender: UISwitch) {
        if(sender.isOn) {
            MatchTransfer.session.disconnect()
            browser.stopBrowsingForPeers()
            browsingSwitch.isOn = false
            browsingSwitch.isEnabled = false
            print("Stop Browsing")
            advertiser.startAdvertisingPeer()
            print("Start Advertising")
        } else {
            MatchTransfer.session.disconnect()
            advertiser.stopAdvertisingPeer()
            browsingSwitch.isEnabled = true
            print("Stop Advertising")
        }
    }
    
    @IBAction func broadcastingSwitchChanged(_ sender: UISwitch) {
        if(sender.isOn) {
            MatchTransfer.session.disconnect()
            advertiser.stopAdvertisingPeer()
            advertisingSwitch.isOn = false
            advertisingSwitch.isEnabled = false
            print("Stop Advertising")
            browser.startBrowsingForPeers()
            showBrowserButton.isEnabled = true
            print("Start Browsing")
        } else {
            MatchTransfer.session.disconnect()
            browser.stopBrowsingForPeers()
            showBrowserButton.isEnabled = false
            advertisingSwitch.isEnabled = true
            print("Stop Browsing")
        }
    }
    
    @IBAction func showBrowserView(_ sender: UIButton) {
        let browserViewController = MCBrowserViewController(browser: browser, session: MatchTransfer.session)
        browserViewController.delegate = self
        browser.delegate = browserViewController
        self.present(browserViewController, animated: true, completion: nil)
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

extension DataTransferViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if self.blockedPeers.contains(peerID) {
            invitationHandler(false, nil)
            return
        }
        
        let alertController = UIAlertController(title: "Received Invitation from \(peerID.displayName)", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            invitationHandler(false, nil)
        })
        let blockAction = UIAlertAction(title: "Block", style: .destructive, handler: { [weak self] _ in
            self?.blockedPeers.append(peerID)
            invitationHandler(false, nil)
        })
        let acceptAction = UIAlertAction(title: "Accept", style: .default, handler: { _ in
            invitationHandler(true, MatchTransfer.session)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(blockAction)
        alertController.addAction(acceptAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("advertiser did not start advertising: \(error.localizedDescription)")
    }
}

extension DataTransferViewController: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        // Deal with error
        print("Browser did not start browsing: \(error.localizedDescription)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Found Peer!
        print("Browser found peer: \(peerID.displayName)")
        browser.invitePeer(peerID, to: MatchTransfer.session, withContext: nil, timeout: 10.0)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // Lost peer
        print("Browser lost peer: \(peerID.displayName)")
    }
}

extension DataTransferViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: { [weak self] in
            self?.browser.delegate = self
        })
        print("Browser View Controller finished")
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        // Update UI!
        browserViewController.dismiss(animated: true, completion: { [weak self] in
            self?.browser.delegate = self
        })
        print("Browser View Controller canceled")
    }
    
    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        // By default show all peers
        print("Peer presented: \(peerID.displayName)")
        return true
    }
}

extension DataTransferViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Deal with state change
        print("Peer: \(peerID.displayName) changed state to: \(state.rawValue)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("(Peer: \(peerID.displayName) received data: \(data)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Received stream: \(streamName) from peer: \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Started receiving resource with name: \(resourceName) from peer: \(peerID.displayName) with progress: \(progress.fractionCompleted)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("Finished receiving resource with name: \(resourceName) from peer: \(peerID.displayName) at url: \(localURL.absoluteURL) with error: \(error.debugDescription)")
    }
}
