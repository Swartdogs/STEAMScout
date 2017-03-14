//
//  TeleopFuelPopoverViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/14/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

class TeleopFuelPopoverViewController: UIViewController {
    
    var match = SteamMatch()
    
    weak var teleopView: TeleopViewController!

    @IBOutlet weak var HighGoalSlider: UISlider!
    @IBOutlet weak var LowGoalSlider: UISlider!
    
    @IBAction func GoalSliderChanged(_ sender: UISlider) {
        if(sender.tag == 0) {
            match.teleHighFuelScored = sender.value
        } else if(sender.tag == 1) {
            match.teleLowFuelScored = sender.value
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        match = teleopView.match
        
        HighGoalSlider.value = match.teleHighFuelScored
        LowGoalSlider.value = match.teleLowFuelScored
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        teleopView.match.teleLowFuelScored = match.teleLowFuelScored
        teleopView.match.teleHighFuelScored = match.teleHighFuelScored
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
