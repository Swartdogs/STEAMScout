//
//  FinalViewController.swift
//  SteamScout
//
//  Created by Team 525 Students on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class FinalViewController: UIViewController {

    @IBOutlet var EndingRobotButtons: [UIButton]!
    @IBOutlet var EndingButtons: [UIButton]!
    @IBOutlet var MatchOutcomeButtons: [UIButton]!
    @IBOutlet weak var FinalPenaltyScoreTextField: UITextField!
    @IBOutlet weak var FinalRankingPointsTextField: UITextField!
    @IBOutlet weak var FinalScoreTextField: UITextField!
    @IBOutlet weak var FinalCommentsTextView: UITextView!
    @IBOutlet weak var scrollView:UIScrollView!
    
    fileprivate var match = MatchStore.sharedStore.currentMatch as! SteamMatch
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(FinalViewController.backgroundTap(_:)))
        backgroundTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(backgroundTap)
        
        FinalCommentsTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        match = MatchStore.sharedStore.currentMatch as! SteamMatch
        readyToMoveOn()
        
        FinalPenaltyScoreTextField.text = "\(match.finalPenaltyScore)"
        FinalRankingPointsTextField.text = "\(match.finalRankingPoints)"
        FinalScoreTextField.text = "\(match.finalScore)"
        FinalCommentsTextView.text = match.finalComments
        for b in MatchOutcomeButtons {
            b.isSelected = b.tag == match.finalResult.rawValue
        }
        for b in EndingRobotButtons {
            b.isSelected = (b.tag & match.finalRobot.rawValue) == b.tag
        }
        for b in EndingButtons {
            b.isSelected = (b.tag == match.finalConfiguration.rawValue)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        MatchStore.sharedStore.updateCurrentMatchForType(.finalStats, match: match)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readyToMoveOn() {
        let disable =  match.finalScore < 0 || match.finalPenaltyScore < 0 || match.finalRankingPoints < 0 || match.finalResult == .none
        
        self.navigationItem.rightBarButtonItem?.isEnabled = !disable
    }
    
    @IBAction func RobotButtonTap(_ sender:UIButton) {
        let rState = RobotState(rawValue: sender.tag)
        if sender.isSelected {
            match.finalRobot.subtract(rState)
        } else {
            match.finalRobot.formUnion(rState)
        }
        for b in EndingRobotButtons {
            b.isSelected = (b.tag & match.finalRobot.rawValue) == b.tag
        }
        self.view.endEditing(true)
        print("Final Robot: \(match.finalRobot)")
    }
    
    @IBAction func ConfigTap(_ sender:UIButton) {
        match.finalConfiguration = FinalConfigType(rawValue: sender.isSelected ? 0 : sender.tag)!
        for b in EndingButtons {
            b.isSelected = (b.tag == match.finalConfiguration.rawValue)
        }
        self.view.endEditing(true)
    }
    
    @IBAction func ResultTap(_ sender:UIButton) {
        let result = ResultType(rawValue: sender.tag)!
        if match.finalResult == result { return }
        
        match.finalResult = result;
        for b in MatchOutcomeButtons {
            b.isSelected = b.tag == match.finalResult.rawValue
        }
        self.view.endEditing(true)
        readyToMoveOn()
    }

    @IBAction func FinalScoreEndEdit(_ sender: UITextField) {
        if (sender.text?.characters.count)! > 0 {
            match.finalScore = (Int(sender.text!) ?? match.finalScore)!
            sender.text = "\(match.finalScore)"
        }
        self.view.endEditing(true)
        readyToMoveOn()
        //print("finalScore: \(match.finalScore)")
    }
    
    @IBAction func FinalRPEndEdit(_ sender: UITextField) {
        if (sender.text?.characters.count)! > 0 {
            match.finalRankingPoints = (Int(sender.text!) ?? match.finalRankingPoints)!
            sender.text = "\(match.finalRankingPoints)"
        }
        self.view.endEditing(true)
        readyToMoveOn()
        //print("finalScore: \(match.finalRankingPoints)")
    }
    
    @IBAction func FinalPenaltyEndEdit(_ sender: UITextField) {
        if (sender.text?.characters.count)! > 0 {
            match.finalPenaltyScore = (Int(sender.text!) ?? match.finalPenaltyScore)!
            sender.text = "\(match.finalPenaltyScore)"
        }
        self.view.endEditing(true)
        readyToMoveOn()
        //print("finalScore: \(match.finalPenaltyScore)")
    }
    
    func backgroundTap(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToMatchView" {
            MatchStore.sharedStore.updateCurrentMatchForType(.finalStats, match: match)
            MatchStore.sharedStore.finishCurrentMatch()
        }
    }
}

extension FinalViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        match.finalComments = textView.text
        readyToMoveOn()
    }
}
