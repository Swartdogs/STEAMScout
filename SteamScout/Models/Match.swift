//
//  Match.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol Actionable {
    func updateMatchWithAction(_ action:Action)
    func aggregateActionsPerformed()
}

protocol CsvDataProvider {
    static var csvHeader:String { get }
    var csvMatch:String { get }
}

protocol Match : CsvDataProvider {
    
    // Team Info
    
    var teamNumber:Int         { get set }
    var matchNumber:Int        { get set }
    var alliance:AllianceType  { get set }
    var isCompleted:Int        { get set }
    
    // Final Info
    
    var finalScore:Int         { get set }
    var finalRankingPoints:Int { get set }
    var finalResult:ResultType { get set }
    var finalPenaltyScore:Int  { get set }
    var finalFouls:Int         { get set }
    var finalTechFouls:Int     { get set }
    var finalYellowCards:Int   { get set }
    var finalRedCards:Int      { get set }
    var finalRobot:RobotState  { get set }
    var finalComments:String   { get set }
    
    // Calculated Variables
    var messageDictionary:Dictionary<String, AnyObject> { get }
    
    init(queueData:MatchQueueData)
    
    // Required Functions
    func updateForType(_ type:UpdateType, withMatch match:Match)
    func aggregateMatchData()
}

class MatchImpl : AnyObject, Match {
    
    // Team Info
    
    var teamNumber:Int         = 0
    var matchNumber:Int        = 0
    var alliance:AllianceType  = .unknown
    var isCompleted:Int        = 0
    
    // Final Info
    
    var finalScore:Int         = 0
    var finalRankingPoints:Int = 0
    var finalResult:ResultType = .none
    var finalPenaltyScore:Int  = 0
    var finalFouls:Int         = 0
    var finalTechFouls:Int     = 0
    var finalYellowCards:Int   = 0
    var finalRedCards:Int      = 0
    var finalRobot:RobotState  = .None
    var finalComments:String   = ""
    
    // Calculated Variables
    class var csvHeader:String {
        var matchHeader = ""
        
        matchHeader += "Match Number, Team Number, Alliance, "
        matchHeader += "Final Score, Final Ranking Points, Penalty Points Received, Final Result, Fouls, Tech Fouls, "
        matchHeader += "Yellow Cards, Red Cards, Robot, Config, Comments \r\n"
        
        return matchHeader
    }
    
    var csvMatch:String {
        var matchData = ""
        matchData += "\(matchNumber), \(teamNumber), \(alliance.toString)"
        
        return matchData;
    }
    
    var messageDictionary:Dictionary<String, AnyObject> {
        var data:[String:AnyObject]    = [String:AnyObject]()
        var team:[String:AnyObject]    = [String:AnyObject]()
        var final:[String:AnyObject]   = [String:AnyObject]()
        
        // Team Info
        team["teamNumber"]  = teamNumber as AnyObject?
        team["matchNumber"] = matchNumber as AnyObject?
        team["alliance"]    = alliance.toString() as AnyObject?
        
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
        final["comments"] = finalComments as AnyObject?
        
        // All Data
        data["team"]    = team as AnyObject?
        data["final"]   = final as AnyObject?
        
        return data
    }
    
    required init() {
        // Init
    }
    
    required init(queueData:MatchQueueData) {
        teamNumber = queueData.teamNumber
        matchNumber = queueData.matchNumber
        alliance = queueData.alliance
    }
    
    // Required Functions
    func updateForType(_ type:UpdateType, withMatch match:Match) {
        // Implement default!
    }
    
    func aggregateMatchData() {
        // Implement default!
    }
    
}

extension MatchImpl: Equatable {
    static func ==(lhs:MatchImpl, rhs:MatchImpl) -> Bool {
        return lhs.matchNumber == rhs.matchNumber && lhs.teamNumber == rhs.teamNumber;
    }
}
