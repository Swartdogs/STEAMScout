//
//  EventSelectionViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import MBProgressHUD

class EventSelectionViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
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
    var selectedList = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getScheduleButton.isEnabled = EventStore.sharedStore.selectedEvent != nil
        buildListButton.isEnabled = false
        selectedList = 0
        for b in listSelectorButtons {
            b.isSelected = false
            b.isEnabled = ScheduleStore.sharedStore.currentSchedule != nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if EventStore.sharedStore.selectedEvent != nil {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
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
        let hud = MBProgressHUD.showAdded(to: self.navigationController?.view, animated: true)
        hud?.mode = .indeterminate
        hud?.labelText = "Loading..."
        hud?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventSelectionViewController.cancelRequest(_:))))
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.getScheduleButton.isEnabled = false
        self.buildListButton.isEnabled = false
        ScheduleStore.sharedStore.getScheduleList({ (progress:Double) in
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController?.view)
                hud.mode = .determinate
                hud.progress = Float(progress)
            })
        }, completion: { (error) in
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController?.view)
                let imageView = UIImageView(image: UIImage(named: error == nil ? "check" : "close"))
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.getScheduleButton.isEnabled = true
                for b in self.listSelectorButtons {
                    b.isEnabled = ScheduleStore.sharedStore.currentSchedule != nil
                }
                self.buildListButton.isEnabled = self.selectedList > 0
                hud.customView = imageView
                hud.mode = .customView
                hud.labelText = error == nil ? "Completed" : "Error"
                hud.hide(true, afterDelay: 1)
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
            let hud = MBProgressHUD.showAdded(to: self.navigationController?.view, animated: true)
            hud?.mode = .indeterminate
            hud?.labelText = "Building List"
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
                ScheduleStore.sharedStore.buildMatchListForGroup(self.selectedList)
                DispatchQueue.main.async(execute: {
                    let hud = MBProgressHUD(for: self.navigationController?.view)
                    let imageView = UIImageView(image: UIImage(named: "check"))
                    hud?.customView = imageView
                    hud?.mode = .customView
                    hud?.labelText = "Completed"
                    hud?.hide(true, afterDelay: 1)
                })
            })
        })
        ac.addAction(continueAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func cancelRequest(_ sender:UITapGestureRecognizer) {
        ScheduleStore.sharedStore.cancelRequest({
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController?.view)
                let imageView = UIImageView(image: UIImage(named: "close"))
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.getScheduleButton.isEnabled = true
                for b in self.listSelectorButtons {
                    b.isEnabled = ScheduleStore.sharedStore.currentSchedule != nil
                }
                self.buildListButton.isEnabled = self.selectedList > 0
                hud.customView = imageView
                hud.mode = .customView
                hud.labelText = "Canceled"
                hud.hide(true, afterDelay: 1)
            })
        })
    }
}

extension EventSelectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return EventStore.sharedStore.eventsByType.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return EventStore.sharedStore.selectedEvent == nil ? 0 : 1
        }
        return EventStore.sharedStore.eventsByType[section-1].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Selected Event"
        }
        return EventStore.sharedStore.eventHeaderForSection(section-1)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        let event = indexPath.section == 0 ? EventStore.sharedStore.selectedEvent! : EventStore.sharedStore.eventsByType[indexPath.section - 1][indexPath.row]
        cell.title.text = event.name
        cell.venue.text = event.venue
        cell.location.text = "\(event.city), \(event.stateProv), \(event.country)"
        let formatter = DateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy"
        cell.startDate.text = formatter.string(from: event.dateStart! as Date)

        return cell
    }
}

extension EventSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        let event = EventStore.sharedStore.eventsByType[indexPath.section-1][indexPath.row]
        
        getScheduleButton.isEnabled = true
        tableView.beginUpdates()
        if EventStore.sharedStore.selectedEvent != nil { // selected event is there, we need to remove the cell
            tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .right)
        }
        EventStore.sharedStore.selectedEvent = event
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
        tableView.endUpdates()
        
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
    }
}
