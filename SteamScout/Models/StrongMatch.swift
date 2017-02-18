//
//  Match.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ScoreStat = (scored:Int, missed:Int)

class StrongMatch : MatchImpl, Actionable, NSCoding {
    
    // Auto Scoring Info
    
    var autoHigh:ScoreStat      = (0, 0)
    var autoLow:ScoreStat       = (0, 0)
    var autoBatters:ScoreStat   = (0, 0)
    var autoCourtyard:ScoreStat = (0, 0)
    var autoDefenses:ScoreStat  = (0, 0)
    
    // Scoring Info
    
    var teleHigh:ScoreStat      = (0, 0)
    var teleLow:ScoreStat       = (0, 0)
    var teleBatters:ScoreStat   = (0, 0)
    var teleCourtyard:ScoreStat = (0, 0)
    var teleDefenses:ScoreStat  = (0, 0)
    
    // Defense Info
    
    var defense1 = Defense(withDefenseType: .lowbar)
    var defense2 = Defense()
    var defense3 = Defense()
    var defense4 = Defense()
    var defense5 = Defense()
    lazy var defenses:[Defense] = [self.defense1, self.defense2, self.defense3, self.defense4, self.defense5]
    
    // Action Info
    
    var actionsPerformed:[Action] = []
    
    // Final Info
    
    var finalConfiguration:FinalConfigType = .none
    
    func aggregateActionsPerformed() {
        self.teleHigh      = (0, 0)
        self.teleLow       = (0, 0)
        self.teleBatters   = (0, 0)
        self.teleCourtyard = (0, 0)
        self.teleDefenses  = (0, 0)
        
        self.autoHigh      = (0, 0)
        self.autoLow       = (0, 0)
        self.autoBatters   = (0, 0)
        self.autoCourtyard = (0, 0)
        self.autoDefenses  = (0, 0)
        
        self.defense1.clearStats()
        self.defense2.clearStats()
        self.defense3.clearStats()
        self.defense4.clearStats()
        self.defense5.clearStats()
        
        self.defense1.location = 1
        self.defense2.location = 2
        self.defense3.location = 3
        self.defense4.location = 4
        self.defense5.location = 5
        
        self.finalFouls = 0
        self.finalTechFouls = 0
        self.finalYellowCards = 0
        self.finalRedCards = 0
        
        for action in self.actionsPerformed {
            let a = action
            switch a.data {
            case let .scoreData(score):
                if a.section == .tele {
                    self.teleHigh.scored       += (score.type == .high)          ? 1 : 0
                    self.teleHigh.missed       += (score.type == .missedHigh)    ? 1 : 0
                    self.teleLow.scored        += (score.type == .low)           ? 1 : 0
                    self.teleLow.missed        += (score.type == .missedLow)     ? 1 : 0
                    self.teleBatters.scored   += (score.location == .batter && !score.type.missed)    ? 1 : 0
                    self.teleBatters.missed   += (score.location == .batter && score.type.missed)     ? 1 : 0
                    self.teleCourtyard.scored += (score.location == .courtyard && !score.type.missed) ? 1 : 0
                    self.teleCourtyard.missed += (score.location == .courtyard && score.type.missed)  ? 1 : 0
                    self.teleDefenses.scored  += (score.location == .defenses && !score.type.missed)  ? 1 : 0
                    self.teleDefenses.missed  += (score.location == .defenses && score.type.missed)   ? 1 : 0
                } else {
                    self.autoHigh.scored      += (score.type == .high)          ? 1 : 0
                    self.autoHigh.missed      += (score.type == .missedHigh)    ? 1 : 0
                    self.autoLow.scored       += (score.type == .low)           ? 1 : 0
                    self.autoLow.missed       += (score.type == .missedLow)     ? 1 : 0
                    self.autoBatters.scored   += (score.location == .batter && !score.type.missed)    ? 1 : 0
                    self.autoBatters.missed   += (score.location == .batter && score.type.missed)     ? 1 : 0
                    self.autoCourtyard.scored += (score.location == .courtyard && !score.type.missed) ? 1 : 0
                    self.autoCourtyard.missed += (score.location == .courtyard && score.type.missed)  ? 1 : 0
                    self.autoDefenses.scored  += (score.location == .defenses && !score.type.missed)  ? 1 : 0
                    self.autoDefenses.missed  += (score.location == .defenses && score.type.missed)   ? 1 : 0
                }
                continue
            case let .defenseData(defense):
                if defense.type == self.defense1.type {
                    if a.section == .tele {
                        self.defense1.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense1.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense1.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense1.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense1.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense1.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense1.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense1.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                } else if defense.type == self.defense2.type {
                    if a.section == .tele {
                        self.defense2.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense2.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense2.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense2.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense2.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense2.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense2.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense2.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                } else if defense.type == self.defense3.type {
                    if a.section == .tele {
                        self.defense3.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense3.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense3.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense3.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense3.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense3.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense3.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense3.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                } else if defense.type == self.defense4.type {
                    if a.section == .tele {
                        self.defense4.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense4.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense4.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense4.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense4.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense4.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense4.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense4.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                } else if defense.type == self.defense5.type {
                    if a.section == .tele {
                        self.defense5.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense5.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense5.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense5.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense5.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense5.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense5.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense5.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                }
                continue
            case let .penaltyData(penalty):
                self.finalFouls       += (penalty == .foul)       ? 1 : 0
                self.finalTechFouls   += (penalty == .techFoul)   ? 1 : 0
                self.finalYellowCards += (penalty == .yellowCard) ? 1 : 0
                self.finalRedCards    += (penalty == .redCard)    ? 1 : 0
                continue
            default:
                continue
            }
        }
        self.defenses = [defense1, defense2, defense3, defense4, defense5]
    }
    
    func encode(with aCoder: NSCoder) {
        
        // Team Information
        aCoder.encode(teamNumber,        forKey: "teamNumber")
        aCoder.encode(matchNumber,       forKey: "matchNumber")
        aCoder.encode(alliance.rawValue, forKey: "alliance")
        aCoder.encode(isCompleted,       forKey: "isCompleted")
        
        // Auto Score Information
        aCoder.encode(autoHigh.scored,      forKey: "autoScoreHigh")
        aCoder.encode(autoHigh.missed,      forKey: "autoMissedHigh")
        aCoder.encode(autoLow.scored,       forKey: "autoScoreLow")
        aCoder.encode(autoLow.missed,       forKey: "autoMissedLow")
        aCoder.encode(autoBatters.scored,   forKey: "autoScoredBatters")
        aCoder.encode(autoBatters.missed,   forKey: "autoMissedBatters")
        aCoder.encode(autoCourtyard.scored, forKey: "autoScoredCourtyard")
        aCoder.encode(autoCourtyard.missed, forKey: "autoMissedCourtyard")
        aCoder.encode(autoDefenses.scored,  forKey: "autoScoredDefenses")
        aCoder.encode(autoDefenses.missed,  forKey: "autoMissedDefenses")
        
        // Score Information
        aCoder.encode(teleHigh.scored,      forKey: "teleScoreHigh")
        aCoder.encode(teleHigh.missed,      forKey: "teleMissedHigh")
        aCoder.encode(teleLow.scored,       forKey: "teleScoreLow")
        aCoder.encode(teleLow.missed,       forKey: "teleMissedLow")
        aCoder.encode(teleBatters.scored,   forKey: "teleScoredBatters")
        aCoder.encode(teleBatters.missed,   forKey: "teleMissedBatters")
        aCoder.encode(teleCourtyard.scored, forKey: "teleScoredCourtyard")
        aCoder.encode(teleCourtyard.missed, forKey: "teleMissedCourtyard")
        aCoder.encode(teleDefenses.scored,  forKey: "teleScoredDefenses")
        aCoder.encode(teleDefenses.missed,  forKey: "teleMissedDefenses")
        
        // Defense Information
        aCoder.encode(defense1.propertyListRepresentation(), forKey: "defense1")
        aCoder.encode(defense2.propertyListRepresentation(), forKey: "defense2")
        aCoder.encode(defense3.propertyListRepresentation(), forKey: "defense3")
        aCoder.encode(defense4.propertyListRepresentation(), forKey: "defense4")
        aCoder.encode(defense5.propertyListRepresentation(), forKey: "defense5")
        
        // Actions Information
        var actionsPerformedPList:[NSDictionary] = []
        for a in actionsPerformed {
            actionsPerformedPList.append(a.propertyListRepresentation())
        }
        aCoder.encode(actionsPerformedPList, forKey: "actionsPerformed")
        
        // Final Information
        aCoder.encode(finalScore,                  forKey: "finalScore")
        aCoder.encode(finalRankingPoints,          forKey: "finalRankingPoints")
        aCoder.encode(finalResult.rawValue,        forKey: "finalResult")
        aCoder.encode(finalPenaltyScore,           forKey: "finalPenaltyScore")
        aCoder.encode(finalFouls,                  forKey: "finalFouls")
        aCoder.encode(finalTechFouls,              forKey: "finalTechFouls")
        aCoder.encode(finalYellowCards,            forKey: "finalYellowCards")
        aCoder.encode(finalRedCards,               forKey: "finalRedCards")
        aCoder.encode(finalRobot.rawValue,         forKey: "finalRobot")
        aCoder.encode(finalConfiguration.rawValue, forKey: "finalConfiguration")
        aCoder.encode(finalComments,                forKey: "finalComments")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init()
        
        // Team Information
        self.teamNumber  = aDecoder.decodeInteger(forKey: "teamNumber")
        self.matchNumber = aDecoder.decodeInteger(forKey: "matchNumber")
        self.alliance    = AllianceType(rawValue:aDecoder.decodeInteger(forKey: "alliance"))!
        self.isCompleted = aDecoder.decodeInteger(forKey: "isCompleted")
        
        // Auto Score Information
        var highScore       = aDecoder.decodeInteger(forKey: "autoScoreHigh")
        var highMiss        = aDecoder.decodeInteger(forKey: "autoMissedHigh")
        var lowScore        = aDecoder.decodeInteger(forKey: "autoScoreLow")
        var lowMiss         = aDecoder.decodeInteger(forKey: "autoMissedLow")
        var battersScore    = aDecoder.decodeInteger(forKey: "autoScoredBatters")
        var battersMissed   = aDecoder.decodeInteger(forKey: "autoScoredBatters")
        var courtyardScore  = aDecoder.decodeInteger(forKey: "autoScoredCourtyard")
        var courtyardMissed = aDecoder.decodeInteger(forKey: "autoMissedCourtyard")
        var defensesScore   = aDecoder.decodeInteger(forKey: "autoScoredDefenses")
        var defensesMissed  = aDecoder.decodeInteger(forKey: "autoMissedDefenses")
        
        self.autoHigh       = (highScore, highMiss)
        self.autoLow        = (lowScore, lowMiss)
        self.autoBatters    = (battersScore, battersMissed)
        self.autoCourtyard  = (courtyardScore, courtyardMissed)
        self.autoDefenses   = (defensesScore, defensesMissed)
        
        // Score Information
        highScore       = aDecoder.decodeInteger(forKey: "teleScoreHigh")
        highMiss        = aDecoder.decodeInteger(forKey: "teleMissedHigh")
        lowScore        = aDecoder.decodeInteger(forKey: "teleScoreLow")
        lowMiss         = aDecoder.decodeInteger(forKey: "teleMissedLow")
        battersScore    = aDecoder.decodeInteger(forKey: "teleScoredBatters")
        battersMissed   = aDecoder.decodeInteger(forKey: "teleScoredBatters")
        courtyardScore  = aDecoder.decodeInteger(forKey: "teleScoredCourtyard")
        courtyardMissed = aDecoder.decodeInteger(forKey: "teleMissedCourtyard")
        defensesScore   = aDecoder.decodeInteger(forKey: "teleScoredDefenses")
        defensesMissed  = aDecoder.decodeInteger(forKey: "teleMissedDefenses")
        
        self.autoHigh       = (highScore, highMiss)
        self.autoLow        = (lowScore, lowMiss)
        self.autoBatters    = (battersScore, battersMissed)
        self.autoCourtyard  = (courtyardScore, courtyardMissed)
        self.autoDefenses   = (defensesScore, defensesMissed)
        
        // Defense Information
        self.defense1 = Defense(propertyListRepresentation: aDecoder.decodeObject(forKey: "defense1") as? NSDictionary)!
        self.defense2 = Defense(propertyListRepresentation: aDecoder.decodeObject(forKey: "defense2") as? NSDictionary)!
        self.defense3 = Defense(propertyListRepresentation: aDecoder.decodeObject(forKey: "defense3") as? NSDictionary)!
        self.defense4 = Defense(propertyListRepresentation: aDecoder.decodeObject(forKey: "defense4") as? NSDictionary)!
        self.defense5 = Defense(propertyListRepresentation: aDecoder.decodeObject(forKey: "defense5") as? NSDictionary)!
        
        // Actions Information
        let actionsPerformedPList = aDecoder.decodeObject(forKey: "actionsPerformed") as? [NSDictionary]
        self.actionsPerformed = []
        for pList in actionsPerformedPList! {
            guard let action = Action(propertyListRepresentation: pList) else { continue }
            self.actionsPerformed.append(action)
        }
        
        // Final Information
        self.finalScore         = aDecoder.decodeInteger(forKey: "finalScore")
        self.finalRankingPoints = aDecoder.decodeInteger(forKey: "finalRankingPoints")
        self.finalResult        = ResultType(rawValue: aDecoder.decodeInteger(forKey: "finalResult"))!
        self.finalPenaltyScore  = aDecoder.decodeInteger(forKey: "finalPenaltyScore")
        self.finalFouls         = aDecoder.decodeInteger(forKey: "finalFouls")
        self.finalTechFouls     = aDecoder.decodeInteger(forKey: "finalTechFouls")
        self.finalYellowCards   = aDecoder.decodeInteger(forKey: "finalYellowCards")
        self.finalRedCards      = aDecoder.decodeInteger(forKey: "finalRedCards")
        self.finalRobot         = RobotState(rawValue: aDecoder.decodeInteger(forKey: "finalRobot"))
        self.finalConfiguration = FinalConfigType(rawValue: aDecoder.decodeInteger(forKey: "finalConfiguration"))!
        self.finalComments      = (aDecoder.decodeObject(forKey: "finalComments") as? String) ?? ""
    }
    
    required init(queueData:MatchQueueData) {
        super.init(queueData:queueData)
    }
    
    required init() {
        // Init
        super.init()
    }
    
    override var messageDictionary:Dictionary<String, AnyObject> {
        var data:[String:AnyObject]    = [String:AnyObject]()
        var team:[String:AnyObject]    = [String:AnyObject]()
        var auto:[String:AnyObject]    = [String:AnyObject]()
        var tele:[String:AnyObject]   = [String:AnyObject]()
        var defense:[String:AnyObject] = [String:AnyObject]()
        var final:[String:AnyObject]   = [String:AnyObject]()
        
        // Team Info
        team["teamNumber"]  = teamNumber as AnyObject?
        team["matchNumber"] = matchNumber as AnyObject?
        team["alliance"]    = alliance.toString() as AnyObject?
        
        // Auto
        auto["scoreHigh"]       = autoHigh.scored as AnyObject?
        auto["missedHigh"]      = autoHigh.missed as AnyObject?
        auto["scoreLow"]        = autoLow.scored as AnyObject?
        auto["missedLow"]       = autoLow.missed as AnyObject?
        auto["scoreBatters"]    = autoBatters.scored as AnyObject?
        auto["missedBatters"]   = autoBatters.missed as AnyObject?
        auto["scoreCourtyard"]  = autoCourtyard.scored as AnyObject?
        auto["missedCourtyard"] = autoCourtyard.missed as AnyObject?
        auto["scoreDefenses"]   = autoDefenses.scored as AnyObject?
        auto["missedDefenses"]  = autoDefenses.missed as AnyObject?
        
        // Score
        tele["scoreHigh"]       = teleHigh.scored as AnyObject?
        tele["missedHigh"]      = teleHigh.missed as AnyObject?
        tele["scoreLow"]        = teleLow.scored as AnyObject?
        tele["missedLow"]       = teleLow.missed as AnyObject?
        tele["scoreBatters"]    = teleBatters.scored as AnyObject?
        tele["missedBatters"]   = teleBatters.missed as AnyObject?
        tele["scoreCourtyard"]  = teleCourtyard.scored as AnyObject?
        tele["missedCourtyard"] = teleCourtyard.missed as AnyObject?
        tele["scoreDefenses"]   = teleDefenses.scored as AnyObject?
        tele["missedDefenses"]  = teleDefenses.missed as AnyObject?

        
        // Defenses
        defense["defense1"] = defense1.propertyListRepresentation()
        defense["defense2"] = defense2.propertyListRepresentation()
        defense["defense3"] = defense3.propertyListRepresentation()
        defense["defense4"] = defense4.propertyListRepresentation()
        defense["defense5"] = defense5.propertyListRepresentation()
        
        // Final Info
        final["score"]    = finalScore as AnyObject?
        final["rPoints"]  = finalRankingPoints as AnyObject?
        final["result"]   = finalResult.rawValue as AnyObject?
        final["pScore"]   = finalPenaltyScore as AnyObject?
        final["fouls"]    = finalFouls as AnyObject?
        final["tFouls"]   = finalTechFouls as AnyObject?
        final["yCards"]   = finalYellowCards as AnyObject?
        final["rCards"]   = finalRedCards as AnyObject?
        final["robot"]    = finalRobot.rawValue as AnyObject?
        final["config"]   = finalConfiguration.rawValue as AnyObject?
        final["comments"] = finalComments as AnyObject?
        
        // All Data
        data["team"]    = team as AnyObject?
        data["auto"]    = auto as AnyObject?
        data["tele"]    = tele as AnyObject?
        data["defense"] = defense as AnyObject?
        data["final"]   = final as AnyObject?
        
        return data
    }
    
    override class var csvHeader:String {
        var matchHeader = ""
        
        matchHeader += "Match Number, Team Number, Alliance, "
        
        matchHeader += "Auto Scored High, Auto Missed High, Auto Scored Low, Auto Missed Low, "
        matchHeader += "Auto Scored Batters, Auto Missed Batters, Auto Scored Courtyard, Auto Missed Courtyard, Auto Scored Defenses, Auto Missed Defenses, "
        
        matchHeader += "Tele Scored High, Tele Missed High, Tele Scored Low, Tele Missed Low, "
        matchHeader += "Tele Scored Batters, Tele Missed Batters, Tele Scored Courtyard, Tele Missed Courtyard, Tele Scored Defenses, Tele Missed Defenses, "
        
        matchHeader += "Defense 1 Type, "
        matchHeader += "D1 Auto Crossed, D1 Auto Attempted Cross, D1 Auto Crossed With Ball, D1 Auto Assisted Cross, "
        matchHeader += "D1 Tele Crossed, D1 Tele Attempted Cross, D1 Tele Crossed With Ball, D1 Tele Assisted Cross, "
        
        matchHeader += "Defense 2 Type, "
        matchHeader += "D2 Auto Crossed, D2 Auto Attempted Cross, D2 Auto Crossed With Ball, D2 Auto Assisted Cross, "
        matchHeader += "D2 Tele Crossed, D2 Tele Attempted Cross, D2 Tele Crossed With Ball, D2 Tele Assisted Cross, "
        
        matchHeader += "Defense 3 Type, "
        matchHeader += "D3 Auto Crossed, D3 Auto Attempted Cross, D3 Auto Crossed With Ball, D3 Auto Assisted Cross, "
        matchHeader += "D3 Tele Crossed, D3 Tele Attempted Cross, D3 Tele Crossed With Ball, D3 Tele Assisted Cross, "
        
        matchHeader += "Defense 4 Type, "
        matchHeader += "D4 Auto Crossed, D4 Auto Attempted Cross, D4 Auto Crossed With Ball, D4 Auto Assisted Cross, "
        matchHeader += "D4 Tele Crossed, D4 Tele Attempted Cross, D4 Tele Crossed With Ball, D4 Tele Assisted Cross, "
        
        matchHeader += "Defense 5 Type, "
        matchHeader += "D5 Auto Crossed, D5 Auto Attempted Cross, D5 Auto Crossed With Ball, D5 Auto Assisted Cross, "
        matchHeader += "D5 Tele Crossed, D5 Tele Attempted Cross, D5 Tele Crossed With Ball, D5 Tele Assisted Cross, "
        
        matchHeader += "Final Score, Final Ranking Points, Penalty Points Received, Final Result, Fouls, Tech Fouls, Yellow Cards, Red Cards, Robot, Config, Comments \r\n"
        
        return matchHeader
    }
    
    override var csvMatch:String {
        var matchData = ""
        let match = JSON(messageDictionary)
        
        matchData += "\(match["team", "matchNumber"].intValue),"
        matchData += "\(match["team", "teamNumber"].intValue),"
        matchData += "\(match["team", "alliance"].stringValue),"
        
        let typeKeys = ["auto", "tele"]
        let scoreKeys = ["scoreHigh", "missedHigh", "scoreLow", "missedLow", "scoreBatters", "missedBatters", "scoreCourtyard", "missedCourtyard", "scoreDefenses", "missedDefenses"]
        for i in 0..<typeKeys.count {
            for j in 0..<scoreKeys.count {
                matchData += "\(match[typeKeys[i], scoreKeys[j]].intValue),"
            }
        }
        
        let defenseNames = ["defense1", "defense2", "defense3", "defense4", "defense5"]
        let defenseVals = ["type", "atcross", "afcross", "abcross", "aacross", "cross", "fcross", "bcross", "across"]
        for i in 0..<defenseNames.count {
            for j in 0..<defenseVals.count {
                matchData += "\(match["defense", defenseNames[i], defenseVals[j]].intValue),"
            }
        }
        
        let finalKeys = ["score", "rPoints", "pScore", "result", "fouls", "tFouls", "yCards", "rCards", "robot", "config"]
        for i in 0..<finalKeys.count {
            matchData += "\(match["final", finalKeys[i]].intValue),"
        }
        matchData += "\(match["final", "comments"].stringValue)"

        return matchData
    }
    
    override func updateForType(_ type:UpdateType, withMatch match:Match) {
        let m = match as! StrongMatch
        switch type {
        case .teamInfo:
            teamNumber  = m.teamNumber
            matchNumber = m.matchNumber
            alliance    = m.alliance
            isCompleted = m.isCompleted
            finalResult = m.finalResult
            break;
        case .fieldSetup:
            defense1.type = m.defense1.type
            defense2.type = m.defense2.type
            defense3.type = m.defense3.type
            defense4.type = m.defense4.type
            defense5.type = m.defense5.type
            defenses = [(defense1), (defense2), (defense3), (defense4), (defense5)]
            break;
        case .finalStats:
            finalScore         = m.finalScore
            finalRankingPoints = m.finalRankingPoints
            finalResult        = m.finalResult
            finalPenaltyScore  = m.finalPenaltyScore
            finalConfiguration = m.finalConfiguration
            finalComments      = m.finalComments
        case .actionsEdited:
            actionsPerformed = m.actionsPerformed
        default:
            break;
        }
    }
    
    func updateMatchWithAction(_ action:Action) {
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
                isCompleted |= 8;
            }
            break
        case let .penaltyData(penalty):
            print("\tPenaltyType: \(penalty.toString())")
            break
        default:
            break
        }
        actionsPerformed.append(action)
    }
    
    override func aggregateMatchData() {
        aggregateActionsPerformed()
    }
}
