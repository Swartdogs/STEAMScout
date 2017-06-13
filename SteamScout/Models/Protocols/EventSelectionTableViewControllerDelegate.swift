//
//  EventSelectionTableViewControllerDelegate.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/12/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

protocol EventSelectionTableViewControllerDelegate: class {
    func eventSelectionTableViewController(_ estvc:EventSelectionTableViewController, requestedDismissAnimated animated: Bool)
}
