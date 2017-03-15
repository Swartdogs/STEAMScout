//
//  ResultsScoringViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/2/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class ResultsScoringViewController: UIViewController {

    @IBOutlet weak var teleHighFuelLabel: UILabel!
    @IBOutlet weak var teleLowFuelLabel: UILabel!
    @IBOutlet weak var teleGearsScoredLabel: UILabel!
    
    @IBOutlet weak var autoHighFuelLabel: UILabel!
    @IBOutlet weak var autoLowFuelLabel: UILabel!
    @IBOutlet weak var autoBlCrossLabel: UILabel!
    @IBOutlet weak var autoHTriggerLabel: UILabel!
    @IBOutlet weak var autoStartPosLabel: UILabel!
    @IBOutlet weak var autoGearPlaceLabel: UILabel!
    
    var match = SteamMatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Score Results"
        
        autoHighFuelLabel.text = "\(floor(match.autoHighFuelScored))"
        autoLowFuelLabel.text = "\(floor(match.autoLowFuelScored))"
        autoBlCrossLabel.text = "\(match.autoBaselineCrossed ? "Yes" : "No")"
        autoHTriggerLabel.text = "\(match.autoHopperTriggered ? "Yes" : "No")"
        autoStartPosLabel.text = match.autoStartPos.toString()
        autoGearPlaceLabel.text = match.autoGearPlacement.toString()
        
        teleHighFuelLabel.text = "\(floor(match.teleHighFuelScored))"
        teleLowFuelLabel.text = "\(floor(match.teleLowFuelScored))"
        teleGearsScoredLabel.text = "\(match.teleGearsScored)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
