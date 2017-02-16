//
//  AutonomousViewController.swift
//  SteamScout
//
//  Created by Dylan Wells on 2/13/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

class AutonomousViewController: UIViewController {
    @IBOutlet weak var NoAttemptHighGoal: UIButton!
    @IBOutlet weak var NoAttemptLowGoal: UIButton!
    @IBOutlet weak var LeftLift: UIButton!
    @IBOutlet weak var RightLift: UIButton!
    @IBOutlet weak var CenterLift: UIButton!
    @IBOutlet weak var NoGearPlaced: UIButton!
    @IBAction func NoGearPlacedPressed(_ sender: UIButton) {
        if NoGearPlaced.isSelected {
            NoGearPlaced.isSelected = false
        }
        else {
            NoGearPlaced.isSelected = true
            LeftLift.isSelected = false
            RightLift.isSelected = false
            CenterLift.isSelected = false
        }
    }
    @IBAction func HighGoalHighlight(_ sender: UIButton) {
        if NoAttemptHighGoal.isSelected {
            NoAttemptHighGoal.isSelected = false
        }
        else {
            NoAttemptHighGoal.isSelected = true
        }
    }
    @IBAction func LowGoalHighLight(_ sender: UIButton) {
        if NoAttemptLowGoal.isSelected {
            NoAttemptLowGoal.isSelected = false
        }
        else {
            NoAttemptLowGoal.isSelected = true
        }
    }
 
    @IBAction func LeftLiftPressed(_ sender: UIButton) {
        if LeftLift.isSelected {
            LeftLift.isSelected = false
            }
        else {
            LeftLift.isSelected = true
            RightLift.isSelected = false
            CenterLift.isSelected = false
            NoGearPlaced.isSelected = false
        }
    }

    @IBAction func CenterLiftPressed(_ sender: UIButton) {
        if CenterLift.isSelected {
            CenterLift.isSelected = false
        }
        else {
            CenterLift.isSelected = true
            LeftLift.isSelected = false
            RightLift.isSelected = false
            NoGearPlaced.isSelected = false
        }
    }
    @IBAction func RightLiftPressed(_ sender: UIButton) {
        if RightLift.isSelected {
            RightLift.isSelected = false
        }
        else {
            RightLift.isSelected = true
            CenterLift.isSelected = false
            LeftLift.isSelected = false
            NoGearPlaced.isSelected = false
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
