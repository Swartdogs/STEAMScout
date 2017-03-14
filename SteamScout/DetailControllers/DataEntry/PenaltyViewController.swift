//
//  PenaltyViewController.swift
//  SteamScout
//
//  Created by Dylan Wells on 2/15/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

class PenaltyViewController: UIViewController {

    var match = SteamMatch()
    
    weak var dataView: UIViewController!
    
    @IBOutlet weak var YellowCard: SelectionButton!
    @IBOutlet weak var RedCard: SelectionButton!
    @IBOutlet weak var Foul: SelectionButton!
    @IBOutlet weak var TechnicalFoul: SelectionButton!
    
    @IBAction func SaveButtonPressed(_ sender: UIBarButtonItem) {
        match.finalYellowCards += YellowCard.isSelected ? 1 : 0
        match.finalRedCards += RedCard.isSelected ? 1 : 0
        match.finalFouls += Foul.isSelected ? 1 : 0
        match.finalTechFouls += TechnicalFoul.isSelected ? 1 : 0
        
        if let autoView = dataView as? AutonomousViewController {
            autoView.match.finalYellowCards += match.finalYellowCards
            autoView.match.finalRedCards    += match.finalRedCards
            autoView.match.finalFouls       += match.finalFouls
            autoView.match.finalTechFouls   += match.finalTechFouls
        }
        
        if let teleView = dataView as? TeleopViewController {
            teleView.match.finalYellowCards += match.finalYellowCards
            teleView.match.finalRedCards    += match.finalRedCards
            teleView.match.finalFouls       += match.finalFouls
            teleView.match.finalTechFouls   += match.finalTechFouls
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func YellowCardPressed(_ sender: UIButton) {
        YellowCard.isSelected = !sender.isSelected
        RedCard.isSelected = false
    }
    
    @IBAction func RedCardPressed(_ sender: UIButton) {
        RedCard.isSelected = !sender.isSelected
        YellowCard.isSelected = false
    }
    
    @IBAction func FoulPressed(_ sender: UIButton) {
        Foul.isSelected = !sender.isSelected
    }
    
    @IBAction func TechnicalFoulPressed(_ sender: UIButton) {
        TechnicalFoul.isSelected = !sender.isSelected
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        YellowCard.isSelected = false
        RedCard.isSelected = false
        Foul.isSelected = false
        TechnicalFoul.isSelected = false
        
        YellowCard.selectedColor    = UIColor.orange
        RedCard.selectedColor       = UIColor.orange
        Foul.selectedColor          = UIColor.orange
        TechnicalFoul.selectedColor = UIColor.orange
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
