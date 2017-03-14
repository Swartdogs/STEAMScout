//
//  AutonomousViewController.swift
//  SteamScout
//
//  Created by Dylan Wells on 2/13/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

class AutonomousViewController: UIViewController {
    
    var match = SteamMatch()
    
    @IBOutlet weak var StartingPosition: UISegmentedControl!
    @IBOutlet weak var BaselineCrossed: UISegmentedControl!
    @IBOutlet weak var HopperTriggered: UISegmentedControl!
    @IBOutlet weak var NoAttemptHighGoal: UIButton!
    @IBOutlet weak var NoAttemptLowGoal: UIButton!
    @IBOutlet var GearButtons:[UIButton]!
    @IBOutlet weak var HighGoalSlider: UISlider!
    @IBOutlet weak var LowGoalSlider: UISlider!
    
    @IBAction func NoAttemptHighGoalPressed(_ sender: UIButton) {
        if NoAttemptHighGoal.isSelected {
            NoAttemptHighGoal.isSelected = false
            HighGoalSlider.value = match.autoHighFuelScored
        }
        else {
            NoAttemptHighGoal.isSelected = true
            HighGoalSlider.value = 0.0
        }
    }
    
    @IBAction func LowGoalNoAttemptPressed(_ sender: UIButton) {
        if NoAttemptLowGoal.isSelected {
            NoAttemptLowGoal.isSelected = false
            LowGoalSlider.value = match.autoLowFuelScored
        }
        else {
            NoAttemptLowGoal.isSelected = true
            LowGoalSlider.value = 0.0
        }
    }
    
    @IBAction func HighGoalValueChanged(_ sender: UISlider) {
        NoAttemptHighGoal.isSelected = false
        match.autoHighFuelScored = sender.value
    }
    
    @IBAction func LowGoalValueChanged(_ sender: UISlider) {
        NoAttemptLowGoal.isSelected = false
        match.autoLowFuelScored = sender.value
    }
    
    @IBAction func GearButtonPressed(_ sender: UIButton) {
        let raw = SteamGearPlacementType(rawValue: sender.tag) ?? .notPlaced
        
        // If selected button was already selected, reset it to .notPlaced
        // Otherwise use the value
        if(raw == match.autoGearPlacement) {
            match.autoGearPlacement = .notPlaced
        } else {
            match.autoGearPlacement = raw
        }
        
        // Update all buttons
        for b in GearButtons {
            b.isSelected = (b.tag == match.autoGearPlacement.rawValue)
        }
    }
    
    @IBAction func StartPosChanged(_ sender: UISegmentedControl) {
        match.autoStartPos = SteamStartPositionType(rawValue: sender.selectedSegmentIndex + 1)!
    }
    
    @IBAction func BaselineCrossedChanged(_ sender: UISegmentedControl) {
        match.autoBaselineCrossed = (sender.selectedSegmentIndex == 0)
    }
    
    @IBAction func HopperTriggeredChanged(_ sender: UISegmentedControl) {
        match.autoHopperTriggered = (sender.selectedSegmentIndex == 0)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        HighGoalSlider.maximumValue = 5.0
        HighGoalSlider.minimumValue = 1.0
        LowGoalSlider.maximumValue = 5.0
        LowGoalSlider.minimumValue = 1.0
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get a reference to the current match
        match = MatchStore.sharedStore.currentMatch as! SteamMatch
        
        if(match.autoStartPos == .none) {
            StartingPosition.selectedSegmentIndex = 0
            match.autoStartPos = .feeder
        } else {
            StartingPosition.selectedSegmentIndex = match.autoStartPos.rawValue-1
        }
        
        BaselineCrossed.selectedSegmentIndex = match.autoBaselineCrossed ? 0 : 1
        HopperTriggered.selectedSegmentIndex = match.autoHopperTriggered ? 0 : 1
        
        HighGoalSlider.value = match.autoHighFuelScored
        LowGoalSlider.value = match.autoLowFuelScored
        NoAttemptHighGoal.isSelected = (match.autoHighFuelScored < 1.0)
        NoAttemptLowGoal.isSelected = (match.autoLowFuelScored < 1.0)
        
        for b in GearButtons {
            b.isSelected = (b.tag == match.autoGearPlacement.rawValue)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        // Update values of fuel if No Attempt is selected
        if(NoAttemptHighGoal.isSelected) {
            match.autoHighFuelScored = 0.0
        }
        
        if(NoAttemptLowGoal.isSelected) {
            match.autoLowFuelScored = 0.0
        }
        
        MatchStore.sharedStore.updateCurrentMatchForType(.autonomous, match: match)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showPenaltyFromAuto") {
            let penalty = segue.destination as! PenaltyViewController
            penalty.dataView = self
        }
    }
}
