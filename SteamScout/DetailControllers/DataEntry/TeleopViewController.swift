//
//  TeleopViewController.swift
//  SteamScout
//
//  Created by Dylan Wells on 2/13/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

class TeleopViewController: UIViewController {
    
    var match = SteamMatch()
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
            match.teleGearsScored = Int(sender.value)
            valueLabel.text = Int(sender.value).description
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.wraps = false
        stepper.autorepeat = false
        stepper.maximumValue = 12
        stepper.stepValue = 1
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        match = MatchStore.sharedStore.currentMatch as! SteamMatch
        
        stepper.value = Double(match.teleGearsScored)
        valueLabel.text = "\(match.teleGearsScored)"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        MatchStore.sharedStore.updateCurrentMatchForType(.teleop, match: match)
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
