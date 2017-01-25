//
//  MatchStore.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class MatchStore: NSObject {
    
    static let sharedStore:MatchStore = MatchStore()
    
    var allMatches:[Match] = []
    var matchesToScout:[MatchQueueData] = []
    var currentMatchIndex = -1
    var currentMatch:Match?
    var fieldLayout:FieldLayoutType = .blueRed
    
    // Action Edit
    
    var actionsUndo:Stack<ActionEdit> = Stack<ActionEdit>(limit: 1)
    var actionsRedo:Stack<ActionEdit> = Stack<ActionEdit>(limit: 1)
    
    override init() {
        super.init()
        
        allMatches = NSKeyedUnarchiver.unarchiveObject(withFile: self.matchArchivePath()) as? [Match] ?? allMatches
        let queueData = NSKeyedUnarchiver.unarchiveObject(withFile: self.match2ScoutArchivePath()) as? [NSDictionary]
        if let qD = queueData {
            for d in qD {
                let mqd = MatchQueueData(propertyListRepresentation: d)!
                matchesToScout.append(mqd)
            }
        }
        
        if allMatches.count == 0 {
            print("No Match data existed!")
            allMatches = []
        } else {
            print("Match Data successfully Loaded")
        }
        
        //let currentMatchData = NSUserDefaults.standardUserDefaults().objectForKey("StrongScout.currentMatch") as? NSData
        let fieldLayout = UserDefaults.standard.integer(forKey: "StrongScout.fieldLayout")
        self.fieldLayout = FieldLayoutType(rawValue: fieldLayout)!
        
//        if currentMatchData == nil {
//            currentMatch = nil
//        } else {
//            currentMatch = NSKeyedUnarchiver.unarchiveObjectWithData(currentMatchData!) as? Match
//        }
    }
    
    func matchArchivePath() -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent("Match.archive")
    }
    
    func match2ScoutArchivePath() -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent("MatchQueue.archive")
    }
    
    func filePath(_ filename:String) -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent(filename)
    }
    
    func csvFilePath() -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent("Match data - \(UIDevice.current.name).csv")
    }
    
    func saveChanges() -> Bool {
        if !self.writeCSVFile() {
            return false
        }
        UserDefaults.standard.set(fieldLayout.rawValue, forKey: "StrongScout.fieldLayout")
//        saveCurrentMatch()
        
        let path = self.matchArchivePath()
        let path2 = self.match2ScoutArchivePath()
        // let jsonPath = self.filePath("Match.json")
        
        var queueData = [NSDictionary]()
        for mqd in matchesToScout {
            let d = mqd.propertyListRepresentation()
            queueData.append(d)
        }
        
        // let data = dataTransferMatchesAll(true)
        // let string = String(data: data!, encoding: NSUTF8StringEncoding)
        
//        do {
//            try string?.writeToFile(jsonPath, atomically: true, encoding: NSUTF8StringEncoding)
//        } catch  {
//            
//        }
        
        NSKeyedArchiver.archiveRootObject(queueData, toFile: path2)
        
        return NSKeyedArchiver.archiveRootObject(allMatches, toFile: path)
    }
    
//    func saveCurrentMatch() {
//        if currentMatch == nil {
//            NSUserDefaults.standardUserDefaults().setNilValueForKey("StrongScout.currentMatch")
//        } else {
//            let currentMatchData = NSKeyedArchiver.archivedDataWithRootObject(currentMatch!)
//            NSUserDefaults.standardUserDefaults().setValue(currentMatchData, forKey: "StrongScout.currentMatch")
//        }
//    }
    
    func writeCSVFile() -> Bool {
        let device = "\(UIDevice.current.name)    \r\n"
        var csvFileString = device
        
        csvFileString += Match.writeMatchCSVHeader()
        
        for m in allMatches {
            csvFileString += m.writeMatchCSV() + " \r\n"
        }
        
        do {
            try csvFileString.write(toFile: self.csvFilePath(), atomically: true, encoding: String.Encoding.utf8)
        } catch {
            return false
        }
        return true
    }
    
    func exportNewMatchData() -> Bool {
        
        let device = "\(UIDevice.current.name)  \r\n"
        var csvFileString = device
        var matchJSONData = [NSDictionary]();
        
        csvFileString += Match.writeMatchCSVHeader()
        
        for m in allMatches {
            if (m.isCompleted & 32) == 32 {
                m.isCompleted ^= 32
                csvFileString += m.writeMatchCSV() + " \r\n"
                matchJSONData.append(m.messageDictionary())
            }
        }
        
        do {
            try csvFileString.write(toFile: self.filePath("newMatchData.csv"), atomically: true, encoding: String.Encoding.utf8)
            // let jsonData = try NSJSONSerialization.dataWithJSONObject(matchJSONData, options: .PrettyPrinted)
            // jsonData.writeToFile(self.filePath("newMatchData.json"), atomically: true)
        } catch {
            return false
        }
        
        return saveChanges()
    }
    
    func createMatch() {
        currentMatch = Match()
        currentMatchIndex = -1
        actionsUndo.clearAll()
        actionsRedo.clearAll()
    }
    
    func createMatchFromQueueIndex(_ index:Int) {
        guard 0..<matchesToScout.count ~= index else { return }
        let data = matchesToScout[index]
        currentMatch = Match(queueData: data)
        currentMatchIndex = index
        actionsUndo.clearAll()
        actionsRedo.clearAll()
    }
    
    func addMatch(_ newMatch:Match) {
        allMatches.append(newMatch)
    }
    
    func cancelCurrentMatchEdit() {
        currentMatch = nil
        currentMatchIndex = -1
        actionsUndo.clearAll()
        actionsRedo.clearAll()
    }
    
    func containsMatch(_ match:Match?) -> Bool {
        if let search:Match = match {
            for m in allMatches {
                if m.teamNumber == search.teamNumber && m.matchNumber == search.matchNumber {
                    return true
                }
            }
        }
        return false
    }
    
    func removeMatchQueueAtIndex(_ index:Int) {
        guard 0..<matchesToScout.count ~= index else { return }
        matchesToScout.remove(at: index)
    }
    
    func removeMatchAtIndex(_ index:Int) {
        guard 0..<allMatches.count ~= index else { return }
        allMatches.remove(at: index)
    }
    
    func removeMatch(_ thisMatch:Match) {
        for (index, value) in allMatches.enumerated() {
            if value.teamNumber == thisMatch.teamNumber && value.matchNumber == thisMatch.matchNumber {
                allMatches.remove(at: index)
            }
        }
    }
    
    func replace(_ oldMatch:Match, withNewMatch newMatch:Match) {
        for (index, value) in allMatches.enumerated() {
            if value.teamNumber == oldMatch.teamNumber && value.matchNumber == oldMatch.matchNumber {
                allMatches[index] = newMatch
            }
        }
    }
    
    func updateCurrentMatchForType(_ type:UpdateType, match:Match) {
        switch type {
        case .teamInfo:
            currentMatch?.teamNumber  = match.teamNumber
            currentMatch?.matchNumber = match.matchNumber
            currentMatch?.alliance    = match.alliance
            currentMatch?.isCompleted = match.isCompleted
            currentMatch?.finalResult = match.finalResult
            break;
        case .fieldSetup:
            currentMatch?.defense1.type = match.defense1.type
            currentMatch?.defense2.type = match.defense2.type
            currentMatch?.defense3.type = match.defense3.type
            currentMatch?.defense4.type = match.defense4.type
            currentMatch?.defense5.type = match.defense5.type
            currentMatch?.defenses = [(currentMatch?.defense1)!, (currentMatch?.defense2)!, (currentMatch?.defense3)!, (currentMatch?.defense4)!, (currentMatch?.defense5)!]
            break;
        case .finalStats:
            currentMatch?.finalScore         = match.finalScore
            currentMatch?.finalRankingPoints = match.finalRankingPoints
            currentMatch?.finalResult        = match.finalResult
            currentMatch?.finalPenaltyScore  = match.finalPenaltyScore
            currentMatch?.finalConfiguration = match.finalConfiguration
            currentMatch?.finalComments      = match.finalComments
        case .actionsEdited:
            currentMatch?.actionsPerformed = match.actionsPerformed
        default:
            break;
        }
    }
    
    func updateCurrentMatchWithAction(_ action:Action) {
        print("Adding Action: \(action.type)")
        switch action.data {
        case let .scoreData(score):
            print("\tScoreType: \(score.type.toString())")
            print("\tScoreLoc:  \(score.location.toString())")
            break
        case let .defenseData(defense):
            print("\tDefenseType:   \(defense.type.toString())")
            print("\tDefenseAction: \(defense.actionPerformed.toString())")
            if(1...3 ~= defense.actionPerformed.rawValue && action.section == .auto) {
                currentMatch?.isCompleted |= 8;
            }
            break
        case let .penaltyData(penalty):
            print("\tPenaltyType: \(penalty.toString())")
            break
        default:
            break
        }
        currentMatch?.actionsPerformed.append(action)
    }
    
    func aggregateCurrentMatchData() {
        if currentMatch == nil { return }
        currentMatch!.aggregateActionsPerformed()
    }
    
    func finishCurrentMatch() {
        aggregateCurrentMatchData()
        allMatches.append(currentMatch!)
        if currentMatchIndex >= 0 {
            matchesToScout.remove(at: currentMatchIndex)
        }
        currentMatchIndex = -1
        let success = self.saveChanges()
        print("All Matches were \(success ? "" : "un")successfully saved")
        currentMatch = nil
    }
    
    func dataTransferMatchesAll(_ all:Bool) -> Data? {
        var matchData = [NSDictionary]()
        
        for match in allMatches {
            matchData.append(match.messageDictionary())
        }
        
        return try? JSONSerialization.data(withJSONObject: matchData, options: .prettyPrinted)
    }
    
    func createMatchQueueFromMatchData(_ data:[MatchQueueData]) {
        guard data.count > 0 else { return }
        
        matchesToScout.removeAll()
        matchesToScout = data
        _ = self.saveChanges()
    }
    
    func clearMatchData(_ type:Int) {
        if type & 1 == 1 {
            matchesToScout.removeAll()
        }
        
        if type & 2 == 2 {
            allMatches.removeAll()
        }
    }
}
