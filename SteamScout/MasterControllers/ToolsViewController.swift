//
//  ToolsViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/7/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import CoreBluetooth
import MBProgressHUD
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ToolsViewController: UIViewController {
    
    @IBOutlet weak var fieldLayout:UIImageView!
    @IBOutlet weak var getScheduleButton:UIButton!
    @IBOutlet weak var buildListButton:UIButton!
    
    @IBOutlet var listSelectorButtons:[UIButton]!
    
    /**
     * represents the list the user wants to build
     * the first 2 bits correspond to the number of the list
     * bit 3 corresponds to the color (0 == red, 1 == blue)
     * ex: 5 = Blue 1 ~> (5 & 4) == 1, (5 & 3) == 1
     * ex: 3 = Red  3 ~> (5 & 4) == 0, (5 & 3) == 3
     */
    fileprivate var selectedList = 0
    
    fileprivate var peripheralManager:CBPeripheralManager?
    fileprivate var infoCharacteristic:CBMutableCharacteristic?
    fileprivate var newDataCharacteristic:CBMutableCharacteristic?
    fileprivate var allDataCharacteristic:CBMutableCharacteristic?
    
    fileprivate var dataToSend:Data?
    fileprivate var sendDataIndex:Int = 0
    fileprivate var sendingEOM = false
    fileprivate var sendingCharacteristic:CBMutableCharacteristic!
    
    @IBOutlet var adSwitch:UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        fieldLayout.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(fieldLayoutTap(_:)))
        fieldLayout.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fieldLayout.image = MatchStore.sharedStore.fieldLayout.getImage()
        self.view.backgroundColor = themeOrange
        
        adSwitch.isOn = false
        
        getScheduleButton.isEnabled = EventStore.sharedStore.selectedEvent != nil
        buildListButton.isEnabled = false
        selectedList = 0
        for b in listSelectorButtons {
            b.isSelected = false
            b.isEnabled = ScheduleStore.sharedStore.currentSchedule != nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        adSwitch.isOn = false
        peripheralManager?.stopAdvertising()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fieldLayoutTap(_ sender:UITapGestureRecognizer) {
        MatchStore.sharedStore.fieldLayout.reverse()
        UserDefaults.standard.set(MatchStore.sharedStore.fieldLayout.rawValue, forKey: "SteamScout.fieldLayout")
        let image = MatchStore.sharedStore.fieldLayout.getImage()
        UIView.transition(with: fieldLayout, duration: 0.2, options: .transitionCrossDissolve, animations: {[weak self] in
            self?.fieldLayout.image = image
        }, completion: nil)
    }
    
    @IBAction func startAdvertising(_ sender:UISwitch) {
        if(peripheralManager?.state != .poweredOn && adSwitch.isOn) {
            adSwitch.isOn = false
            let alertController = UIAlertController(title: "Bluetooth Advertising", message: "Before you can advertise data via bluetooth, you must enable it.  Go to the settings and turn Bluetooth on to start sending data", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        if(adSwitch.isOn) {
            print("Advertising")
            peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [lastUpdateServiceUUID, dataServiceUUID]])
        } else {
            peripheralManager?.stopAdvertising()
        }
    }
    
    @IBAction func getEventList(_ sender:UIButton) {
        let hud = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        hud.label.text = "Loading..."
        hud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelRequest(_:))))
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        EventStore.sharedStore.getEventsList({(progress) in
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                hud?.mode = .determinate
                hud?.progress = Float(progress)
            })
        }, completion: {(error) in
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                let image = UIImage(named: error == nil ? "Checkmark" : "Close")
                let imageView = UIImageView(image: image)
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                hud?.customView = imageView
                hud?.mode = .customView
                hud?.label.text = error == nil ? "Completed" : "Error"
                hud?.hide(animated: true, afterDelay: 1)
            })
        })
    }
    
    func cancelRequest(_ sender:UITapGestureRecognizer) {
        EventStore.sharedStore.cancelRequest({
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                let imageView = UIImageView(image: UIImage(named: "Close"))
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                hud?.customView = imageView
                hud?.mode = .customView
                hud?.label.text = "Canceled"
                hud?.hide(animated: true, afterDelay: 1)
            })
        })
    }
    
    func sendData() {
        if sendingEOM {
            let didSend = peripheralManager?.updateValue("<EOM>".data(using: String.Encoding.utf8)!, for: sendingCharacteristic!, onSubscribedCentrals: nil)
            if didSend == true {
                sendingEOM = false
                print("Sent: EOM")
            }
            return
        }
        
        if sendDataIndex >= dataToSend?.count {
            return
        }
        
        var didSend = true
        while didSend {
            var amountToSend = dataToSend!.count - sendDataIndex
            if amountToSend > NOTIFY_MTU {
                amountToSend = NOTIFY_MTU
            }
            let chunk = Data(bytes: UnsafeRawPointer((dataToSend! as NSData).bytes + sendDataIndex), count: amountToSend)
            
            didSend = (peripheralManager?.updateValue(chunk, for: sendingCharacteristic, onSubscribedCentrals: nil))!
            
            if !didSend { return }
            
            sendDataIndex += amountToSend
            
            if sendDataIndex >= dataToSend?.count {
                sendingEOM = true
                let eomSent = peripheralManager!.updateValue("<EOM>".data(using: String.Encoding.utf8)!, for: sendingCharacteristic, onSubscribedCentrals: nil)
                
                if eomSent {
                    sendingEOM = false
                    print("Send complete")
                }
                
                return
            }
            
        }
    }
    
    @IBAction func selectList(_ sender:UIButton) {
        selectedList = sender.isSelected ? 0 : sender.tag
        for b in listSelectorButtons {
            b.isSelected = b.tag == selectedList
        }
        buildListButton.isEnabled = selectedList > 0
    }
    
    @IBAction func getSchedule(_ sender:UIButton) {
        ScheduleStore.sharedStore.currentSchedule = EventStore.sharedStore.selectedEvent?.code
        let hud = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading..."
        hud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ToolsViewController.cancelScheduleRequest(_:))))
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.getScheduleButton.isEnabled = false
        self.buildListButton.isEnabled = false
        ScheduleStore.sharedStore.getScheduleList({ (progress:Double) in
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                hud?.mode = .determinate
                hud?.progress = Float(progress)
            })
            }, completion: { (error) in
                DispatchQueue.main.async(execute: {
                    let hud = MBProgressHUD(for: self.navigationController!.view)
                    let imageView = UIImageView(image: UIImage(named: error == nil ? "Checkmark" : "Close"))
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
                    self.getScheduleButton.isEnabled = true
                    for b in self.listSelectorButtons {
                        b.isEnabled = ScheduleStore.sharedStore.currentSchedule != nil
                    }
                    self.buildListButton.isEnabled = self.selectedList > 0
                    hud?.customView = imageView
                    hud?.mode = .customView
                    hud?.label.text = error == nil ? "Completed" : "Error"
                    hud?.hide(animated: true, afterDelay: 1)
                })
        })
    }
    
    @IBAction func buildList(_ sender:UIButton) {
        if ScheduleStore.sharedStore.currentSchedule != EventStore.sharedStore.selectedEvent?.code {
            let scheduleAC = UIAlertController(title: "Current Schedule is different from Selected Event", message: "You have a schedule from a different event! Would you like to continue with the build, or get the new schedule", preferredStyle: .alert)
            let buildAction = UIAlertAction(title: "Continue With Build", style: .default, handler: { (action) in
                self.confirmBuildList()
            })
            scheduleAC.addAction(buildAction)
            
            let getScheduleAction = UIAlertAction(title: "Get New Schedule", style: .default, handler: { (action) in
                self.getSchedule(self.getScheduleButton)
            })
            scheduleAC.addAction(getScheduleAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            scheduleAC.addAction(cancelAction)
            
            self.present(scheduleAC, animated: true, completion: nil)
        } else {
            confirmBuildList()
        }
    }
    
    func confirmBuildList() {
        var list = (selectedList & 4) == 1 ? "Blue" : "Red"
        list += " \(selectedList & 3)"
        let ac = UIAlertController(title: "Build \(list) List for event \(ScheduleStore.sharedStore.currentSchedule!)", message: "Building this list will clear the previous queue of matches.  Do you want to continue?", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .destructive, handler: {(action) in
            let hud = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            hud.mode = .indeterminate
            hud.label.text = "Building List"
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
                ScheduleStore.sharedStore.buildMatchListForGroup(self.selectedList)
                DispatchQueue.main.async(execute: {
                    let hud = MBProgressHUD(for: self.navigationController!.view)
                    let imageView = UIImageView(image: UIImage(named: "Checkmark"))
                    hud?.customView = imageView
                    hud?.mode = .customView
                    hud?.label.text = "Completed"
                    hud?.hide(animated: true, afterDelay: 1)
                })
            })
        })
        ac.addAction(continueAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func cancelScheduleRequest(_ sender:UITapGestureRecognizer) {
        ScheduleStore.sharedStore.cancelRequest({
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                let imageView = UIImageView(image: UIImage(named: "Close"))
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.getScheduleButton.isEnabled = true
                for b in self.listSelectorButtons {
                    b.isEnabled = ScheduleStore.sharedStore.currentSchedule != nil
                }
                self.buildListButton.isEnabled = self.selectedList > 0
                hud?.customView = imageView
                hud?.mode = .customView
                hud?.label.text = "Canceled"
                hud?.hide(animated: true, afterDelay: 1)
            })
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ToolsViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if(peripheral.state != .poweredOn) {
            print("Peripheral manager updated state: \(peripheral.state.rawValue), \(CBPeripheralManagerState.poweredOn.rawValue)")
            return
        }
        
        print("Peripheral Manager Powered On")
        
        infoCharacteristic = CBMutableCharacteristic(type: lastUpdateCharacteristicUUID,
                                               properties: .read,
                                                    value: nil,
                                              permissions: .readable)
        newDataCharacteristic = CBMutableCharacteristic(type: newMatchDataCharacteristicUUID,
                                                  properties: .notify,
                                                       value: nil,
                                                 permissions: .readable)
        allDataCharacteristic = CBMutableCharacteristic(type: allMatchDataCharacteristicUUID,
                                                  properties: .notify,
                                                       value: nil,
                                                 permissions: .readable)
        
        let infoService = CBMutableService(type: lastUpdateServiceUUID, primary: false)
        infoService.characteristics = [infoCharacteristic!]
        
        let dataService = CBMutableService(type: dataServiceUUID, primary: true)
        dataService.characteristics = [allDataCharacteristic!]
        
        peripheralManager!.add(infoService)
        peripheralManager!.add(dataService)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central: \(central.identifier) has subscibed to characteristic: \(characteristic.uuid)")
        
        sendDataIndex = 0
        dataToSend = MatchStore.sharedStore.dataTransferMatchesAll(characteristic.uuid == allDataCharacteristic?.uuid) ?? "An Error Occured".data(using: String.Encoding.utf8)
        sendingCharacteristic = characteristic.uuid == allDataCharacteristic?.uuid ? allDataCharacteristic! : newDataCharacteristic!
        
        sendData();
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Central: \(central.identifier) has unsubscibed to characteristic: \(characteristic.uuid)")
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        sendData()
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print(error)
        }
    }
}
