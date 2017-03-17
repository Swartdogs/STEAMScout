//
//  EventSelectionTableViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 4/13/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

protocol EventSelectionTableViewControllerDelegate: class {
    func eventSelectionTableViewController(_ estvc:EventSelectionTableViewController, requestedDismissAnimated animated: Bool)
}

class EventSelectionTableViewController: UITableViewController {
    
    weak var delegate: EventSelectionTableViewControllerDelegate?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if EventStore.sharedStore.selectedEvent != nil {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    @IBAction func dismissView(_ sender:AnyObject) {
        delegate?.eventSelectionTableViewController(self, requestedDismissAnimated: true)
    }
}

// MARK: UITableViewDataSource
extension EventSelectionTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return EventStore.sharedStore.eventsByType.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return EventStore.sharedStore.selectedEvent == nil ? 0 : 1
        }
        return EventStore.sharedStore.eventsByType[section-1].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Selected Event"
        }
        return EventStore.sharedStore.eventHeaderForSection(section-1)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["R", "DE", "DC", "CS", "CD", "C", "O"];
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index + 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        let event = indexPath.section == 0 ? EventStore.sharedStore.selectedEvent! : EventStore.sharedStore.eventsByType[indexPath.section - 1][indexPath.row]
        cell.selectionStyle = .none
        cell.title.text = event.name
        cell.venue.text = event.venue
        cell.location.text = "\(event.city), \(event.stateProv), \(event.country)"
        let formatter = DateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy"
        cell.startDate.text = formatter.string(from: event.dateStart! as Date)
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension EventSelectionTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        let event = EventStore.sharedStore.eventsByType[indexPath.section-1][indexPath.row]
        
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
