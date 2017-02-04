//
//  TeamInfoViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 2/7/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
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
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class TeamInfoViewController: UIViewController {
    
    @IBOutlet weak var teamNumberTextField: UITextField!
    @IBOutlet weak var matchNumberTextField: UITextField!
    @IBOutlet var allianceButtons: [UIButton]!
    @IBOutlet weak var noShowButton: UIButton!
    
    var m:Match = Match()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TeamInfoViewController.backgroundTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        m = MatchStore.sharedStore.currentMatch ?? m
        
        m.isCompleted |= 1;
        //if let m:Match = MatchStore.sharedStore.currentMatch {
            teamNumberTextField.text = m.teamNumber > 0 ? "\(m.teamNumber)" : ""
            matchNumberTextField.text = m.matchNumber > 0 ? "\(m.matchNumber)" : ""
            allianceButtons[0].isSelected = m.alliance == .blue
            allianceButtons[1].isSelected = m.alliance == .red
            noShowButton.isSelected = m.finalResult == .noShow
        //}
        
        readyToMoveOn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        teamNumberTextField.resignFirstResponder()
        matchNumberTextField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToEndMatchNoShow" {
            MatchStore.sharedStore.updateCurrentMatchForType(.teamInfo, match: m)
            MatchStore.sharedStore.finishCurrentMatch()
        } else if segue.identifier == "segueToFieldSetup" {
            MatchStore.sharedStore.updateCurrentMatchForType(.teamInfo, match: m)
        }
    }
    
    func readyToMoveOn() {
        let disable = m.teamNumber <= 0 || m.matchNumber <= 0 || m.alliance == .unknown
        self.navigationItem.rightBarButtonItem?.isEnabled = !disable
    }
    
    @IBAction func textFieldEditDidEnd(_ sender: UITextField) {
        if sender.text?.characters.count <= 0 { return }
        if sender === teamNumberTextField {
            m.teamNumber = (Int(sender.text!) ?? m.teamNumber)!
            sender.text = m.teamNumber > 0 ? "\(m.teamNumber)" : ""
        } else if sender === matchNumberTextField {
            m.matchNumber = (Int(sender.text!) ?? m.matchNumber)!
            sender.text = m.matchNumber > 0 ? "\(m.matchNumber)" : ""
        }
        
        readyToMoveOn()
    }
    
    @IBAction func allianceTap(_ sender: UIButton) {
        if sender.tag == 0 {
            m.alliance = .blue
        } else if sender.tag == 1 {
            m.alliance = .red
        } else {
            m.alliance = .unknown
        }
        allianceButtons[0].isSelected = m.alliance == .blue
        allianceButtons[1].isSelected = m.alliance == .red
        self.view.endEditing(true)
        readyToMoveOn()
    }
    
    @IBAction func noShowTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if(sender.isSelected) {
            m.finalResult = .noShow
            self.navigationItem.rightBarButtonItem?.title = "End Match"
        } else {
            m.finalResult = .none
            self.navigationItem.rightBarButtonItem?.title = "Next"
        }
        self.view.endEditing(true)
    }
    
    @IBAction func nextButtonTap(_ sender:UIBarButtonItem) {
        if m.finalResult == .noShow {
            let noShowAC = UIAlertController(title: "No Show Match", message: "You've indicated that this team is a no show.  The match will now end.  Are you sure you want to continue?", preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "segueToEndMatchNoShow", sender: nil)
            })
            noShowAC.addAction(continueAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            noShowAC.addAction(cancelAction)
            
            self.present(noShowAC, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "segueToFieldSetup", sender: nil)
        }
    }
    
    func backgroundTap(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
